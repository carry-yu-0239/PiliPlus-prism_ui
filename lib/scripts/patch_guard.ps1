param(
    [ValidateSet("android", "ios", "linux", "macos", "windows")]
    [string]$Platform = "android",
    [switch]$VerifyOnly,
    [string]$StateFile = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# This guard is only for the disposable CI environment. It does not change the
# original patch chain or authorize resetting a developer's shared Flutter SDK.
if (-not $env:GITHUB_WORKSPACE -or -not $env:FLUTTER_ROOT -or -not $env:PUB_CACHE -or -not $env:RUNNER_TEMP) {
    throw "Patch guard requires GITHUB_WORKSPACE, FLUTTER_ROOT, PUB_CACHE and RUNNER_TEMP"
}
$workspace = (Resolve-Path $env:GITHUB_WORKSPACE).Path
$flutterRoot = (Resolve-Path $env:FLUTTER_ROOT).Path
$pubCache = [System.IO.Path]::GetFullPath($env:PUB_CACHE)
$tempRoot = [System.IO.Path]::GetFullPath($env:RUNNER_TEMP)
$separator = [System.IO.Path]::DirectorySeparatorChar
if (-not $pubCache.StartsWith($tempRoot.TrimEnd($separator) + $separator, [StringComparison]::Ordinal)) {
    throw "Refusing to patch a PUB_CACHE outside RUNNER_TEMP: $pubCache"
}
if (-not $StateFile) {
    $StateFile = Join-Path $tempRoot "prism-$Platform-patch-state.json"
}
$stateParent = [System.IO.Path]::GetFullPath([System.IO.Path]::GetDirectoryName($StateFile))
if (-not $stateParent.StartsWith($tempRoot.TrimEnd($separator) + $separator, [StringComparison]::Ordinal) -and $stateParent -ne $tempRoot) {
    throw "StateFile must remain under RUNNER_TEMP"
}

function Get-Sha256Text([string]$value) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($value)
    return [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}
function Get-GitValue([string[]]$arguments) {
    $output = & git @arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($arguments -join ' ') failed: $($output -join ' ')"
    }
    return @($output) -join [Environment]::NewLine
}
function Get-InputFingerprint {
    $base = Join-Path $workspace "lib/scripts"
    $files = @(Get-ChildItem -LiteralPath $base -File -Recurse | Where-Object {
        $_.Extension -eq ".patch" -or $_.Name -eq "patch.ps1"
    } | Sort-Object FullName)
    $entries = foreach ($file in $files) {
        $rel = [System.IO.Path]::GetRelativePath($base, $file.FullName)
        "$rel=$((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash)"
    }
    return Get-Sha256Text ($entries -join [Environment]::NewLine)
}
function Get-SdkFingerprint {
    $status = Get-GitValue -arguments @("-C", $flutterRoot, "status", "--porcelain=v1", "--untracked-files=no")
    $diff = Get-GitValue -arguments @("-C", $flutterRoot, "diff", "--binary", "--no-ext-diff", "HEAD")
    return Get-Sha256Text ($status + [Environment]::NewLine + $diff)
}
function Get-PackageDir([string]$pattern) {
    $hosted = Join-Path $pubCache "hosted/pub.dev"
    if (-not (Test-Path -LiteralPath $hosted -PathType Container)) {
        throw "Missing pub cache hosted directory: $hosted"
    }
    $dirs = @(Get-ChildItem -LiteralPath $hosted -Directory | Where-Object { $_.Name -like $pattern } | Sort-Object Name)
    if ($dirs.Count -ne 1) {
        throw "Expected exactly one $pattern cache directory; found $($dirs.Count)"
    }
    return $dirs[0].FullName
}
function Get-PackageFingerprint([string]$packageDir, [string]$patchSubdir) {
    $patchDir = Join-Path $workspace "lib/scripts/$patchSubdir"
    $paths = [System.Collections.Generic.SortedSet[string]]::new([StringComparer]::Ordinal)
    foreach ($patch in @(Get-ChildItem -LiteralPath $patchDir -Filter "*.patch" -File)) {
        foreach ($line in [System.IO.File]::ReadLines($patch.FullName)) {
            if ($line -match '^\+\+\+ b/(.+?)\s*$') {
                [void]$paths.Add($Matches[1])
            }
        }
    }
    $entries = foreach ($relative in $paths) {
        $path = Join-Path $packageDir $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Patched package target missing: $path"
        }
        "$relative=$((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash)"
    }
    return Get-Sha256Text ($entries -join [Environment]::NewLine)
}
function Get-ObservedState {
    $revision = Get-GitValue -arguments @("-C", $flutterRoot, "rev-parse", "HEAD")
    $material = Get-PackageDir "material_ui-*"
    $cupertino = Get-PackageDir "cupertino_ui-*"
    return [ordered]@{
        version = 1
        platform = $Platform
        workspace = $workspace
        flutterRoot = $flutterRoot
        flutterRevision = $revision
        pubCache = $pubCache
        patchInputs = Get-InputFingerprint
        lockSha256 = (Get-FileHash -LiteralPath (Join-Path $workspace "pubspec.lock") -Algorithm SHA256).Hash
        sdkChanges = Get-SdkFingerprint
        materialDir = $material
        materialTargets = Get-PackageFingerprint $material "material"
        cupertinoDir = $cupertino
        cupertinoTargets = Get-PackageFingerprint $cupertino "cupertino"
    }
}
function Test-Marker {
    if (-not (Test-Path -LiteralPath $StateFile -PathType Leaf)) {
        throw "Patch state marker missing: $StateFile"
    }
    $recorded = Get-Content -LiteralPath $StateFile -Raw | ConvertFrom-Json
    $observed = Get-ObservedState
    foreach ($key in $observed.Keys) {
        if ([string]$recorded.$key -cne [string]$observed[$key]) {
            throw "Patch state mismatch ($key). Recreate isolated SDK/PUB_CACHE; do not replay destructive patch chain"
        }
    }
    Write-Host "Verified already-patched environment: Flutter $($observed.flutterRevision), lock $($observed.lockSha256)"
    Write-Host "Patch input fingerprint: $($observed.patchInputs); SDK diff: $($observed.sdkChanges)"
    Write-Host "material_ui: $($observed.materialDir); cupertino_ui: $($observed.cupertinoDir)"
}

if ($VerifyOnly) {
    Test-Marker
    return
}
if (Test-Path -LiteralPath $StateFile -PathType Leaf) {
    Test-Marker
    Write-Host "Idempotent patch guard: original patch.ps1 NOT re-executed"
    return
}

# A missing marker is only safe with a clean SDK checkout. The original Android
# chain contains git reset --hard and package deletion, so never attempt repair
# in-place after a partial or externally modified run.
$initialStatus = Get-GitValue -arguments @("-C", $flutterRoot, "status", "--porcelain=v1", "--untracked-files=no")
if ($initialStatus) {
    throw "Unmarked Flutter checkout is dirty. Recreate isolated environment before patching: $initialStatus"
}
$lockBefore = (Get-FileHash -LiteralPath (Join-Path $workspace "pubspec.lock") -Algorithm SHA256).Hash
$originalLocation = Get-Location
try {
    Write-Host "Applying the unmodified original $Platform patch chain once"
    & (Join-Path $workspace "lib/scripts/patch.ps1") $Platform
    if (-not $?) {
        throw "Original patch chain reported failure"
    }
    Set-Location $workspace
    $observed = Get-ObservedState
    if ($observed.lockSha256 -cne $lockBefore) {
        throw "pubspec.lock drift during original patch chain ($lockBefore -> $($observed.lockSha256))"
    }
    $tmp = "$StateFile.tmp"
    $observed | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $tmp -Encoding utf8
    Move-Item -LiteralPath $tmp -Destination $StateFile -Force
    Test-Marker
    Write-Host "Patch guard marker established after successful patch and lock validation"
} catch {
    Remove-Item -LiteralPath $StateFile -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath "$StateFile.tmp" -Force -ErrorAction SilentlyContinue
    Write-Host "::error::Patch guard failed: $($_.Exception.Message)"
    throw
} finally {
    Set-Location $originalLocation
}
