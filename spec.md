# PiliPlus × Prism UI 移植开发规范

> **规范版本：1.0 · 2026-11-11**  
> **目标仓库：carry-yu-0239/PiliPlus-prism_ui**  
> **状态：P1 基础集成开发中；P0 未完成的证据任务保留，G0/G1 尚未通过。**  
> 本文定义开发范围、架构、行为、参数、阶段任务和验收证据。后续开发必须按本文的需求编号与 TODO 推进；发现源码或实验结果与本文冲突时，先修正规范中的相应决定并记录原因，再改实现。

## 目录

0. 当前开发进度与会话交接
1. 规范用法与完成定义
2. 固定基线与审查结论
3. 产品范围、保留行为与不可漂移约束
4. 总体架构与目录职责
5. 依赖、受控补丁与构建环境
6. 主题、本地化、缩放与 Overlay 契约
7. 设置模型、能力检测与场景准入
8. 玻璃材质参数与分配矩阵
9. 动效、形状、触觉与减弱动效
10. 主导航、页面状态与安全边距
11. 按钮、菜单、弹窗和 Sheet
12. 播放器、直播、图片查看器与平台边界
13. 需求追踪与阶段依赖
14. P0—P10 详细开发 TODO
15. 测试矩阵、性能门槛与证据格式
16. 风险、待实测问题与固定处置
17. 变更控制、交接与最终验收
18. 固定源码索引

---

## 0. 当前开发进度与会话交接

> **更新日期：2026-11-13。当前实际开发阶段 P1；Gate G0 仍有未核验条目，G1 未验证。** 本章仅记录已提交代码、GitHub Actions 和实测证据；未满足原定义的 TODO 保持 `[ ]`。

| 交接维度 | 当前事实 |
|---|---|
| P0 历史分支及 PR | `feat/prism-p0-foundation`，[PR #2](https://github.com/carry-yu-0239/PiliPlus-prism_ui/pull/2) 为 Draft；基于文档分支 `docs/prism-ui-spec-20261111`，文档 [PR #1](https://github.com/carry-yu-0239/PiliPlus-prism_ui/pull/1) 尚未合入 `main` |
| P0 最近代码提交 | [`6d08421a13b55abab142d158fdd94adbb578c7da`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/6d08421a13b55abab142d158fdd94adbb578c7da)：为独立账户删除测试夹具显式提供 `buvid`；未修改产品逻辑、断言或测试门槛 |
| 最近两次正式验证 | [Run #10（push）](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43380337911)、[Run #11（pull_request）](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43380343098)，均 **success**；两者均对应同一代码提交 |
| 测试与构建结论 | Flutter 3.47.9 / Dart 3.13.7 / engine `9e025265bef30b838c0c1b68cad19decf97048f2`；原 Android 补丁链、lockfile 检查、`flutter analyze --no-fatal-infos`、`flutter test`（41/41）及 Android dev APK 构建、产物上传通过 |
| 构建证据 | [Run #10 的 APK artifact](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43380337911/artifacts/14017520193)：ARMv7、ARM64、x86_64 三种 APK；开发构建使用仓库已有的开发签名回退，不涉及生产签名或发布 |
| Gate G0 | **未通过**：全仓入口台账 P0-09/10 尚未完成；P0-01/04 和实机 P0-11—14 仍待完成或取证。P1 已由用户单独批准提前实施，验收 Gate 仍未通过 |
| 最近一次文档一致性检查 | 本轮编辑前，开发分支 `spec.md` 的 Git blob `f8de30659ad249714674800c539a6b2b97e5fe41` 与 Library 原文件版本 `1` 的原始字节 SHA 完全一致；本轮双端更新结果按回读实况另行报告。 `main` 等待 PR #1 合并 |

### 本轮故障、修复与验证

- 先前 [Run #8](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43212602139) 和 [Run #9](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43212610355) 均在 `flutter test` 失败：39 项通过，`test/utils/accounts/deleted_account_test.dart` 的两项测试因测试账户未设置 `buvid`，Hive 序列化时访问尚未初始化的 `GStorage.setting`，抛出 `LateInitializationError`；APK 因前置失败而跳过。
- 提交 `6d08421a` 只补齐测试数据。随后 push 与 PR 两次完整运行均通过 SDK/补丁/lockfile/analyze/test/build/upload。先前分析器的非致命诊断继续保留，`analyze` 步骤退出码为零不表示零诊断。
- **已完成并有证据的 P0 TODO：** P0-02、P0-03、P0-05、P0-06、P0-07、P0-08。证据分别见 [冻结基线](docs/prism/baseline.md)、[场景台账](docs/prism/surface_inventory.md)、上述 Actions 日志与产物。本轮关联 R01/R02、T01；没有 Prism 功能集成或真机 Shader 成绩。
- **正在执行/阻塞：** P0-01 需完成原始状态确认；P0-04 需建立/核实防止补丁重复执行的环境标记；P0-09/10 需按 `rg` 全面扩充稳定入口 ID、Navigator/返回值/滚动所有者；P0-11—14 缺少实际设备录像、截图与性能基线。所有这些 TODO 仍未勾选。
- **下一轮准确入口：** 先完成 P0-09 / P0-10 的逐调用点清单并审查 P0-04 标记机制，然后取得 P0-11—14 的设备证据；仅在 G0 所有条件可核对后进入 P1。


### 2026-11-13 用户批准的任务顺序变更：优先实施 P1

- **原条款**：§13.2、P1 前置 G0；必须先完成 P0 的入口全量审计和实体设备资料。**本轮新决定**：因 P0 Flutter 3.47.9/原补丁链/41项测试/Android APK 已有成功 Actions 证据，用户明确要求先投入可独立实施的 P1 工程工作。P0-01/04/09/10/11/12/13/14 继续保留未完成、G0 不宣告通过，G1/G2 等各自测试条件不降低；开发重排不是验收豁免。
- **原因和可回退性**：阻塞于设备、全面台账的项目不再阻止低风险引入 Prism 固定依赖及混合根桥接；默认关闭 Prism/Glass，随时可回退现有界面。不得提前激活媒体捕获或将试编译等同实机验证。
- **分支与可核实代码**：`feat/prism-p1-integration`，Draft [PR #3](https://github.com/carry-yu-0239/PiliPlus-prism_ui/pull/3)，基于 `feat/prism-p0-foundation`。[`2813e144`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/2813e144fec869c58d03df5281bd85c1f837a4ce) 引入固定 `5d8ed7ab…` 上游完整 194 文件（含两份 Shader、测试、LICENSE、NOTICE）；[`e6278e7`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/e6278e774bb2d15dedb83e0863ce61ff7a57cc96) 增加 path dependency、根桥接、20项本地化与受控 Motion/Measure 补丁；[`ce419c4`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/ce419c47392a5bef6364d85493de1457cc3ae57c) 修复 builder 闭包自引用，并将 Measure 置于 Prism 主题之下。
- **正在实施、不得勾选**：P1-01/02/03/05/07/10/11/12/13 有部分或主要代码，均待锁文件、包/应用测试、CI 校验；P1-04/06/08/09/14/15/16/17 尚未完成。**任何 P1 TODO 尚未取得全部完成证据。**
- **测试状态**：最后一次已确认成功的完整原版运行是 P0 [Run #10](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43380337911) / [Run #11](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43380343098)。P1 新提交触发的 [Run #17](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43389900615) 在此记录写入时尚未取得最终结论；不能视作成功。新依赖的 `pubspec.lock` 及完整补丁验证仍需核对。
- **关联需求/验证**：R01/R02、P1-01～17 与 G1；后续 P2/G2 的 Shader 与设备验证继续按 T 编号及 §15 适用矩阵执行。P0 原始验收门槛和 P2—P10 性能边界原封不动。
- **下一工作入口**：依据真实 CI 日志解决 P1 新依赖的 `pubspec.lock` 与 Dart API 编译问题；继续 VP-01/04/05/07，完成包测试、混合 App tests 与实际 Android APK，随后处理独立 P2/P3 适配。
- **文档位置**：本次修改首先提交 P1 分支 GitHub 原 `spec.md`，随后以 Library 稳定原文件 ID `libfile_5fddde3697608191a9fd61f84b677435` 的当前版本原位覆盖并回读；`main` 仍待文档 PR #1及后续开发 PR 合并。若双端某一步失败，则本条不得代表同步成功。



### 2026-11-13 P1/P2/P3/P4 实际代码实施交接（最新）

- **分支/PR**：`feat/prism-p1-integration`，Draft [PR #3](https://github.com/carry-yu-0239/PiliPlus-prism_ui/pull/3) → `feat/prism-p0-foundation`；`main` 仍待 PR #1 与 #2/3 按依赖合并。最新 P1 代码提交 [`5052f317`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/5052f317d66a4fc152fb1fd9f416ea52b89fb817)（尚需本轮最新 GitHub Actions 终检）。
- **P1 已写入源码（待全部验证）**：`packages/prism_ui` 固定上游194文件；`pubspec.yaml`、`pubspec.lock` path 依赖；`lib/main.dart` + `lib/prism/bridge.dart` 的 Material/Prism 颜色主题映射、真实 IconTheme、20 字段 UiLocalizations、Measure/View/Motion Scope、唯一根 Host；VP-01 Dock 重新激活与单层徽标/触觉，VP-02 reduced/Haptics 部分接入，VP-03 Measure 文本缩放与方向，VP-04 Shader ensureLoaded 状态（profile计数尚缺），VP-05 字重覆盖（显式覆盖点待审计），VP-07 未实现。补丁源文件/尚待测试记录见 `packages/prism_ui/PATCHES.md`。
- **P2 已写入源码（待验收）**：`lib/prism/preferences.dart`、`glass_policy.dart`、原 `storage_pref.dart` / `storage_key.dart` 和 `style_settings.dart`：实验 UI 总开关、Off/Standard/Ultra、动效与页面过渡持久化、安全默认值、确定性的有效玻璃准入（渲染器/Shader/媒体/过渡/高对比度/前后台），增加 `test/prism/preferences_test.dart`、`glass_policy_test.dart`。主业务树有播放器/PlatformView 风险，当前标记 `unsafeSurface=true`，所以**仅独立预览的无媒体场景可启用原生 Shader**，不把预览当作生产整页折射验收。新增 `lib/prism/preview_page.dart` 设置页入口，直接采用原生 LiquidGlass 与 NavigationDock，可交互预览。
- **P3 已写入源码（待验证）**：`lib/prism/navigation_adapter.dart` 提供三个原生 Glyph 与实际配置序列，真实 `main/view.dart` 底栏在实验开关开启后改用原生 NavigationDock，保留旧 floating/Material 模式；dynamic badge 对 dot/number/hidden 做显式准入和语义去重，原 `MainController.setIndex` 的业务选择、重选回顶与节流不重写。触觉由新 Dock feedback hook 与业务 `haptic:false` 分工，拖动回当前项不误重选。P3 SafeArea/真实手势/性能矩阵未验证，G3 不通过。
- **P4 已写入源码（待验证）**：`lib/prism/root_tab_host.dart` 在 Prism 实验模式选择稳定身份、惰性创建并保留已访问页面，支持 inherit/none/fade/slide（220/300ms）、系统 reduced 和新目标中断；使用原生 `LiquidGlassFade`，没有截图中间页或复制播放器纹理。`MainController` 的传统 Page/Tab controller 保留在旧界面分支，Prism 分支不创建旧 controller。新增 `test/prism/root_tab_host_test.dart`；尚未通过 CI/G4，不能宣称保活和快速中断完整验证。
- **提交证据**：[`bc2cad15`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/bc2cad153a3c70a845202390ec69f244cd1c6e40) 初次锁文件；[`0538fcc0`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/0538fcc052d1ab2bf8d1fd825dafb950bb806051) P2 配置；[`930e7067`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/930e7067f9c4f31f8df313ecda5540faa8b3adaa) 修复真实 pub lock 排序；[`3b42a440`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/3b42a4407b20e5283d4851656e990bdd997edec3) 原生导航/无媒体预览/Shader 状态与场景策略；[`a7f5845c`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/a7f5845c5d72df108b630942dd2c884fb6cbbdbd) P4 root host、字重补丁与测试。
- **Actions 实况**：[Run #43390836533](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43390836533) 曾因 `freezed_annotation` 字母排序漂移失败，现已按 CI diff 修复；[Run #43391165642](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43391165642) 通过原补丁、lockfile、analyze 和 test，但被后续 push 取消 APK；[Run #43392174612](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43392174612) 通过 analyze/test，APK 构建启动但结果待追踪；[Run #43393322012](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43393322012) 为最新 `a7f5845c` 触发、在此记录时无最终结论。**不得把取消运行的 APK 和未结束运行当成成功。**
- **TODO/Gate**：P1-01～13、P2 设置/策略、P3-01～10、P4-01～07 均为已实现部分或主要代码、待证据；**仍全部保持 `[ ]`**。P0 未完成清单与 G0 保留，G1～G4 均尚未通过；真机 Shader/PlatformView/120Hz/GPU 和手势录屏尚未验证。
- **下一轮精确入口**：首先读取最新 PR #3 Actions 的 analyzer/test/build 完整结果；按日志修复 `a7f5845c` 的 API 或生命周期问题并重跑。之后补 VP-01 触摸/键盘/语义包级测试、VP-02 完整 reduced ticker、VP-04 profile 计数、VP-07 route 主题捕获及 P3 SafeArea；在获得 G2/G3 证据前保持生产混合 Host 禁止捕获。
- **双端文档同步**：必须将本记录作为原 `spec.md` 内容同步到 P1 开发分支和原 Library 文件 `libfile_5fddde3697608191a9fd61f84b677435`，两端完整字节 SHA 相等后才可报告成功；main 等待合并。



### 2026-11-13 P1/P2 原生玻璃主页面与扩展 CI 交接

- **真实主界面接入**：[`06681eeb`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/06681eeb76ff4a294caeeb31f367ec5eea552ee8) 在 `lib/pages/main/view.dart` 的 MainLayout 内接入独立原生 `LiquidGlassHost`。当用户显式开启实验 UI 并选 Standard/Ultra 后，主 Tab 的背景可被原生 NavigationDock 取样；主 Host 在 `didPushNext`/`didPopNext` 的路由前后台、应用生命周期、Shader 状态、系统高对比度及渲染支持不满足时回退实体。根 Bridge 的跨路由 Host 仍保守关闭，视频/直播/图库等独立路由不被主 Host 纳入背景取样。这是原生代码集成，**尚无实体 Android 设备 GPU 折射截图和性能证据**。
- **P1 补丁进度**：[`6759c03`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/6759c03b66dad760c9d96e03f67a7d9b62f8ae5d) 依据 CI `flutter analyze` 提示，让 P4 `_generation` 真正作为异步过渡完成的防竞态 token；[`06681eeb`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/06681eeb76ff4a294caeeb31f367ec5eea552ee8) 为 Shader 加载增加无图像引用的可选 capture/held 数字计数与 `test/prism/shader_diagnostics_test.dart`，新增20项本地化回退 `test/prism/localizations_test.dart`，并让减弱动效控制原底栏的显隐动画时长。VP-04 的真实 Shader 失败注入、Profile GPU 证明仍缺。
- **P1 字重补丁增强**：[`5052f317`](https://github.com/carry-yu-0239/PiliPlus-prism_ui/commit/5052f317d66a4fc152fb1fd9f416ea52b89fb817) 在原生 ThemeData 上增加绝对字重解析器 `resolveFontWeight`，统一 AppTextStyle 及 Alert 原先显式的 `w500` 动作文字覆盖，未修改原有默认字重比例。仍需审查其他直接使用 `fontWeight:` 的控件，VP-05 保留部分完成状态。
- **扩展验证工作流**：在 `prism-verify.yml` 中保持旧 SDK/补丁/lockfile/Flutter analyze/应用测试/APK 原门槛，并在应用测试与 APK 之间增加 `packages/prism_ui` 的独立 `flutter pub get` + `flutter test --no-pub`，实际运行 vendored 上游完整组件套件，不以根级应用测试冒充包级测试。
- **CI 证据**：[Run #43393636728](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43393636728) 失败由 P4 `_generation` unused-field warning 引起，已精确修复；[Run #43394106500](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43394106500) 通过 SDK/补丁/lockfile、`flutter analyze`、现有应用测试，APK 开始构建后被新提交取消，不能认定 APK 通过；[Run #43395381843](https://github.com/carry-yu-0239/PiliPlus-prism_ui/actions/runs/43395381843) 是新增主 Host 与包级测试的最新运行，最终结论待回读。
- **实际 TODO/Gate**：P1-08（计数扩展）、P1-11（本地化测试）、P1-16（包级测试环境）、P2-08（根/主页面有效玻璃策略）、P3 导航主线、P4 页面过渡均**处于代码已实现或部分实现、待 CI/手势/设备验收**；保持对应 `[ ]`、G1-G4 未通过。P0 未完成原任务继续存在，main 仍待合并。
- **下一轮准确入口**：读取 Run #43395381843 全部 jobs/step/logs，修复失败并获得 APK 结果；随后补 VP-01 触摸键盘/徽标双层绘制测试、VP-02 reduced ticker cleanup、VP-04 Shader 状态失败测试、VP-07 主题捕获，评估 P3 主页面滚动/安全边距和设备捕获。
- **文档同步要求**：此新增记录属于原始 `spec.md`，写入 GitHub P1 分支后必须使用 Library 同一稳定文件 ID 原位覆盖，比较全文 blob SHA；main 等待 PR 合并。


## 1. 规范用法与完成定义

### 1.1 本文中的三种陈述

| 标记 | 含义 | 后续处理 |
|---|---|---|
| **源码事实** | 在下列固定提交的文件或测试源码中确认 | 可据此设计；不等于本项目运行通过 |
| **设计决定** | 本次移植已经选定的行为或实现边界 | 开发必须遵循；变更须更新决定记录 |
| **验证门槛** | 只有编译、自动测试或实机实验才能证明 | 未取得证据不得宣称完成或支持 |

“必须 / 不得”是验收条件；“建议”允许等效实现，但应解释取舍。文中新增类型、字段、路径若注明“拟新增”，均为待实现契约，不能当作上游现成 API。

### 1.2 单个 TODO 如何完成

每个 TODO 都有唯一编号，例如 `P3-07`。满足以下条件后才能从 `[ ]` 改为 `[x]`：

1. 对应实现已提交，并记录 commit / PR。
2. 本阶段要求的测试或观察已经执行；有结果及环境信息。
3. 对应需求没有被视觉近似、静态截图或模拟数据偷换。
4. 存在已知限制时，明确列入支持矩阵，而不是删除测试或静默降级后仍声称支持。

本文件交付时，所有开发 TODO 保持未完成。源码审查不替代 `flutter analyze`、组件测试、真实 Shader 渲染和手机性能测试。

### 1.3 完整移植的定义

v1 的完成目标是：**保留 PiliPlus 业务与导航架构，提供可选择的 Prism 界面，在允许的场景复用其原生玻璃、连续曲率、按压反馈和连续手势；所有已有业务行为与明确保留的界面能够正常工作。**

这包括完整的基础运行环境、导航、通用操作入口、菜单、普通弹窗、设置开关和经过逐项批准纳入范围的普通 Sheet。播放器相关复杂界面在 v1 保持既有容器与业务语义，应用明确的玻璃禁用策略。

“完整”不等于把仓库所有 Material/Cupertino 组件机械替换成 Prism。必须给每类组件一个确定归属：已迁移、保留并有理由、或进入独立后续需求。不得留下没有登记的半迁移状态。

## 2. 固定基线与审查结论

### 2.1 版本冻结

| 项目 | 固定提交 / 版本 | 用途 |
|---|---|---|
| PiliPlus-prism_ui | `cab0114a21ce7fad5b90b9a4d788d35d313d25f9` | 本规范的应用基线 |
| prism_ui | `5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6` | 实际引入与最小补丁的上游基线 |
| FlClash | `be84736605527034689c95bf27828ff27d912c5e` | 场景、交互和测试设计参照 |
| FlClash 的 prism_ui submodule | `63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185` | 解释参照实现与引入版本的差异 |
| PiliPlus 应用版本 | `2.2.0+1` | 源码声明；正式构建脚本另生成版本信息 |
| PiliPlus Flutter | `.fvmrc` 和 `pubspec.yaml` 均为 `3.47.9` | 本轮移植固定 SDK |
| PiliPlus Dart 声明 | `>=3.13.0` | 不把下限当作唯一可用版本 |
| Prism 包版本 | `0.1.2` | Dart `>=3.10.0 <4.0.0`，Flutter `>=3.47.0` |
| FlClash CI Flutter | `3.47.6` | 仅是参照仓库构建值；不复制到本项目 |

来源：[P-PUB]、[P-FVM]、[U-PUB]、[F-PUB]、[F-SUB]、[F-GITLINK]、[F-CI]。其中 `.gitmodules` 只证明子模块路径与来源；`63450c0a…` 由固定 FlClash tree 的 `plugins/prism_ui` gitlink（mode `160000`）确认，不能从 `.gitmodules` 推出提交。

`5d8ed7ab` 的父提交就是 `63450c0a`，新增的是鼠标 press 赢得手势竞技场后拖出时墨迹未消失的修复。因此保留较新的 Prism 提交，同时明确它与 FlClash 所锁版本不是同一 SHA。[U-PRESS-FIX]

### 2.2 已确认的关键约束

| 编号 | 源码事实 | 对移植的直接要求 |
|---|---|---|
| F01 | PiliPlus 使用定制 GetX、`material_ui`、`cupertino_ui` 和 SDK / 包补丁 | 不按未打补丁的通用 Flutter 示例直接施工 |
| F02 | 根应用是 `GetMaterialApp`，含 SmartDialog、路由观察器和自定义 MediaQuery | 保留根应用，增加桥接；不嵌套第二个 App |
| F03 | Prism 的 ThemeData / ColorScheme 独立于应用现有类型 | 显式字段映射与 import 前缀 |
| F04 | Prism 依赖应用提供 `UiLocalizations`；部分组件要求 MeasureScope / ViewScope | 基础阶段必须补齐，不能只包 Theme 和 Host |
| F05 | NavigationDock 只有 Glyph、label、selectedIndex、onSelected 等窄接口；触摸同项释放不回调 | 徽标、重选、触觉和减弱动效需要受控补丁 |
| F06 | Dock 的多个弹簧是私有常量；不是公开的全局强度配置 | 保留标准参数，按场景选组件；新增减弱动效入口 |
| F07 | `LiquidGlassScope` 默认 quality 是 Ultra；Off 不是质量枚举 | 桥接必须显式传 quality 与 enabled |
| F08 | Host 的 layer replay 没有 TextureLayer / PlatformViewLayer 分支 | 有视频或平台视图风险时禁止捕获 |
| F09 | PiliPlus Windows 和 Linux 入口显式关闭 Impeller | 不能把这些平台标成已支持完整折射 |
| F10 | 原主导航支持删除、排序、启动页、未读、重选回顶、双击刷新、隐藏、侧栏 | 必须逐项保留；不能只接三个固定按钮 |
| F11 | `RouteAwareMixin` 使用 `RouteObserver<GetPageRoute>` 并强制转换当前 route | 不全局替换页面 route 类型 |
| F12 | 视频相关 Sheet 包含持久面板、LocalHistoryEntry、横屏右侧弹层 | 不统一替换为 SnapSheetRoute |
| F13 | FlClash 默认玻璃关闭；内容卡/行主要用 ink，普通按钮 tint，浮动操作才 elastic | 质量、运动与场景分开；禁止全页面玻璃化/缩放 |

证据：[P-ROOT]、[P-PATCH]、[P-NAV-C]、[P-NAV-V]、[P-ROUTE]、[P-SHEET]、[P-PAGE-UTILS]、[P-WIN]、[P-LINUX]、[U-THEME]、[U-L10N]、[U-MEASURE]、[U-VIEW]、[U-DOCK]、[U-GLASS]、[U-CAPTURE]、[F-CONFIG]、[F-PRESS]。

### 2.3 本轮审查的证据边界

已读取三个固定仓库的相关源码、依赖声明、锁文件、构建脚本、平台入口和组件测试；额外核对了 PiliPlus 锁定的 SmartDialog `5a1be84314e8c53efa3b7324cd8dc535fefe931a` 的初始化与 Overlay 实现。[P-LOCK]、[D-SMART]

本轮环境没有 Flutter / Dart 可执行程序。因此本文不声称已经构建成功、测试通过、达到某个帧率或完成 Android 真机验证。声明的 SDK 区间兼容，只证明约束没有表面冲突；实际依赖求解和补丁兼容是 P0 / P1 门槛。

## 3. 产品范围、保留行为与不可漂移约束

### 3.1 v1 范围矩阵

| 区域 | v1 决定 | 不允许出现的偏移 |
|---|---|---|
| 根主题、环境、能力与设置 | 接入完整桥接 | 用 PrismApp 取代 GetMaterialApp |
| 竖屏 / 底部主导航 | 提供 Prism Dock，保留全部业务 | 写死首页、动态、我的的索引顺序 |
| 平板 / 横屏侧栏 | 保留现有 Drawer / Rail 结构和行为 | 为“统一”强制变成底部 Dock |
| 主 Tab 切换 | Prism 模式提供继承/无/淡入淡出/滑动；稳定保活 | AnimatedSwitcher 重建页面与控制器 |
| 顶栏搜索和工具按钮 | 按入口分批迁移，采用原生反馈 | 给整个 AppBar 大面积做透镜 |
| 视频卡操作菜单、设置选择菜单 | 使用 typed adapter，保留业务 callback | 把所有长按改为按下立即打开 |
| 普通确认、警告弹窗 | 分批迁移到 Prism Alert | 改变确认、取消、返回值和危险操作逻辑 |
| 设置 Switch | 保留整行点击和持久化语义 | 一次点击导致切换两次 |
| 普通可滚动选择 Sheet | 在逐项登记后迁移 SnapSheet | 把原列表 controller 丢弃后声称交接完成 |
| 播放器、直播、视频内评论 / 分集面板 | 保留既有专用容器；执行玻璃禁用 | 变更播放、横屏、PiP、局部遮罩与返回历史 |
| 图片/Live Photo 查看器、WebView、验证码、支付 | 保留；覆盖视频/平台视图风险 | 只按 `/video` 路由判断安全 |
| 视频卡、评论流、动态卡、正文排版 | 实体信息表面；必要操作入口迁移 | 每张卡加玻璃或整体弹性缩放 |
| 全局返回手势、滚动物理、文本选择 | 保留既有实现 | 全局引入 DragBackRouteMixin 或替换现有滚动补丁 |

### 3.2 必须保留的业务

- 账号、登录、鉴权、数据请求、缓存、下载、历史、收藏、稍后再看、屏蔽与分享逻辑。
- 视频播放状态机、音频、进度、字幕、弹幕、倍速、长按、亮度、音量、双击、锁屏、全屏、画中画与远端播放控制。
- 原有导航排序、导航项删除、启动页配置，以及返回到 Navbar 当前排序的第一项的规则。
- 深浅主题、动态取色、纯黑、用户字体、字重、文本缩放、UI 缩放、横屏适配和触觉偏好。
- 已有 Material / Cupertino / SmartDialog 表面仍能独立正常使用；关闭 Prism 后恢复原渲染路径。

### 3.3 明确不在本轮做的工作

不得在本次移植顺带升级 Flutter、改造 GetX 为另一状态库、替换播放器、重建导航栈、重做内容信息架构或引入新的网络/账号依赖。视频背景真实折射、Windows/Linux Impeller 启用、全库任意数值动效编辑器、逐组件质量分级，都属于独立后续需求。

这些边界限制的是开发范围，不是允许放弃已列入 v1 的基础桥接、菜单行为、导航兼容和回归测试。

## 4. 总体架构与目录职责

### 4.1 三层职责

| 层 | 负责 | 不负责 |
|---|---|---|
| 上游组件层 `packages/prism_ui` | 材质、连续曲率、原生状态机、绘制与窄扩展 API | PiliPlus 路由名、业务服务、用户内容和 Hive |
| 应用适配层 `lib/prism` | 主题/本地化桥接、场景策略、配置、业务事件映射、环境诊断 | 另写一套 Dock 弹簧或复制 Shader |
| PiliPlus 页面与控制器 | 数据、业务动作、页面身份、生命周期、现有播放器 | 散落玻璃数值、私自修改库内部状态 |

### 4.2 计划目录

以下是拟新增路径；不是当前已经存在的源码：

| 路径 | 单一职责 |
|---|---|
| `packages/prism_ui/` | 固定上游副本及最小补丁 |
| `packages/prism_ui/UPSTREAM.md` | 上游 URL、完整 SHA、复制范围、更新步骤 |
| `packages/prism_ui/PATCHES.md` | 补丁账本：编号、理由、修改文件、测试、移除条件 |
| `lib/prism/app_bridge.dart` | 安装必要环境，保持原 Navigator 子树身份 |
| `lib/prism/theme_bridge.dart` | 现有主题到 Prism 主题的确定性映射 |
| `lib/prism/localizations.dart` | UiLocalizations 与 delegate |
| `lib/prism/preferences.dart` | 新设置的安全解析、持久化与通知 |
| `lib/prism/glass_policy.dart` | 质量、材质、场景准入；不拥有业务状态 |
| `lib/prism/motion_policy.dart` | 系统/用户减弱动效与场景反馈选择 |
| `lib/prism/scene_controller.dart` | 不安全表面租约、路由过渡和捕获抑制 |
| `lib/prism/navigation_adapter.dart` | 导航身份、徽标、选择/重选/触觉适配 |
| `lib/prism/navigation_metrics.dart` | Dock 占用、安全边距和布局模式 |
| `lib/prism/root_tab_host.dart` | Prism 主 Tab 的保活与可中断页面呈现 |
| `lib/prism/icons/pili_glyphs.dart` | 三个导航业务 Glyph；不混用 Widget 图标类型 |
| `lib/prism/widgets/action_button.dart` | 顶栏/普通按钮的有限外观适配 |
| `lib/prism/widgets/popup_menu.dart` | typed 菜单模型与执行时点 |
| `lib/prism/widgets/alert.dart` | 返回值、取消与危险动作适配 |
| `lib/prism/widgets/switch.dart` | 设置开关的事件与语义适配 |
| `lib/prism/widgets/sheet.dart` | 普通 Sheet 的结果、控制器和 Navigator 归属 |
| `lib/prism/debug/gallery.dart` | 内部组件预览与交互检查 |
| `test/prism/` | 应用桥接、策略和业务交互回归 |
| `integration_test/prism/` | 实机/模拟器可重复操作脚本 |
| `docs/prism/surface_inventory.md` | 组件迁移台账 |
| `docs/prism/verification/` | 不包含账号信息的测试与性能证据 |
| `docs/prism/decisions/` | 对本规范的明确变更决定 |

文件允许在同一职责内合并，不能为了满足目录表造空壳。跨层依赖必须单向；例如 vendored Dock 不得 import `PiliPlus/utils/storage_pref.dart`。

### 4.3 唯一状态来源

| 状态 | 权威来源 | 适配层允许持有的内容 |
|---|---|---|
| 当前导航项 | MainController + NavigationBarType | 动画中的视觉位置、过渡序号 |
| 未读与账号 | 现有业务控制器 | 只读显示值 |
| 主题 | 现有 Material 主题和用户设置 | 缓存后的 Prism 映射 |
| 播放状态 | 原播放器 | 是否有可见不安全绘制表面的租约 |
| 请求玻璃模式 | 新设置 | 有效模式与降级原因 |
| 触觉开关 | 既有 feedBackEnable / enableFeedback | 同一偏好的实时快照 |
| 弹层业务结果 | 原业务 callback/Future | 关闭过程、一次性分发标记 |

## 5. 依赖、受控补丁与构建环境

### 5.1 已选依赖方案

**采用 `packages/prism_ui` 受控 vendoring，并使用 path dependency。** 之所以不在本规范中继续悬置“直接 Git 依赖还是 fork”，是因为徽标、重选、触觉偏好和部分减弱动效已确认无法仅用上游公开 API 保留。

```yaml
# 规划片段：待 P1 实施
dependencies:
  prism_ui:
    path: packages/prism_ui
```

保留上游 package name `prism_ui`，以保证内部 package imports 和 `packages/prism_ui/shaders/...` 资源路径不变。保留运行时源码、着色器、pubspec、生成文件、LICENSE、NOTICE 和相关上游测试。不得把上游 `.git`、构建目录、私有环境配置带入应用仓库。

上游生成代码保持原样；只有模型确实变化时，才在包自己的工具链里重新生成。不得手改 `lib/generated/models.freezed.dart`，不得为包的 dev_dependencies 无差别升级主应用全部生成器。[U-PUB]、[U-NOTICE]

### 5.2 必要补丁账本

| 补丁编号 | 拟新增能力 | 修改边界 | 必须证明 |
|---|---|---|---|
| VP-01 | Dock `onReselected`、`onActivationFeedback`；destination badge 与语义补充 | `navigation_dock.dart`，保留原弹簧/几何 | 输入路径统一且只触发一次；点击反馈保留、拖动提交不双震 |
| VP-02 | 窄 MotionScope；Dock/ElasticPress/Popup/Alert/SnapSheet 减弱动效；触觉 gating | 只修改动效入口、反馈分发和必要清理 | 标准模式参数不变；切换模式无半途残留 |
| VP-03 | `Measure.withTextScaler(context, scaler)` 与正确的默认文字方向 | `measure.dart`，旧 `.of(context,double)` 保留 | 实际TextScaler与Directionality参与测量/缓存 |
| VP-04 | 幂等 ensureLoaded 入口、只读 Shader 加载/能力状态及可控 profile 计数 | 复用上游唯一资源加载器与 Future；诊断不持有图像 | 不改 Shader、atlas、uniform 和质量算法；无启动死锁、无失效计数假通过 |
| VP-05 | 可空绝对字重覆盖与统一 resolver | ThemeData、AppTextStyle，已迁移控件的显式字重例外 | null 与上游一致；非 normal 用户偏好按绝对字重生效 |
| VP-06 | `SnapSheetRoute.topPeek`，默认 `stackedSheetPeek`（10dp） | 仅最大高度 `_SheetModel._peak` 的每 route 顶部预留；P7实施 | 默认行为不变；音频收藏设0时实际达到可用高度的1.0 |
| VP-07 | Popup/Alert/Sheet 的可空 `CapturedThemes` 与源主题传递 | route helper、PopupAnchor与整个弹层内容/过渡的主题边界；P1实施 | 局部主题的文字和材质一致；根玻璃/动效/场景策略仍实时变化 |

VP-01 建议签名：`NavigationDock.onReselected: ValueChanged<int>?`、`onActivationFeedback: VoidCallback?`；destination 增加可空badge Widget和semanticLabel。反馈hook默认null保持上游，仅在真正派发激活且本次手势尚未实际发送跨项/fling触觉时调用，并受统一hapticsEnabled约束；应用传现有feedBack，详见§9.4。badge布局使用Dock已计算的真实destination geometry，不开放任意整项Widget替换以破坏透镜副本与hit testing。

VP-02 的名称可采用 `PrismMotionScope` 与 `PrismMotionData`；这些是新 API。只公开最终 `reduceMotion` 和 `hapticsEnabled`，不公开任意全局倍率。必须修改 `lib/context.dart` 的 disableAnimations/motionDuration，使其读取系统 OR 新 scope；另行覆盖 Dock/ElasticPress 自建 ticker。Dock、Popup 内部直接发出的 selectionClick 受统一开关控制；该基线 Switch 不直接发触觉，不为迁移额外添加震动。

VP-04 的状态至少区分 `notLoaded / loading / ready / failed` 和 renderer 是否支持 Shader filter。**必须新增幂等 `ensureLoaded()` 窄入口**：用户已请求非 Off、当前启动的 Prism 已开启、renderer 支持时，根桥接非阻塞地主动触发；复用上游唯一 `_loading` Future 和程序缓存，成功/失败通知可解除监听。上游当前仅在 pane paint 请求时加载；如果等待 ready 才创建 pane、却没有主动加载入口，会永远停在 notLoaded。Off 不触发加载；已开始的加载可完成但不能越过当前 Off/场景策略重新启用。失败后保持本进程终态，不每帧重试，不向应用暴露 FragmentProgram。[U-GLASS]

VP-04 的诊断另提供默认关闭、由验证构建显式开启的数值计数入口，例如 `PRISM_PROFILE_METRICS=true`；release构建不启用。必须在profile中有效，区分累计capture pass、实际snapshot次数、当前pane数和当前held引用数，并支持按测量窗口读取差值。不得保存 `ui.Image` / atlas / source snapshot 对象或改变捕获流程。上游 `debugCaptures` 和 `debugLastCapture` 的更新在assert内，profile/release被裁掉，不能读到0就判定没有捕获；`debugHeldCaptures` 是另一条直接计数路径，也不能与capture次数混称。[U-CAPTURE]

VP-06 不改全局 `stackedSheetPeek`，它仍用于叠层覆盖的位移与几何；只让当前route的最大高度上限可选。最大宽度在应用的公开route子类处理，不扩展库的任意布局参数。VP-07保留可空默认以兼容上游；捕获范围与热更新规则见§6.3，不能将整个应用环境对象快照到弹层。

### 5.3 代码边界

- 标准模式不得重写 Shader、替换 `_Spring` 算法、把弹簧追随改成每帧重启动画。
- 应用层只能使用公开接口；禁止跨 Dart library 访问私有成员、复制内部状态机到 `lib/prism`。
- 一项补丁一个清晰理由和回归测试；合入新上游版本时逐项判断是否已被上游覆盖。
- 保留 GPL 与 NOTICE 中各来源的声明。源内 HCT、shape、sliver、ink Shader 等有独立来源说明，不能仅复制顶层 LICENSE。[U-NOTICE]

### 5.4 SDK 与依赖补丁环境

PiliPlus 的 `lib/scripts/patch.ps1` 会修改 Flutter SDK，同时对 pub cache 中的 `material_ui` / `cupertino_ui` 应用补丁；部分平台分支还含 `git reset --hard HEAD` 和包缓存删除。因此 P0 必须在**专属 SDK checkout 和专属 PUB_CACHE**中重现构建，不能把它直接指向开发者共享 SDK。[P-PATCH]

固定顺序：确认 SDK 3.47.9 → 配置隔离目录和脚本要求的 `FLUTTER_ROOT` / `GITHUB_WORKSPACE` → 审核并按目标平台执行现有 patch 流程 → 核对补丁清单及 lockfile → analyze/test/build。保持原脚本语义；不以跳过补丁来“修好构建”。

首次加入 Prism 允许引入它必需的传递依赖；`pubspec.lock` 中与此次接入无关的 Git resolved-ref 和包版本应保持。发现大面积漂移先查求解原因，不能直接提交全量升级。

Shader 由 Prism 包自己的 `flutter.shaders` 注册：`liquid_glass.frag`、`ink_sparkle.frag`。PiliPlus `assets/shaders/` 的视频处理文件属于另一用途，禁止混放或替代。[P-PUB]、[U-PUB]

## 6. 主题、本地化、缩放与 Overlay 契约

### 6.1 已核对的现有装配

PiliPlus 当前 `GetMaterialApp.builder` 使用 `FlutterSmartDialog.init(builder: _builder)`。锁定 SmartDialog 的实现会先构造 `FlutterSmartDialog(child: 原 child)`，再把这个 Widget 传给 `_builder`；SmartDialog 自身内部创建 Overlay。因此只在 Navigator 某个页面内包 Host 会遗漏部分弹层，正确插入点是 `_builder` 收到的整体子树之外。[P-ROOT]、[D-SMART]

### 6.2 必须实现的逻辑层次

顺序从外到内：

1. 保留 GetMaterialApp 及其原本主题、delegates、路由与 observers。
2. 保留原桌面 BackDetector 和现有 MediaQuery 缩放结果。
3. 在**缩放后的 MediaQuery 下**用新的 Builder 获取上下文，建立 `PiliPrismBridge`。
4. 安装 Prism Theme；在其下恢复原有 IconTheme 给旧界面，Prism adapter 在需要时提供局部图标主题。
5. 安装 MeasureScope、ViewScope 与 MotionScope。
6. `LiquidGlassScope(enabled: effectiveEnabled, quality: explicitQuality)`。
7. 唯一稳定的根 `LiquidGlassHost(enabled: effectiveEnabled)`。
8. `_builder` 原先收到的整个 SmartDialog 子树，包括其 Overlay 和 Navigator。

Host/Scope 的开关和主题更新不得更换 Navigator key、SmartDialog key、页面 key 或重新初始化 GetX 控制器。始终保留 Host 节点，用其 enabled 属性切换；不能用两套不同父树来回替换整棵应用。

不要额外安装 PrismApp、第二个 Navigator、第二套 HeroController，或全局替换 ScrollConfiguration。BannerHost、RemoteFocusAdapter、ThemeCrossFade、DefaultSelectionStyle 只有独立采用对应能力时才评估；v1 基础桥接不默认引入。[U-APP]

### 6.3 主题映射

导入当前应用实际使用的 `package:material_ui/material_ui.dart`，明确前缀，例如 `m`；Prism 使用 `p`。不要把 `flutter/material.dart` 的类型与当前定制包不经核对混用。Glyph 另从 `package:prism_ui/icons/icons.dart` 导入，Prism 主 barrel 没有导出该目录。[P-ROOT]、[U-BARREL]

ColorScheme 对应角色必须逐项映射，不重新 `fromSeed`：

| 角色组 | 要映射的字段 |
|---|---|
| 基础 | brightness |
| Primary | primary / onPrimary / primaryContainer / onPrimaryContainer / primaryFixed / primaryFixedDim / onPrimaryFixed / onPrimaryFixedVariant |
| Secondary | secondary / onSecondary / secondaryContainer / onSecondaryContainer / secondaryFixed / secondaryFixedDim / onSecondaryFixed / onSecondaryFixedVariant |
| Tertiary | tertiary / onTertiary / tertiaryContainer / onTertiaryContainer / tertiaryFixed / tertiaryFixedDim / onTertiaryFixed / onTertiaryFixedVariant |
| 错误 | error / onError / errorContainer / onErrorContainer |
| Surface | surface / onSurface / surfaceDim / surfaceBright / surfaceContainerLowest / surfaceContainerLow / surfaceContainer / surfaceContainerHigh / surfaceContainerHighest / onSurfaceVariant |
| 其他 | outline / outlineVariant / shadow / scrim / inverseSurface / onInverseSurface / inversePrimary / surfaceTint |

映射 ThemeData 的 platform、fontFamily/fallback、scaffoldBackgroundColor、视觉密度与点击尺寸；密度和 tap target 需要转换为 Prism 自己的类型，不可强制 cast。主色仍由 PiliPlus 动态取色/用户主题决定。[P-THEME]、[U-COLORS]、[U-THEME]

纯黑主题保留页面黑色和现有主题生成逻辑；不要为了贴近 FlClash 擅自替换整个应用的中性色调。v1 的 `elevatedColorScheme` 明确为 null；如实际暗色 Sheet 可读性未过门槛，须更新主题决定并配套截图，再实现统一分支，不能在组件里散落提亮值。

缓存以实际颜色、字体、字重、平台、密度等输入为键。无关未读/下载更新不得创建新主题并触发整树重绘。局部深色播放器或其他 Material Theme 覆盖区若使用 Prism adapter，必须在该局部边界重新桥接颜色，不能沿用根部浅色 Prism Theme。

**临时弹层的局部主题继承也必须显式处理。** 当前Popup route在自己的 `buildPage` / `buildTransitions` 中读取颜色，showFloatingDialog也没有自动捕获调用者的InheritedTheme；只给源按钮或菜单条目包局部主题，可能得到深色文字区域配浅色玻璃底盘。[U-POPUP]、[U-ALERT]

VP-07在push前使用 `InheritedTheme.capture(from: callerContext, to: targetNavigator.context)`，传入实际目标route。捕获的主题必须包住**整个弹层内容和读取颜色的过渡/材质层**；相关颜色计算放到包装后的Builder context中，不能先用外层context算色再包装child。屏障颜色在打开时从同一源主题解析。PopupAnchor、point popup、Alert和SnapSheet都遵守此合同，不能只修菜单内部列表。

捕获到的局部颜色/字体保持本次打开时的快照，关闭再开采用新值；未被捕获的根主题仍按正常继承更新。玻璃有效模式、scene lease、MotionScope、MediaQuery/键盘/系统高对比始终从根实时订阅，不加入主题快照；弹层打开期间切Off或系统减弱动效必须立即生效。测试必须同时检查内容与玻璃底盘颜色，不能只做一张文字golden。

### 6.4 字体、字重和缩放

PiliPlus 使用 ScaledWidgetsFlutterBinding 改变 ViewConfiguration、DPR 和 pointer 坐标，根 `_builder` 同时调整 size/padding/insets/DPR。Prism 的捕获、Popup anchor 坐标和 Dock hit test 必须使用这套**已生效的逻辑坐标**，禁止再次乘 UI scale。[P-SCALE]

Measure使用VP-03读取 `MediaQuery.textScalerOf(context)`；不要重新设置App的textScaler来迎合Prism。当前应用使用用户线性文本比例，但适配接口应接受TextScaler；以后系统非线性缩放也无需重写桥接。上游Measure默认文字方向硬编码为ltr，VP-03同时改成显式 `Text.textDirection` 优先，否则使用 `Directionality.of(context)`；实际方向参与缓存失效，不能只刷新仍按ltr计算的旧逻辑。[U-MEASURE]

字重采用以下**本项目决定**：新增可空 `fontWeightOverride`。`Pref.appFontWeight == FontWeight.normal` 时传 null，保留 Prism 自己的标题/正文/强调字阶；用户选择非 normal 字重时，按现有设置的绝对 w100…w900 覆盖，不解释成增量，不改变字号与 leading。旧设置无法区分默认 w400 与主动选择 w400，因此这两者都走 null；这一限制必须记入兼容说明。[P-PREF]、[P-THEME]

`AppTextStyle.of` / `custom` 会显式设 fontWeight，仅改 ThemeData 的 base TextStyle 无效。已迁移 Alert 的显式 w500 等例外也必须经过 resolver。Measure cache 在 font/scaler/locale/direction/weight 变化时重建，避免显示已经变宽而测量仍用旧值。[U-TYPE]

### 6.5 本地化完整契约

`PiliPrismLocalizationsDelegate` 支持现有 `zh_CN` 与 `en_US`，按 languageCode 提供对应类；未知语言走现有 app fallback。保留 Material/Cupertino delegates，不替换原 locale 策略。库目前只有抽象 UiLocalizations，不能直接使用不存在的生产 delegate。[U-L10N]

| getter | 中文 | English |
|---|---|---|
| back | 返回 | Back |
| cancel | 取消 | Cancel |
| clearSearch | 清空搜索 | Clear search |
| close | 关闭 | Close |
| copy | 复制 | Copy |
| cut | 剪切 | Cut |
| dialog | 对话框 | Dialog |
| hidePassword | 隐藏密码 | Hide password |
| more | 更多 | More |
| noSearchResults | 无搜索结果 | No search results |
| paste | 粘贴 | Paste |
| reset | 重置 | Reset |
| select | 选择 | Select |
| search | 搜索 | Search |
| selectAll | 全选 | Select all |
| showLess | 收起 | Show less |
| showMore | 展开 | Show more |
| showPassword | 显示密码 | Show password |
| sort | 排序 | Sort |
| submit | 提交 | Submit |

### 6.6 ViewScope 与弹层归属

ViewScope 的 size 来自缩放后的真实约束。主布局沿用现有 `SizeExt.isPortrait`（width<600 或 height>=width）与 useSideBar 等决策；`context.isTablet` 等既有判断不得偷偷改值。将已解析的布局模式传给适配层，避免同一屏幕一部分认定手机、一部分认定桌面。[P-SIZE]、[P-NAV-V]

普通页面路由仍用 GetPageRoute；新增的 PopupRoute / DialogRoute / SnapSheetRoute 仅属于明确的临时弹层。使用 RouteAwareMixin 的完整页面不得直接搬进这些 route 而不审查订阅假设。[P-ROUTE]

所有 adapter 明确 root / nearest Navigator，保留调用点原本的归属。主路径默认跟随调用点；仅原先确为全局确认的入口使用 root。菜单关闭、SmartDialog loading、Esc 和 Android 返回键的优先级通过集成测试冻结，不靠两个组件各自抢先 pop。

## 7. 设置模型、能力检测与场景准入

### 7.1 设置与默认值

以下均为拟新增设置，使用字符串语义值，不以 enum.index 长期持久化：

| Key | 合法值 | v1 默认 | 生效方式 |
|---|---|---|---|
| `prismUiEnabled` | bool | false | 重启应用；保留原控制器生命周期 |
| `prismGlassMode` | `off / standard / ultra` | off | 热更新 |
| `prismMotionMode` | `system / reduced` | system | 热更新 |
| `prismRootTransition` | `inherit / none / fade / slide` | inherit | 重启应用 |

**发布决定：v1 为可选择启用的迁移版本，所有用户默认关闭 Prism。** 只有用户开启 `prismUiEnabled` 后采用本规范的迁移组件；玻璃仍是独立设置。P10 不得擅自把默认改为 true。将来如需默认启用，单独更新规范与回归计划。

`inherit` 保留原 `mainTabBarView` 的含义：false→无根 Tab 过渡，true→滑动。显式 fade/slide/none 只影响主导航页面呈现，不改原 `pageTransition`（Get 页面路由过渡）和 `springDescription`（原滚动物理）。

在 Prism 模式的底部导航布局中使用 Prism Dock；原 enableMYBar / floatingNavBar 值原样存储并在关闭 Prism 时恢复。侧栏模式继续用既有侧栏。设置页在 Prism 开启时应清楚显示旧底栏样式选项当前不参与渲染，不能同时展示两套互相矛盾的生效状态。

preferences 区分 `persistedPending` 与 `appliedAtStartup`：UI总开关和根过渡保存后只影响下一次启动，设置导入也不能热切 RootTabHost/controller 类型。运行时策略读取 appliedAtStartup 的 UI 状态，以及热更新的 glass/motion 值；不能直接用 pending 总开关拆装当前界面。

缺失 key 按默认解析；未知枚举或错误类型回落至安全默认并保留可诊断信息。只修复新设置的读取，不顺手重写全部历史设置。GStorage 的设置导入会先 clear 后 putAll，监听必须处理瞬时缺失和一次完整更新，不能在中间态重建导航或清掉合法用户选择。[P-STORAGE]

### 7.2 请求模式与有效模式

建议应用层使用以下概念，具体类为拟新增：

```dart
enum PrismGlassMode { off, standard, ultra }
enum PrismGlassBlockReason {
  uiDisabled, userOff, rendererUnsupported, shaderNotReady, shaderFailed,
  unsafeSurface, unsafeTransition, appNotVisible, inaccessibleContrast,
}
// 结构示意，不是上游现成 API。
class ResolvedGlassPolicy {
  final PrismGlassMode requested;
  final bool enabled;
  final LiquidGlassQuality quality;
  final Set<PrismGlassBlockReason> reasons;
}
```

解析顺序必须确定：

1. UI 总开关关闭或用户选择 Off → disabled。
2. 已知 renderer 不支持 Shader filter，或 Shader 未 ready/加载失败 → disabled，实体表面；符合 VP-04 前提时主动请求加载。
3. 有可见视频/平台视图、不安全路由过渡、应用不可见或 `MediaQuery.highContrast == true` → disabled。
4. 其余按用户选定 Standard / Ultra；quality 显式设置。高对比禁用是本项目 v1 的确定决定，不引入逐像素阈值算法。

加载尚未完成时保留可交互的实体 fallback；资源准备成功再启用，不能阻塞首屏。请求值不因临时降级被写回 Off。场景结束且能力恢复后，可按已保存的请求值恢复。

**本项目 v1 决定：非支持 renderer 使用实体 Prism 控件。** 上游可以提供不折射的 frosted fallback，但本项目不把它显示成“完整 Ultra”。设置页用简短原因说明当前效果受限；开发诊断再显示具体 renderer/Shader 信息。

### 7.3 场景租约与过渡期

`scene_controller.dart` 采用可释放的 token / lease，而不是一个容易被后关闭页面错误清除的 bool。至少支持：可见媒体表面、平台视图、进入/退出不安全页面的过渡、应用不可见。

- 同时出现两个不安全表面，释放一个不能解除另一个的抑制。
- push 到视频等页面前或其首个可见帧前，必须抑制捕获。
- pop 时直到离场动画完成且不安全表面不再绘制，才解除；不能只等 `Navigator.pop()` 发出。
- 取消返回手势时保留 lease；replace/remove 和程序化关闭也必须释放到正确状态。
- mini player、Live Photo、图库视频不依赖固定路由名；由实际表面注册。
- lease 表示表面正在或即将参与可见绘制，不表示 Player 对象存在；不能只在 initState/dispose 切换。opaque route 覆盖、Offstage、全屏容器切换、PiP 进出和保活页面都必须更新活跃状态；退出动画中的表面保持 lease。
- 应用不可见时只停止本层装饰与捕获；恢复时只撤销 appNotVisible，不解除仍有效的视频/平台视图 lease，不改变后台音频/下载生命周期。
- 现有 NavigatorObserver 继续保留；新观察器只负责场景，不成为第二套路由器。
- 根 Host 和 Scope 必须使用同一个解析结果；组件 adapter 也按同一结果决定是否创建玻璃 pane。

v1 采取保守的根级抑制：只要同一根绘制树中有可见不安全表面，根 Host 停止捕获，迁移组件用实体外观。以后若要按几何区域局部恢复，必须单独设计和验证。

### 7.4 Off 的真实含义

`LiquidGlass` 自身并不自动读取 Scope.enabled。只关 Host 不足以证明 Off；app adapter 还必须走实体 surface 路径，停止创建需要捕获的 pane。验收同时检查：无 active capture、无残留 held image、控件可读、所有交互仍然可用。[U-GLASS]、[U-CAPTURE]

本文“Off无捕获”、capture pass/snapshot/held资源均指 **LiquidGlassHost背景重放及玻璃pane资源**。PopupAnchor为普通源按钮拍摄一次source snapshot属于其原生开合机制，不计为玻璃背景捕获；Off可保留该机制，但源只能是安全的按钮子树，不包含视频/平台视图，并在关闭/取消/源销毁后释放。禁止把“背景捕获=0”扩大成删除全部原生菜单形变，或反过来借此允许对视频做快照。[U-POPUP]

Off 不关闭弹簧、按压、菜单滑选或 Switch；运动由单独的 motion policy 决定。

## 8. 玻璃材质参数与分配矩阵

### 8.1 固定规则

**最终外观由“用户质量档位 × 场景准入 × 组件原生预设 × 交互状态”共同决定。** 这里的“×”表示组合决策，不是把数值相乘。

禁止新增统一 `glassStrength=0.8` 去线性乘所有 refraction、blur、tint、dispersion。不同参数具有不同单位、符号和目的；透镜的负折射与普通表面的正折射不是可互换的强度值。

### 8.2 分场景材质与反馈

| 场景 ID | 具体位置 | 材质 | 标准反馈 | 边界 |
|---|---|---|---|---|
| GS-01 | 主悬浮 Dock 底座 | pill | Dock 原生运动 | 主玻璃载体；保持背景可滚过 |
| GS-02 | Dock 选中项抬升透镜 | lens | follow/lift/jelly/settle | 只由原生 Dock 状态机驱动 |
| GS-03 | Dock 透镜内内容 | lensContent | 与透镜连续 | Ultra 才保留完整二次 warp 路径 |
| GS-04 | 已迁移顶栏搜索/工具按钮 | regular | elastic，关闭重复 ink/tint | 不是整个顶栏背景 |
| GS-05 | 普通功能按钮 | 实体 tonal/filled/text | tint | 默认不额外变成玻璃 |
| GS-06 | 锚点操作菜单 | menu | 原生开合/滑选 | 视频等不安全背景下实体 |
| GS-07 | 普通确认与警告 | alert | 原生 Alert 路由 | 保留专用 veil/fade |
| GS-08 | 有状态语义的少量强调操作 | tinted | 按组件原生反馈 | v1 默认不扩张使用；入口须列台账 |
| GS-09 | 设置 Switch | 静止轨道实体，运动 thumb 按库实现 | toggle/press/lift | 不将整个行/轨道长期玻璃化 |
| GS-10 | 普通 SnapSheet | 实体 page/elevated surface | 拖动、吸附、滚动交接 | 不把整张 Sheet 包玻璃 |
| GS-11 | 视频卡、动态卡、评论、普通行 | 实体 card/block/inset | ink；无整卡缩放 | 不给每个 item 单独捕获 |
| GS-12 | 播放器、直播、图库视频和覆盖它的弹层 | 实体 | 保留既有反馈；安全迁移项按 policy | 根捕获抑制 |
| GS-13 | 文本编辑菜单 / Banner | v1 保留原实现 | 原行为 | 若后续迁移才使用 editMenu/banner |

参考依据是 FlClash 的真实分场景使用与表面规范，不是把全部组件统一增强。[F-PRESS]、[F-SURFACES]、[F-GLASS]、[U-SNAP]

### 8.3 预设参数完整账本

以下为上游固定值；除明确补丁外不复制为业务常量。保留“默认 + 覆盖项”的表达，以免漏列字段被误认为 0。源码：[U-GLASS]。

**共同默认值**：

| 参数 | 默认 |
|---|---:|
| contrast / blur | 0 / 2.5 |
| haze / hazeBlur | 0 / 0 |
| refraction / bevel | 60 / 20 |
| saturation / brightness | 1.5 / 1 |
| rim / rimWidth | 0.6 / 1.3 |
| rimTail / rimFocus / rimAdded | 0 / 0 / 0 |
| endShade / dispersion / rimBlur | 0 / 0 / 0 |
| hairline | 0 |
| hairlineSide | null；有效值继承 hairline |
| tint | 必填，不存在统一默认颜色 |

长度参数按库坐标使用；颜色 alpha 保留源码精度。`darkTint = scheme.surfaceContainer.shiftTone(7)`。

| 预设 | 浅色覆盖值 | 深色覆盖值 |
|---|---|---|
| regular | tint `0x8AFDFDFD`；contrast .4；saturation 2.08；rim .28；rimWidth 1.2；rimTail .17；rimFocus 1；rimAdded .38；hairline .25；hairlineSide .75 | tint darkTint alpha .62；contrast −.4；saturation 2.84；rim .28；rimWidth 1.2；rimTail .17；rimFocus 1；rimAdded .38；hairlineSide .75 |
| pill | tint `0x93F4F4F4`；contrast .4；blur 0；haze .72；hazeBlur 15.6；saturation 2.1；hairline .35 | tint darkTint alpha .48；contrast −.4；blur 0；haze .72；hazeBlur 15.6；saturation 1.925；rim .35 |
| menu | tint surfaceBright alpha .55；blur 12；saturation 2；brightness 1.1；rim 0 | tint darkTint alpha .63；contrast −.53；blur 12；saturation 1.75；brightness 1.8；rim 0 |
| alert | menu 的值，仅 blur 改为 16 | menu 的值，仅 blur 改为 16 |
| tinted | tint 输入色 alpha .82；saturation 1.2；rim .2；rimWidth 1.2；rimTail .17；rimFocus 1；rimAdded .38；hairline .34；hairlineSide .5 | tint 输入色 alpha .82；saturation 1.2；rim .14；rimWidth 1.2；rimTail .17；rimFocus 1；rimAdded .38；hairline 0；hairlineSide .73 |
| lens | transparent；blur 0；refraction −4.3；bevel 5.5；saturation 1；brightness 1；rim .6；rimWidth 1.1；endShade .045；dispersion 6.5；rimBlur 1.5；hairline .42 | 与左相同，brightness 1.33、rim .3 |
| lensContent | transparent；blur 0；refraction 14；bevel 11.2；saturation 1；brightness 1；rim 0；dispersion 3.6；rimBlur 2.5 | 与左相同，brightness 1.33 |

以下是已审查但 v1 不默认启用的预设，保留以约束后续范围扩展：

| 预设 | 浅色覆盖值 | 深色覆盖值 |
|---|---|---|
| banner | tint `0x86F9F9F9` 或 fill alpha .8；blur 0；haze .72；hazeBlur 15.6；saturation 2.1；rim/hairline 系列取 regular factory；contrast 保留默认 0 | tint surfaceContainer.shiftTone(18) alpha .42 或 fill alpha .8；blur 0；haze .72；hazeBlur 15.6；saturation 1.925；rim/hairline 系列取 regular；contrast 保留默认 0 |
| editMenu | tint `0x85FFFFFF`；blur 0；haze .71；hazeBlur 15.6；saturation 1.97；brightness .98；rim .28；rimWidth 1.2；rimTail .17；rimFocus 1；rimAdded .38；hairline .25；hairlineSide .75 | tint `0x85454545`；contrast −.33；blur 0；haze .71；hazeBlur 15.6；saturation 1.8；brightness 1.55；rim .28；rimWidth 1.2；rimTail .17；rimFocus 1；rimAdded .38；hairlineSide .75 |

Shader 会按 pane 短边限制 bevel 和正 refraction；不能把 `refraction=60` 解释为在任何尺寸都位移 60 物理像素。`LiquidGlassStyle.copyWith` 目前只接受 blur/hazeBlur；`scale(t)` 是出现/消退函数，也不是全局强度 API。[U-SHADER]、[U-GLASS]

### 8.4 Standard 与 Ultra 的准确区别

| 项目 | Standard | Ultra |
|---|---|---|
| 色散 | 有效 dispersion 置 0 | 保留原预设 |
| haze | 置 0；原先有 haze 时 blur 改用 hazeBlur | 保留 haze 混合 |
| Dock 内容透镜 | 禁用内容副本二次 warp，保留直接着色与放大副本 | 完整内容透镜路径 |
| Popup goo 轮廓采样 | 64 rays / .15 dp 容差 | 128 rays / .05 dp 容差 |
| 决策位置 | Host/组件共同处理 | Host/组件共同处理 |

这是不同渲染配方，不能描述为“Standard 50% 强度、Ultra 100% 强度”。同一 Host 的子组件不能靠嵌套不同 quality 的 Scope 获得可靠的逐组件质量隔离。[U-GLASS]、[U-CAPTURE]、[U-POPUP]、[U-GOO]

### 8.5 捕获、分组和透明度

同一个 pane 由一个 Host 管理。默认一个根 Host，不在每张卡/每个按钮外新建 Host。`LiquidGlassGroup.shared` 只用于确实同一材质层、不会互相采样的相邻 pane，shared identity 稳定；禁止把所有重叠弹层粗暴塞进同一组。

普通 Opacity/离屏合成层可能改变捕获根。迁移中的含玻璃淡出必须使用上游适当的 `LiquidGlassFade`/veil，不能用普通 Opacity 包裹后只看实体 fallback 截图就验收。[F-CAPTURE]、[U-CAPTURE]

## 9. 动效、形状、触觉与减弱动效

### 9.1 场景分配

| 场景 | 强度策略 | 禁止项 |
|---|---|---|
| 视频/动态内容卡、普通列表行 | ink，内容位置稳定 | 整卡 swell、jelly、背景捕获 |
| 普通 filled/text/icon button | tint | 无差别增加 ElasticPress |
| 顶栏浮动按钮、Dock | 原生 elastic/hover/press | 再叠一层 Material ripple 或重复缩放 |
| Popup/Alert | 原生几何与路由运动 | 用固定 scale+fade 近似替换连续手势 |
| Switch | 短暂 thumb 抬升与状态过渡 | 长期抬起、拖动时直接提交多次 |
| Sheet | 用户拖动 + 原生速度吸附 | 忽略内层滚动/键盘状态 |
| 根页面切换 | none=0ms；fade=220ms；slide=300ms；inherit按§7.1解析 | 全局给所有动画统一加时长 |

Elastic 入口使用原组件合适的 `PressLook.none`，避免双重反馈。Off 玻璃时仍执行同样的动作和反馈。[F-PRESS]

### 9.2 标准参数账本

| 对象 | 固定参数 | 说明 |
|---|---|---|
| Dock track | duration 120ms | 上游弹簧描述 |
| Dock press | mass 1、stiffness 311、ratio .593 | 按压膨胀 |
| Dock follow | mass 1、stiffness 1024、ratio .9 | 跟手 |
| Dock lift | duration 250ms | 抬升 |
| Dock travel | duration 400ms、bounce .15 | 选择移动 |
| Dock jelly | mass 1、stiffness 100、ratio .4 | 速度相关形变 |
| Dock settle | duration 500ms、bounce .32 | 释放收束 |
| Dock hover | duration 260ms、bounce .18 | 悬停 |
| Dock fade | duration 200ms | 视觉消隐 |
| Glow in/out | 100 / 500ms | 光斑变化 |
| Jelly 几何 | speed 3、stretch .2、brake 25、squash .15、aspect 1.4 | 保留因果关系 |
| Fling 投影 | 100ms；预测落点受上游限制 | 不自行无限跨项 |
| Popup open/dismiss | 450 / 500ms | 有锚点回收 |
| Point popup dismiss | 200ms | 无来源快照的收缩 |
| Popup 主弹簧 | mass 1、stiffness 400、ratio .754 | 展开 |
| Popup 形变弹簧 | stiffness 324、ratio .75 | 形状变化 |
| 子菜单展开/收起 | 420 / 340ms | 弹簧描述参数 |
| 子菜单手指停留 | 400ms | dwell 门槛 |
| Alert | route 404ms；入场 scale 1.2；内部弹簧 duration 275ms | 不是通用 500ms |
| Switch toggle/press/tap lift | 300 / 150 / 200ms | easeOutBack / easeOutCubic / timer |
| SnapSheet | route 500ms；默认 detents 9/16 与 .9 | 速度与滚动共同决定 |
| SnapSheet 物理 | normalized stiffness 1000/3，默认临界阻尼；projection .099s | 保留上游模型 |
| 根 Tab fade | 220ms、easeInOut | 借鉴 FlClash |
| 根 Tab slide | 300ms、easeOut | 借鉴 FlClash |

其中 `withDurationAndBounce` 的 duration 是弹簧描述参数，不能保证所有速度输入下运动恰好在该毫秒停止。以上多数是库内部参数，不是已存在的应用设置。[U-DOCK]、[U-POPUP]、[U-ALERT]、[U-SWITCH]、[U-SNAP]、[F-HOME]

PiliPlus 原 `springDescription` 继续服务于原滚动物理；其默认 mass=1、stiffness=438.64908449286037、damping=41.88790204786391 不改写为 Dock 的 ratio，也不被 MotionPolicy 覆盖。[P-PREF]

### 9.3 减弱动效契约

`effectiveReduced = MediaQuery.disableAnimations || userMotionMode == reduced`。系统要求优先，不提供强行覆盖系统的“完整模式”。

- Dock：按手指直接反馈位置可以保留；装饰 lift/jelly/stretch/hover magnet/glow 动画关闭；自动选择移动立即到终态。
- ElasticPress：保留点击、焦点与轻量静态按压提示，去掉形变与回弹。
- Popup/Alert：直接呈现最终几何；关闭后仍严格完成原结果分发、焦点恢复和 source 恢复。
- SnapSheet：用户拖动仍实时；释放按同样的停靠选择逻辑直接到 detent，去掉装饰性超调；不能关闭滚动。
- Switch：利用已有 motionDuration 并核查 timer、状态和取消路径；不能停在半个 toggle。
- 根 Tab：过渡时长为 0，页面身份与保活不变。
- loading、错误、禁用和选中状态仍真实可见；不能通过关整个应用 TickerMode 来实现减弱动效。

运行中改变系统/用户设置时，取消装饰 ticker、清理速度和临时 lifted/source-hidden 状态，再稳定到当前业务状态；不能冻结在半途。[U-CONTEXT]、[U-DOCK]、[U-SWITCH]

### 9.4 触觉契约

沿用 `Pref.feedBackEnable` 对应的现有开关，适配当前 `enableFeedback` 的热更新路径。关闭时 Dock/Popup 内部不得发送 selectionClick。该基线 Switch 没有直接触觉调用，保留调用点既有的反馈合同，不主动添加新震动。

上游Dock仅在 `_slide` 跨项和 `_fling` 改变落点时发送selectionClick，普通tap/reselect/keyboard/semantics激活没有该内部反馈。因此不能一律关闭MainController反馈后声称原点击触觉仍在。[U-DOCK]

采用VP-01的可选 `onActivationFeedback` hook：内部只在实际commit/reselect/键盘/语义激活且本次手势尚未实际发出跨项/fling触觉时调用一次；应用绑定原feedBack。已经有原生跨项反馈的拖动，终点不补lightImpact。pointerCancel、拖回原项且没有真正reselect均不调用activation hook；每次新的输入序列重置内部“已反馈”记录，不把上一手势状态带入下一次键盘点击。

为MainController.setIndex增加默认true的feedback参数，旧调用方默认行为不变，Dock业务回调传false以避免重复；hook与原生selectionClick都受现有触觉开关控制。标准tap/重选/键盘激活保留一次原反馈，拖动保留原跨项节奏，关闭反馈时全部为0。单次选择和重选各只触发一条业务事件，触觉hook不触发业务。[P-FEEDBACK]、[P-NAV-C]

### 9.5 几何与形状

迁移控件使用上游连续曲率；数值来自 **AppCorner**：none=0、xs=4、sm=8、md=16、lg=20、xl=24、xxl=28、alert=34、full=1000。AppRadius 提供 BorderRadius 对象，没有 `AppRadius.alert`；需要该圆角时用 `AppRadius.all(AppCorner.alert)`。AppCorner.fit 按短边/3 选择适当档位，不把所有卡片固定为 24dp。[U-SHAPE]

本规则只约束迁移组件及其新增外壳；不在同一批改动中全仓替换历史圆角。视觉变形不得改变业务 hit target 或触发重复布局。

## 10. 主导航、页面状态与安全边距

### 10.1 导航数据契约

业务身份使用 `NavigationBarType`，显示位置由 `navigationBars` 当前列表决定。保留旧 enum 顺序和存储含义；不得新增/调序 enum 导致已有 navBarSort 数据错位。[P-NAV-M]、[P-NAV-C]

| 输入 | 必须得到的结果 |
|---|---|
| 默认三项 | 首页、动态、我的按用户当前顺序呈现 |
| 排序 `[mine, home, dynamics]`，默认 home | 启动选中显示索引 1；返回首项时到 mine |
| 删除 mine | 主导航不显示；头像进入我的仍可走独立页面 |
| 删除 home | 不构造其主导航入口；动态/我的保持原业务 |
| 只保留一项 | 不创建 Dock，保留页面和适当安全区 |
| 缺失/空 navBarSort | 按现有规则回到默认列表 |
| 无效历史索引/重复项 | 由显式兼容步骤过滤无效/重复，保留合法项原相对顺序；结果空则默认列表；须写测试 |

最后一项属于保护适配入口的兼容修复，不得以此为由更改全部历史设置。默认启动项被隐藏时仍回退当前列表第一项。

三个 Glyph 在应用适配层定义，保持“首页/动态/我的”的辨识与语义。当前 Material Icon Widget 不能直接传给 Glyph 参数。不要假定上游存在对应业务 Glyph 常量；P3 必须读取当前图标来源并建立自己的 `PiliGlyphs`。

### 10.2 导航事件契约

| 事件 | 视觉状态 | 业务副作用 |
|---|---|---|
| press / hover | 原生抬升/悬停 | 无切页、无请求 |
| drag preview / 跨项 | 透镜连续跟手；按偏好触觉 | 不调用 setIndex，不清未读 |
| commit 到不同项 | 透镜收束至目标 | 只调用一次选择业务 |
| 点击当前项 / 键盘当前项激活 | 同项反馈 | 只调用一次 reselect 业务 |
| 拖走后又回到原项 | 视觉归位 | 不当作双击刷新；不得伪造 reselect |
| pointerCancel / 未确认取消 | 归回已提交项 | 零业务副作用 |
| 外部 setIndex（侧栏/返回/我的入口） | 视觉跟随权威状态 | 原有调用语义保留 |

VP-01 必须在“真正的 tap/reselect”与“拖动最终落回当前项”之间区分。键盘/语义激活与 pointer tap 走统一分发；不能因为输入设备不同而重复点击只在某平台有效。

`MainController.setIndex` 的业务顺序保留：新项先更新 selectedIndex，再呈现页面；进入 home 检查搜索词和消息，进入 dynamics 清理动态 count。当前项的重选保持既有 `toTopOrRefresh` 与 `<500ms` 二次重选 `showRefresh`、500ms throttle 规则。不可把这段逻辑重新实现到 Dock 内。[P-NAV-C]

### 10.3 未读徽标

动态徽标与顶部消息徽标分开处理：动态 number 当前使用完整 `count.toString()`，不要未经决定改成 99+；顶部消息既有 99+ 逻辑保持。

badge 在 destination 的单一前景层绘制，避免被 GlyphTint 改色或 inside/outside/lens 多份副本重复绘制。badge 自身 IgnorePointer、ExcludeSemantics，完整未读信息合并进该导航项语义节点，不能读屏两遍。

**显式兼容修复**：现有动态徽标 build 主要按 dynCount>0 判断，hidden 的查询保护并未覆盖全部状态路径。新适配器必须在 hidden 下不绘制、不读屏；已有 count→hidden、hidden 下账号切换、迟到请求返回均不得重新显示徽标。不得只依赖清零一次 count。[P-NAV-V]、[P-STYLE]

### 10.4 根页面呈现方案

**设计决定：Prism 模式使用一个轻量、按需创建且保留已访问页面的 root tab host；不复制 FlClash 的 snapshot 和临时页面重排。** 当前仅三个根业务身份，用稳定 slot 容器即可避免跨项切换时创建中间页。旧 UI 模式仍使用原 PageView/TabBarView 路径。[P-NAV-V]、[F-HOME]

拟新增 `PrismRootTabHost` 输入：当前选中 NavigationBarType、可见身份列表、各身份页面工厂、已解析过渡类型、reducedMotion 和布局方向。它只拥有呈现状态，不修改 MainController 的业务 selectedIndex。

实现契约：

1. 每个身份绑定稳定 key / slot；页面首次需要时创建，离开后保留原 State、Get controller、内层 Tab、ScrollController 和 PageStorage。
2. 不使用每次生成新 key 的 AnimatedSwitcher；不将同一个 GlobalKey 页面在两份子树间搬动。
3. 每次 selection 更新生成新的 transition generation。捕获当前归一化位置/透明度后接续到新目标；旧 completion 只允许结束自己的呈现，不能写回业务选择或覆盖新 generation。
4. A→C 不创建尚未访问的 B；快速 A→C→B 以 B 为最终目标。过渡中再次点当前目标的 reselect 仍由业务层处理，不因等待动画丢掉事件。
5. fade=220ms/easeInOut；slide=300ms/easeOut；none/reduced 立即呈现。横竖方向按现有 bottom/side 模式决定，不擅自增加根页面横滑识别。
6. 隐藏 slot 不可点击、不参与语义/焦点遍历，装饰 ticker 停止。过渡中的离场 slot 也不得继续接收业务点击。
7. 容器尺寸改变时按归一化位置重新布局，不能使用过期 viewport 像素偏移；保持同一业务身份。
8. 需要淡出的含玻璃子树采用经过验证的 LiquidGlassFade，不用普通 Opacity 截断捕获根。
9. 不对含视频/平台视图的页面做离场截图。原播放器后台播放、音频或业务计时不由 root tab host 擅自暂停。
10. MainController 原 `dynamic controller` 在 Prism 分支改为清晰的生命周期分支/typed presentation 入口；旧分支依旧正确创建和 dispose。该变更只覆盖根导航呈现，不波及 Home/Dynamics 的内部 Tab 控制器。

UI 模式与根转场设置在 v1 通过重启生效，避免热切换两套容器时丢 State；玻璃、主题、触觉和减弱动效仍必须热更新。

### 10.5 Dock 几何与内容末端留白

上游尺寸：主体 62dp，`heightOf(context)=62+textScaler.scale(10)-10`，`insetOf(context)=heightOf+max(21,padding.bottom)`，整体还包含 8dp shadow room。不能只拿 62 当所有页面的 bottom padding，也不能重复叠加系统 bottom inset。[U-DOCK]

`PiliNavigationMetrics` 至少区分：

- `visible`：是否存在并显示底部导航。
- `paintBounds`：可见材质/阴影/形变范围。
- `hitBounds`：实际交互范围，沿用上游命中逻辑。
- `systemBottomInset`：来自正确 MediaQuery。
- `contentBottomClearance`：最后一项完全露出和点击所需的留白。

MainLayout 保留 body 在下、bottomNav 覆盖在上的绘制关系，内容滚动时可以从玻璃后方经过。列表末尾应使用统一 clearance；不通过把整个 body 缩短来制造一个没有背景的底栏空区。[P-LAYOUT]

迁移前必须登记 `ViewSliverSafeArea` 默认 100、Mine bottom 150 等已有留白，逐项替换，不能在新旧 padding 上继续叠加一个 inset。侧栏、单项导航、键盘可见及隐藏底栏时按明确规则取值。[P-SAFE]、[P-MINE]

### 10.6 隐藏、横屏和返回

保留 instant 和 sync 两类底栏隐藏：原 ScrollNotification 仍为来源；Dock 内部运动不能反过来修改列表滚动。instant 的原 500ms 曲线在标准模式保留，reduced 模式立即显示/隐藏；sync 保留拖动同步比例。

Dock 完全隐藏时移除命中、焦点和读屏节点；出现过程中不扩大透明遮罩吞掉列表触摸。若手指正在拖 Dock 而布局切到侧栏或页面离开，应取消本次未提交手势并清理临时视觉。

保留 sideBar/Drawer/Rail、用户头像和搜索入口，旋转不会改选中项。根返回顺序保持原规则：directExitOnBack 开启时按原逻辑退出；否则非第一项先选择配置的第一项，并恢复上下栏，再次返回才退出。[P-NAV-V]、[P-COMMON-PAGE]

## 11. 按钮、菜单、弹窗和 Sheet

### 11.1 按钮迁移合同

按钮 adapter 不改变 onPressed 的可用条件、异步状态、tooltip、semanticLabel 与触达范围。迁移顶栏按钮时使用 Prism 自有可识别的 press 组件；只添加 ElasticPress 包住旧 Material IconButton，并不能自动获得正确的 PopupAnchor 连续手势。

不能为减少重复点击统一加 600ms loading 保留时间。FlClash 的该数字属于代理连接状态展示，视频和网络失败应继续按真实业务立即反馈。[F-STATUS]

### 11.2 菜单类型必须登记

每个入口在 surface_inventory 中标记为：

| 类型 | 触发 | 选择/关闭时点 |
|---|---|---|
| `controlAnchor` | 更多按钮、设置选择按钮 | 可用按下滑选；有 source 回收，原生 action 在 route.completed 后 |
| `longPressContext` | 既有长按内容项 | 保留长按门槛，不能变成 pointerDown |
| `pointContext` | 既有鼠标右键/指定坐标 | 原生 point action 可立即执行；应用适配按下文整理后续路由动作 |

`PopupAnchor._targetEnabled` 仅识别 Prism PressSurface / PressRegion 等目标链路；正式 controlAnchor 使用 Prism target。旧 Material 按钮的包装负例必须写测试，防止只测试鼠标 click 却漏掉触摸滑选。[U-POPUP]

### 11.3 菜单动作模型

建议新增独立于 UI Widget 的 typed action/choice 描述，字段包括稳定 id、label、icon/Glyph、enabled、checked、destructive、业务 payload 和执行器。具体模型类型是应用层新契约，不把 Material PopupMenuEntry 强转为 Prism 条目。

所有 action 捕获稳定内容身份（如原视频 bvid/cid/对象快照），不能在菜单关闭后用“当前列表 index”重新取对象。hover、滑过、取消、移出有效区域均不执行业务。

维护两类 Future：`closed` 表示弹层完全关闭，`actionCompleted` 表示业务异步结束；二者不能合并。锚点菜单在回收后执行一次。point 菜单保留原生选择时点，但如果选中动作会开新 route/dialog，adapter 必须先完成旧菜单关闭再打开新层，避免 `Get.back()` 关闭错误对象。纯操作仍以原业务明确时点执行，不人为延迟网络结果。

异步执行器不得依赖已销毁的来源 BuildContext；通过已验证的 Navigator/service 或有效的新上下文操作。不得捕获页面 State 后在 dispose 后 setState。重复点击、快关快开、系统返回、anchor 被列表回收，都必须满足 action 至多一次。[U-POPUP]、[F-POPUP-TEST]

### 11.4 VideoPopupMenu 的完整业务保留

迁移 `lib/common/widgets/video_popup_menu.dart` 时保留其基于视频类型、bvid/cid、登录态、AI 开关等生成的可见项与校验。逐项覆盖复制 BV、稍后再看、AI 总结、访问 UP、不感兴趣/反馈、本地屏蔽、远端拉黑和无痕等现有动作。[P-VIDEO-MENU]

网络型动作成功之前不调用 `onRemove`；取消零请求，失败保留卡片并沿用原提示。本地屏蔽等无网络分支继续在原本地操作成功后立即 `onRemove`，不能为统一时序给它增加网络依赖。需要二次确认/嵌套弹窗的动作先收好菜单。对缺少 bvid/cid、游客、不同模型类型和菜单打开后列表刷新分别测试。

### 11.5 PopupListTile 的选择合同

保留泛型 T 与原 `value()` / `onSelected(T,setState)` 的含义；逐调用点转换为 PrismChoice，旧 PopupListTile 作为 fallback，不全局破坏其 Material itemBuilder API。[P-POPUP-ITEM]

- null 表示取消；不能转换为 false 或第一个值。
- 选择当前值不写设置、不弹重启提示、不调用业务 onSelected。
- mounted 检查和“业务完成后刷新”的时序保留。
- 原 requestFocus:false、移动/桌面锚点差异需在 adapter 中明确；普通设置菜单不得无故关闭当前输入键盘。
- 长中文、英文、大字、图标缺失、disabled 与 checked 状态完整。

### 11.6 普通确认弹窗

优先迁移 `showConfirmDialog` 能表达的文本确认。保持 `Future<bool>`：确认 true，取消/返回/barrier/null 为 false；原可选 onConfirm 与 await 结果不得造成业务调用两次。[P-DIALOG]

Prism Alert 有 default/destructive/action 排序语义；显式映射确认和取消，不把原 actions 列表位置直接等同于危险程度。不可取消弹窗继续不可通过 barrier 取消；Esc、返回、焦点恢复符合原合同。

复杂输入、多步骤表单、投币/付款、登录验证码等先保留现有 Dialog 并登记。不能为了全量替换，把任意复杂 Widget 强塞标准 Alert。

### 11.7 设置 Switch

`SetSwitchItem.switchChange` 是开关值变更的唯一业务入口：计算目标值 → 必要确认 → 持久化 → onChanged → 重启提示 → 更新界面。Prism Switch 只负责呈现和用户目标值。**onTap==null** 的普通项，整行与 Switch 本体复用一次分发；**onTap!=null** 的项，整行继续打开独立设置详情，其 enabled 依赖当前 val，Switch 本体仍可切换。`isSplit` 保留详情区与开关区的独立命中，不能因 val=false 一并禁用 Switch。[P-SWITCH-ITEM]

为一次未完成的确认/保存设置 busy gate；拒绝确认或存储失败时保持最后已确认值。允许短暂的按压反馈，不允许 UI 永久显示一个未保存的开关状态。保存异常沿用错误反馈，不吞异常后宣称成功。

### 11.8 三类 Sheet 的确定路线

| 类别 | 当前语义 | v1 决定 |
|---|---|---|
| 普通 modal，如收藏面板 | modal barrier、Future 结果、外部 ScrollController、明确初始高度 | 可逐个迁移；具体 detent 和控制器合同单独锁定 |
| MiniScaffold persistent | PersistentBottomSheetController、LocalHistoryEntry、局部覆盖、默认顶部45dp拖动区 | 保留；不得直接换成 SnapSheetRoute |
| 视频 PublishRoute | 竖屏底部高70%；横屏右侧宽50%、最大500dp；350ms easeInOut | 保留；不得统一成底部弹层 |

来源：[P-MINI]、[P-SHEET]、[P-PAGE-UTILS]、[P-PUBLISH]。

P7 的生产试点选定为**音频页面的收藏面板**（`pages/audio/controller.dart` 的 showFavBottomSheet → PageUtils），复用 FavPanel 业务和外部 controller；游客与 enableQuickFav 的点击/长按分流保持。视频场景调用同一收藏能力仍走原实现。PageUtils入口当前为void，收藏结果由原controller/回调维护，不能凭空要求它返回新的泛型结果。[P-AUDIO-C]、[P-FAV]

试点的尺寸合同固定如下，不留给实现者临时选择：

1. 每次打开时，沿用 `PlatformUtils.isMobile && !context.mediaQuerySize.isPortrait` 判断移动横屏；这里的isPortrait是项目§6.6的判定，不替换成Flutter Orientation。普通情况detents为升序 `[.7, 1.0]`，从第0档打开；移动横屏为 `[1.0]`。[P-PAGE-UTILS]、[P-SIZE]
2. 上游 `_SheetModel._peak` 固定减去10dp，直接传detent=1仍达不到完整可用高度；实施VP-06，音频收藏实例设 `topPeek=0`，其余实例保持默认10dp。这里1.0指完成安全区处理后的可用高度，不要求覆盖系统状态栏。[U-SNAP]
3. 应用层继承公开SnapSheetRoute，在 `buildPage` 用LayoutBuilder/底部居中Align/ConstrainedBox约束**整个 `super.buildPage` 返回的Sheet视口**，宽度不超过 `min(640, currentShortestSide, availableWidth)`，高度仍给完整可用约束；只包FavPanel无效，因为上游render viewport会向内容下发满宽约束。modal barrier仍覆盖完整路由区域，不跟着缩窄。[U-SNAP]
4. 同一次打开中冻结detents列表。旋转/resize只重算可用高度和宽度，保留同一路由、FavPanel及ScrollController；静止/吸附阶段保留stop身份，拖动中的resize沿用上游约束重算和取消规则。关闭再开才按新方向选detents。这是明确的新稳定交互合同，不声称与旧DraggableScrollableSheet所有中间态逐帧相同。

**收藏确认的关闭权仍在业务控制器。** `FavMixin.actionFavVideo` 显示SmartDialog loading并请求；成功后由其现有 `Get.back()` 关闭面板、更新收藏状态和toast，失败保留面板。Sheet adapter不能在同一次确认时再pop或自动complete，必须验证成功只关一层、失败不丢选择。[P-COMMON-INTRO]

“新建收藏夹”仍通过 `Get.toNamed('/createFav')` 打开完整页面；返回FavFolderInfo后，FavPanel保留已有选择并按原逻辑插入新文件夹、设favState=1及mediaCount=1。它不是Sheet内新增输入框；键盘测试必须覆盖该完整页面与返回路径，不能用虚构的内联表单替代。[P-FAV]

以上已知API缺口由VP-06和应用route子类解决；若实际验证仍失败，G7保持阻塞，按变更控制记录证据与修正。不得改成仅预览页演示就勾完生产试点。

一般新 Prism Sheet 可采用原生默认 `[9/16, .9]`；迁移已有 Sheet 时以原业务尺寸合同为准。容器使用实体 page/elevated surface，玻璃不是 SnapSheet 迁移目标。[U-SNAP]

### 11.9 Sheet 滚动、键盘和结果

- builder 提供的 ScrollController / PrimaryScrollController 必须与内容实际 Scrollable 对接；一个 controller 不同时 attach 多个无关列表。
- 向上先扩展 Sheet，到最大 detent 后交给内容滚动。
- 向下拖动只有手势开始时内容已在顶部，才按上游规则驱动 Sheet；从中间滚到顶部的同一手势不得突然把面板拖走。
- 键盘 insets 变化、旋转、窗口 resize、拖动中程序 pop 均不得重复 complete/dispose。
- 原本有泛型结果的Sheet保留取消null/确认结果合同，dismiss不再覆盖结果；音频收藏仍按上述void入口与业务控制器负责关闭，不新增第二套结果分发。
- 不将包含 RouteAwareMixin 的完整业务页面直接当 Sheet 内容而触发 GetPageRoute 强转问题。

## 12. 播放器、直播、图片查看器与平台边界

### 12.1 已证实与待证实的区别

已证实：Prism `_Replay._walk` 没有视频 TextureLayer / PlatformViewLayer 分支。PiliPlus 的 SimpleVideo 来自锁定的 media_kit_video fork，放在 FittedBox、Transform、RepaintBoundary 等节点下。[U-CAPTURE]、[P-PLAYER-V]

尚待核对：每个平台、硬解/软解与 PiP 模式下锁定依赖到底产出哪些 layer、实际 native compositor 如何呈现，以及任何局部隔离是否足够。P0/P8 必须读取锁定依赖并实测，不能把“RepaintBoundary 包住视频”误当为普通 PictureLayer 或可安全截图的证据。

### 12.2 捕获禁区清单

| 表面 | 核对入口 | 必须覆盖的变化 |
|---|---|---|
| 视频详情播放器 | `plugin/pl_player/view/view.dart`、`pages/video/view.dart` | 播放/暂停、缓冲、切集、全屏/退出、缩放 |
| 直播 | `pages/live_room/view.dart` | 直播中、重连、弹幕、控制栏、PiP |
| 图库视频/Live Photo | `common/widgets/image_viewer/gallery_viewer.dart` | 静态图切视频、视频切静态图、切页、关闭 |
| Mini/desktop PiP | 原播放器与窗口控制路径 | 切换容器、前后台、原窗口恢复 |
| WebView/验证码/其他 platform view | P0 台账补全 | show/hide、打开弹层、路由过渡 |

视频暂停仍是视频表面，不能当成普通静态图取消抑制。只把播放器按钮设为实体也不够；其上方出现的菜单、Alert、Sheet 必须继承同样的捕获禁用结果。

### 12.3 播放业务与输入零回归

主题、质量、导航视觉、菜单开关不得重建 VideoController/Player、重新解析播放地址、改变 decoder 配置或重置播放位置。原音频后台服务、媒体控制、心跳、字幕与弹幕时间基准保持。

必须测试横滑 seek/取消、左右亮度/音量、中部全屏手势、长按倍速、双击分区、双指缩放、弹幕点选、锁屏、键盘 PlayerFocus、鼠标点击/双击/滚轮。任何 Prism 控件只在自己的热区参与竞技场。[P-PLAYER-V]、[P-PLAYER-C]

返回优先级保留：先解除 controlsLock，再退出 desktop PiP，再退出全屏，最后页面返回。页面 didPushNext/didPopNext 对播放、监听、亮度与心跳的处理不被弹层开合误触发。[P-VIDEO-V]、[P-PLAYER-C]

### 12.4 平台支持策略

| 平台/能力 | v1 策略 | 开放条件 |
|---|---|---|
| Android，Shader filter 支持且已实测 | 安全场景可 Standard/Ultra | 真实设备视觉和性能门槛 |
| Android，fallback renderer/资源失败 | 实体 Prism | 不按平台名假定支持 |
| iOS | 保留业务与构建；通过设备门槛后可声明折射支持 | 键盘、返回、PiP、真机 Shader |
| Windows | 保留现有 Impeller Disabled；实体 Prism | 另立 renderer 升级任务，本轮不改 |
| Linux | 保留现有 Impeller FALSE；实体 Prism | 同上 |
| macOS | 按本项目实际 renderer 能力和设备证据 | 不复制 FlClash 的架构差异假设 |
| Web | 不纳入本项目 v1 构建目标 | 本次是现有 Flutter 应用移植 |

Windows/Linux 当前限制来自 PiliPlus 自己的入口，不是依据 FlClash 推测。[P-WIN]、[P-LINUX] 不得因为升级到“看起来更新”的 SDK 就自动删除这些开关。

## 13. 需求追踪与阶段依赖

### 13.1 需求编号

| 需求 ID | 可验收要求 | 主阶段 | 主要证据 |
|---|---|---|---|
| R01 | 完整 SHA、SDK、补丁与 lockfile 可重现 | P0/P1 | 基线清单、构建日志 |
| R02 | 最小 vendor 补丁可审查与升级 | P1/P7 | UPSTREAM/PATCHES、差异与测试 |
| R03 | 原根 App/路由/播放器身份保持 | P1/P8 | 混合环境集成用例 |
| R04 | 颜色/字体/纯黑/缩放正确 | P1/P9 | 主题映射测试、截图 |
| R05 | 本地化/Measure/ViewScope 无缺项 | P1 | 混合 App smoke test |
| R06 | 设置持久化、未知值、导入恢复正确 | P2 | settings 测试 |
| R07 | Off 无玻璃背景捕获且原生交互保持 | P2/P9 | 有效capture counters、交互录像 |
| R08 | 质量/材质/运动分开，参数不漂移 | P2/P9 | 策略映射、上游差异审查 |
| R09 | 视频/平台表面与过渡完整抑制捕获 | P2/P8 | lease 测试、实机路径 |
| R10 | 导航排序/删除/单项/启动页正确 | P3 | 参数化导航用例 |
| R11 | 选择/重选/取消/双击事件准确 | P3 | 回调/请求次数断言 |
| R12 | 徽标和触觉偏好准确 | P3/P9 | 状态矩阵、haptic mock |
| R13 | 主页面保活和中断过渡正确 | P4 | State/scroll/controller 身份断言 |
| R14 | 底部留白、隐藏、侧栏与返回正确 | P3/P4 | hit-test、尺寸与设备用例 |
| R15 | 内容/按钮反馈按场景分配 | P5 | 台账、press/scroll 用例 |
| R16 | 菜单原生连续手势与业务 exactly-once | P5 | anchor/point/longPress 用例 |
| R17 | PopupListTile 类型/取消/同值合同保留 | P5 | T 泛型与写入次数断言 |
| R18 | Alert/Switch 结果和确认/保存合同保留 | P6 | 结果、拒绝、失败测试 |
| R19 | 普通 Sheet 滚动/键盘/结果正确 | P7 | 控制器和操作序列 |
| R20 | 两类播放器专用 Sheet 保持 | P7/P8 | 返回栈和横屏侧栏录像 |
| R21 | 视频/直播/图库/PiP/后台零回归 | P8 | 媒体用例表 |
| R22 | 减弱动效/读屏/键盘可用 | P1/P9 | 运行时切换、语义树 |
| R23 | 真实帧预算与资源释放有证据 | P9 | profile/设备数据 |
| R24 | 各平台构建和降级真实标注 | P10 | artifact 与支持表 |
| R25 | 回退可用、范围闭环、交接可继续 | P10 | TODO台账、回退演练 |

### 13.2 阶段顺序

P0 → P1 → P2 → P3 → P4 构成首个可运行导航里程碑。P5、P6、P7 必须在共同基础稳定后依次合入；可并行开发独立 adapter，但不能并行改同一个 vendor motion/route 文件而不协调。P8 完成媒体全路径验证，P9 性能与无障碍，P10 发布准备。

**媒体的保守捕获抑制必须在 P2 就存在。P8 是完整回归与硬化，不是到那时才第一次保护视频。** 同样，减弱动效的基础补丁在 P1/P2 完成，P9 负责全覆盖复核。

每个阶段有单独 gate。未过 gate 可以继续做不依赖它的研究/测试准备，不能把依赖该能力的功能标成完成或扩大默认启用范围。

**2026-11-13 实施顺序例外（用户明确批准）**：允许先在独立开发分支实施 P1 与不依赖未完成设备台账的代码，但保持 G0 标记未通过，P1 功能不可默认启用未验证玻璃；所有 P1/P2/P3 的验收 Gate、业务合同、设备性能门槛与回退要求保持不变。详见 §0 变更记录。

## 14. P0—P10 详细开发 TODO

### P0 — 冻结基线、重现工具链和建立行为台账

**目标**：先证明原应用可构建，并记录需要保留的行为；避免把原问题、环境问题、迁移回归混在一起。

**输入**：本文固定提交、现有构建脚本和 lockfile。  
**允许改动**：`docs/prism/`、必要的独立验证 workflow；此阶段不改产品 UI。  
**输出**：baseline.md、surface_inventory.md、初始测试/设备矩阵、可重现的原版构建。

- [ ] **P0-01** 记录三个完整 SHA、FlClash submodule SHA、工作分支 base，确认不存在未保存用户改动。
- [x] **P0-02** 保存 SDK 3.47.9 的 `flutter --version`、Dart、engine revision；不以本机“最新 stable”替代。
- [x] **P0-03** 审核 `patch.ps1` 的 Flutter/material_ui/cupertino_ui 修改范围，在专属 SDK 与 PUB_CACHE 下执行原平台流程。
- [ ] **P0-04** 记录每项 patch 是否应用及失败原因；建立已打补丁的环境标记，避免缓存命中后重复 apply。
- [x] **P0-05** 对照 `pubspec.lock` 的 Git resolved-ref；读取锁定 media_kit_video 的平台 renderer 实现，形成媒体 layer 风险表。
- [x] **P0-06** 在未接入 Prism 的基线上运行现有 analyze/test 与 Android dev 构建，保存现存失败/警告清单及完整命令。
- [x] **P0-07** 验证当前 workflow 的触发方式；现有 build.yml 的 pull_request 被注释，不把“创建 PR”当自动构建已执行。
- [x] **P0-08** 建立仅验证的 CI：pin SDK、应用补丁、依赖、analyze、tests、dev artifact；不使用 release tag，不需要发行签名，不触发发布。
- [ ] **P0-09** 用 rg 清点菜单、Dialog、Switch、modal/persistent/video-side Sheet、视频/平台视图入口，登记路径、触发、返回值、Navigator、滚动所有者。
- [ ] **P0-10** 为每个入口分配稳定台账 ID 和迁移阶段；v1 保留项必须注明理由及业务合同，不能只写“以后再说”。
- [ ] **P0-11** 录制默认/自定义顺序、单项导航、重选、双击、返回首项、底栏隐藏、侧栏、未读的原版基线。
- [ ] **P0-12** 记录视频/直播/图库、全屏/PiP、专用 Sheet 和返回键的原版操作序列。
- [ ] **P0-13** 保存浅/深/纯黑、动态色、自定义字体/字重、UI缩放/大字、横竖屏的基线截图；测试资源不含个人账号信息。
- [ ] **P0-14** 在至少一台 Android 真机测原版列表、菜单、根切页和播放的 profile 基线，记录设备、刷新率、renderer、温度条件，以及采集器/计算脚本版本、窗口与分母定义。

**Gate G0**：原版在记录的隔离环境可重现构建；已有失败被分离记录；入口台账覆盖本次迁移区域。若原版失败，先明确原因，不允许靠升级全量依赖掩盖。

**回退**：只移除验证设施即可回到原基线；产品源码没有被改变。

### P1 — 引入受控 Prism、必要 API 与混合环境桥接

**目标**：完整建立组件能运行的环境，同时原界面保持默认关闭 Prism。  
**前置**：G0。  
**主要文件**：pubspec/lock、packages/prism_ui、main.dart、lib/prism 的 bridge/theme/localizations、相关 tests。

- [ ] **P1-01** 按固定 SHA 引入包，保留源码、Shader、生成文件、LICENSE、NOTICE 和适用测试；写 UPSTREAM.md。
- [ ] **P1-02** 建立 PATCHES.md，每项 VP 编号列出目的、文件、测试与未来移除条件；正常参数变化为零。
- [ ] **P1-03** 使用 path dependency，核对包资源路径和依赖求解差异；拒绝无关 resolved-ref 漂移。
- [ ] **P1-04** 实施VP-01的onReselected、onActivationFeedback、单层badge与语义入口；包级证明各输入分发一致，tap反馈保留、已跨项反馈不在终点叠加。
- [ ] **P1-05** 实施 VP-02 的窄 motion scope，接通 Dock/ElasticPress/Popup/Alert/SnapSheet 的 reduced 路径与内部触觉 gating。
- [ ] **P1-06** 证明标准 motion path 与上游参数/算法一致；reduced 运行时切换能够清理 ticker、source snapshot、lifted 状态。
- [ ] **P1-07** 实施VP-03，Measure接受实际TextScaler，显式Text方向优先、默认跟随Directionality并失效缓存；旧构造保留兼容。
- [ ] **P1-08** 实施 VP-04 的幂等ensureLoaded、有限状态与可控profile数值计数；测试无pane能加载、加载中切Off、失败终态，profile计数有效且诊断不持有图像，首屏不阻塞。
- [ ] **P1-09** 实施 VP-05 的 nullable 绝对 fontWeightOverride 和统一 resolver，核对 Alert 的显式 w500 等覆盖点。
- [ ] **P1-10** 逐字段实现 ColorScheme/ThemeData 映射，缓存真实输入；恢复旧界面的 IconTheme，不改 Material 主主题。
- [ ] **P1-11** 实现 UiLocalizations 20 字段与 delegate，加入现有 delegates，测试中文/英文及 fallback。
- [ ] **P1-12** 在已缩放 MediaQuery 下安装 MeasureScope/ViewScope/MotionScope，采用统一布局模式；无重复 textScale。
- [ ] **P1-13** 将唯一 Host 放在 SmartDialog 整体输出外，保留原 Navigator key、observers、BackDetector 与系统栏逻辑。
- [ ] **P1-14** 在混合 GetMaterialApp harness 中打开 Prism Popup/Alert/Sheet，验证本地化、measure、Overlay、焦点与返回，不只跑上游 PrismApp 测试。
- [ ] **P1-15** 确认玻璃、主题、用户缩放变化不重建 Navigator/业务控制器；局部主题覆盖存在正确桥接路径。
- [ ] **P1-16** 完成包级 analyze/test、应用新增测试与 Android 构建；保存固定环境下的证据。
- [ ] **P1-17** 实施VP-07的源→目标Navigator主题捕获，将整层内容/过渡的颜色计算置于正确context；混合根浅/局部深主题下验证Popup/Alert/Sheet，并在打开期间切Off/reduced。

**Gate G1**：混合环境可构建；所有必需 inherited scope/delegate 完整；原 UI 默认路径无可见/业务回归；必要补丁逐项有测试。Shader 真机表现留给 G2/G9，不将 widget smoke 当真折射证明。

**回退**：移除 main.dart 的桥接和依赖接入即可回到 G0；回退不得删用户存储。

### P2 — 设置、材质策略、媒体抑制与真实预览

**目标**：所有视觉效果都受统一策略控制，有明确 Off 和失败路径。  
**前置**：G1。  
**主要文件**：preferences、glass_policy、motion_policy、scene_controller、storage_key/storage_pref、style_settings、debug/gallery；必要媒体表面注册点。

- [ ] **P2-01** 增加四项新设置，采用本文默认和字符串枚举；实现缺失/未知/错误类型的解析。
- [ ] **P2-02** 通过原 GStorage 体系持久化，不创建平行数据库；处理 clear→putAll 的设置导入过程。
- [ ] **P2-03** 设置页区分 UI 总开关、玻璃质量、减弱动效和主 Tab 过渡；明确热更新/重启生效。
- [ ] **P2-04** 写出请求模式→有效模式的纯决策逻辑与原因集合，显式传 quality，不使用 Scope 的 Ultra 默认。
- [ ] **P2-05** 读取真实 Shader filter 能力与加载状态；失败/不支持时实体 fallback，不改写用户保存的请求档位。
- [ ] **P2-06** 实现可重入/可释放 scene lease；两个表面同时存在时不会因先释放一个而恢复捕获。
- [ ] **P2-07** 给视频详情、直播、图库视频和既有 platform-view 入口安装保守抑制；包括暂停和过渡，不能只匹配路由名。
- [ ] **P2-08** 新 NavigatorObserver 覆盖 push/pop/replace/remove、取消返回和 route.completed；保留现有 observers 的行为。
- [ ] **P2-09** 确保 Host/Scope/adapter 共享同一解析结果；Off 没有新增玻璃 pane，无捕获和残留 image 引用。
- [ ] **P2-10** 建立 GS-01…GS-13 材质/反馈映射，所有业务入口通过角色选择，不直接手写折射值。
- [ ] **P2-11** 系统 disableAnimations 与用户 reduced 合并；旧触觉开关能热更新到全部 Prism 内部反馈路径。
- [ ] **P2-12** 完成真实交互预览页：浅/深/纯黑、Off/Standard/Ultra、Dock/菜单/Alert/Switch/Sheet、长文和缩放。
- [ ] **P2-13** 预览使用有纹理的滚动背景和移动图形，验证折射而不只 tint；静态截图不得冒充 Standard/Ultra 差异证据。
- [ ] **P2-14** 在真实支持 renderer 的 Android 设备观察 Standard/Ultra，记录 shader ready、实际折射、模式切换和失败 fallback。
- [ ] **P2-15** 验证进入/退出视频、打开覆盖视频的菜单/Alert、图库切媒体类型时捕获抑制不闪漏；操作仍可用。
- [ ] **P2-16** 在设置导入、进程重启、系统主题/减弱动效变化后复查有效策略；debug 入口不泄露到普通用户关键流程。

**Gate G2**：Off/失败/不安全表面都能够稳定实体化；安全 Android 路径有真实折射证据；所有场景策略可追踪。未知 renderer 路径保持未支持，不能以强制开启跳过 gate。

**回退**：关闭 prismUiEnabled 并重启恢复原 UI；仅关闭玻璃时保留 Prism 形状/交互。验证这两种回退各自有效。

### P3 — 主导航 Dock 与完整业务兼容

**目标**：首个生产入口同时证明材质、手势、业务与布局正确。  
**前置**：G2。  
**主要文件**：main/view.dart、main/controller.dart、navigation_adapter、pili_glyphs、navigation_metrics、view_sliver_safe_area、mine/view 的明确相关留白；如需调整其他SafeArea调用点，逐项写入台账。

- [ ] **P3-01** 建立 NavigationBarType→Glyph/label/semantic identity 映射，保留原 enum 和旧配置索引。
- [ ] **P3-02** adapter 接收真实排序/可见列表，覆盖空、1、2、3项及非法历史值；1项不构造 Dock。
- [ ] **P3-03** 接入 VP-01，将 commit 和 reselect 分开；touch/keyboard/semantics 走统一分发。
- [ ] **P3-04** 证明 drag preview/crossing 不调用 setIndex、不发请求、不清未读；cancel 和拖回原项不刷新。
- [ ] **P3-05** 保留当前项单次回顶/刷新、500ms 双击/throttle、mine 无刷新语义。
- [ ] **P3-06** 保留新项 home/dynamics 的副作用、toMinePage 和隐藏 mine 后的独立入口。
- [ ] **P3-07** Dock绑定onActivationFeedback到原feedBack，业务setIndex(feedback:false)；tap/重选/键盘各保留一次反馈，跨项后的提交不追加，取消/拖回不误激活，全局关闭内外部均0。
- [ ] **P3-08** 动态 dot/number/hidden 显示与语义完整，保持动态数字原格式；同一 badge 不被复制进三份透镜内容。
- [ ] **P3-09** 显式修复 hidden 后旧 count/账号切换/迟到请求造成的徽标复现，写为关联兼容修复。
- [ ] **P3-10** 明确 Prism/旧 floating/MD3/传统底栏的渲染优先级；关闭 Prism 后旧偏好完全恢复。
- [ ] **P3-11** 保留 MainLayout 绘制和命中顺序，按真实 Dock 尺寸生成 metrics；保留可滚过的背景。
- [ ] **P3-12** 对首页/动态/我的及共用 SafeArea 消除重复 bottom inset，验证末项完整显示与点击。
- [ ] **P3-13** 保留 instant/sync 隐藏；隐藏后无命中/读屏/焦点；reduced 模式没有残留移动。
- [ ] **P3-14** 保留侧栏/Drawer/Rail、tablet 优化、用户搜索区域；旋转和 resize 保持选中身份。
- [ ] **P3-15** 返回键回到当前配置首项并恢复栏状态；directExitOnBack 和 macOS Meta+R 不变。
- [ ] **P3-16** 在 UI scale、文本 1.0/1.3/2.0、中文/英文、手势/三键导航下验证 label、badge、hit target 和安全区。
- [ ] **P3-17** 快速点按、拖动、fling、第二指/取消、选择中旋转各有一次性事件和最终状态断言。
- [ ] **P3-18** 记录生产导航的 Off/Standard/Ultra 录像与局部重绘数据，确认没有每帧重建根业务页面。

**Gate G3**：导航业务矩阵全部通过；Dock 可读、跟手、可取消；原配置和返回行为保留。只实现透镜外观不能过 gate。

**回退**：恢复旧 _bottomNav 分支即可；vendor 保留供后续测试，用户配置不迁移成不可逆格式。

### P4 — 主 Tab 过渡、保活与最新意图协调

**目标**：导航透镜与页面呈现协调，且用户状态不丢失。  
**前置**：G3。  
**主要文件**：root_tab_host、main/controller/view、相关 activity/focus 包装；不修改业务请求层。

- [ ] **P4-01** 实现 inherit/none/fade/slide 的明确映射，保持 pageTransition 和 springDescription 独立。
- [ ] **P4-02** 以 NavigationBarType 创建稳定 lazy-retained slot；只在首次访问时创建页面，不重建 Get controller。
- [ ] **P4-03** 将 MainController 的业务选择与视觉呈现解耦；Prism host 不回写业务 selectedIndex。
- [ ] **P4-04** generation 控制过渡完成回调；新的目标可中断旧目标，旧回调不得回滚位置或状态。
- [ ] **P4-05** 新过渡从当前视觉状态接续，快速 A→C→B 无瞬间跳回起点；最终页/透镜/业务身份一致。
- [ ] **P4-06** A→C 不创建未访问 B；已访问页面保持内层 Tab、列表、滚动和搜索状态。
- [ ] **P4-07** 隐藏/离场页正确 IgnorePointer、ExcludeFocus、ExcludeSemantics，装饰 ticker 不持续运行。
- [ ] **P4-08** fade 使用适合玻璃的绘制路径，确认没有透明度离屏层截断背景；不引入视频 snapshot。
- [ ] **P4-09** 主页面仍禁止横向自由滑页；Home/Dynamics 内层手势与滚动物理完整。
- [ ] **P4-10** 旋转、resize、切布局、关闭/开启 reduced 中断过渡时按稳定身份落位。
- [ ] **P4-11** 同项刷新在过渡期间仍按业务合同分发，动画未完成不吞用户动作、不重复请求。
- [ ] **P4-12** 旧 PageController/TabController 分支和 Prism 分支的创建/dispose 都只发生一次，没有未挂载调用或 ticker 泄漏。
- [ ] **P4-13** 用真实长列表验证切页期间 build/repaint 和首次访问成本，并保存状态身份/scroll position 的回归结果。

**Gate G4**：稳定状态、快速中断和布局变化均正确；根导航首个完整里程碑可交付内部体验，但仍未宣称全部组件迁移完成。

**回退**：Prism Dock 可继续使用，主页面回退原容器/原过渡；不能为了回退清空页面业务缓存。

### P5 — 顶栏操作、按钮反馈和菜单

**目标**：迁移高频操作入口，保持手势与动作语义。  
**前置**：G4；菜单公共基础至少依赖 G2。  
**主要文件**：action_button/popup_menu adapter、video_popup_menu、setting/widgets/popup_item，以及台账明确列出的首页搜索/顶栏入口。

- [ ] **P5-01** 冻结本阶段生产入口：首页搜索与更多操作、设置选择菜单、视频卡 VideoPopupMenu；列出确切调用文件和台账 ID。
- [ ] **P5-02** 将内容行/普通按钮/浮动操作分别映射 ink/tint/elastic，禁止整卡套弹性或每卡玻璃。
- [ ] **P5-03** 保留每个按钮 onPressed=null、busy、tooltip、语义、尺寸与触觉合同；elastic 入口关闭重复 press visual。
- [ ] **P5-04** 为 controlAnchor 使用 Prism PressSurface/PressRegion 可识别目标，测试连续 pointerDown→滑选→松手；保留 Material 包装失效的负例。
- [ ] **P5-05** 建立 typed action/choice 模型，按稳定 id/value 生成条目；不从显示文本推断业务，不强转 Material PopupMenuEntry。
- [ ] **P5-06** 保留 longPressContext 原门槛与 pointContext 原入口，禁止所有菜单改为按下立即弹出。
- [ ] **P5-07** controlAnchor action 只在收回完成后执行；point 菜单会开新层的动作先确认旧层关闭，分别测试时序。
- [ ] **P5-08** 完成 exactly-once 分发与关闭/业务完成 Future 的区分；cancel、移出有效行、源销毁均无误调用。
- [ ] **P5-09** VideoPopupMenu 复用原项条件和闭包，覆盖 bvid/cid缺失、游客、AI关闭和不同模型类型。
- [ ] **P5-10** 稍后看/屏蔽/反馈/拉黑等保持成功/失败/二次确认路径；网络型成功后onRemove，本地屏蔽保持本地成功即移除，不新增网络等待。
- [ ] **P5-11** 来源视频 identity 在菜单打开时固定，列表刷新/重排后不会操作另一条内容；异步完成不访问失效 State。
- [ ] **P5-12** PopupListTile 逐点适配 T 类型，null与同值不写存储，保持保存后刷新、requestFocus与IME行为。
- [ ] **P5-13** 检查可滚动列表的竞技场：纵向滑动优先、长菜单可滚、原地抬手不误选、越界释放不提交。
- [ ] **P5-14** 处理 submenu、disabled、checked、destructive、长文与超屏布局；返回一层/关闭全部按组件和调用点合同分别验证。
- [ ] **P5-15** 菜单在根/局部主题、SmartDialog loading、视频覆盖场景中保持正确层级、颜色和捕获禁用；验证VP-07同时覆盖内容与底盘，主题快照不冻结策略热更新。
- [ ] **P5-16** 真机完成快速开关、列表滚动中点菜单、鼠标/键盘/读屏、reduced/无触觉的组合检查。

**Gate G5**：所有指定生产入口完成台账映射；滑选正确且业务请求次数正确；新层打开不误 pop；scroll 与 long press 没有回归。

**回退**：按 adapter/入口单独切回旧组件，不改动作服务与 payload；菜单回退不得留下孤立 OverlayEntry 或 source 隐藏状态。

### P6 — 普通确认弹窗与设置开关

**目标**：统一普通弹层/开关体验，保留确认和持久化。  
**前置**：G5。  
**主要文件**：alert/switch adapter、common/widgets/dialog/dialog.dart、setting/widgets/switch_item.dart、台账中的普通确认调用点。

- [ ] **P6-01** 按台账筛选简单文本确认；复杂输入/登录/支付等明确保留，不用全局 search-replace。
- [ ] **P6-02** 实现 Future<bool> 兼容层：确认true，其余false；可选onConfirm与await结果不会重复触发业务。
- [ ] **P6-03** 显式标记 default/cancel/destructive action，检验按钮顺序、纵向堆叠和长中文，不靠列表位置猜测。
- [ ] **P6-04** 保留 barrierDismissible、返回/Esc、必要 PopScope guard 与焦点恢复语义。
- [ ] **P6-05** 使用上游 Alert veil/fade，浅/深/纯黑对比可读；视频背景下实体化且无捕获。
- [ ] **P6-06** 保留switchChange为开关唯一入口；onTap为空时整行与本体不双调用，onTap非空时整行仍进详情；isSplit独立命中、val=false不禁用开关本体。
- [ ] **P6-07** 必要确认先得到结果再保存；拒绝、返回、重复点和异步延迟都保持最后确认值。
- [ ] **P6-08** 处理存储失败与保存中busy gate，不显示永久的假成功；保留onChanged与needReboot时序。
- [ ] **P6-09** Disabled开关不接收手势/激活，语义仍给出状态；横拖、取消、RTL和键盘激活正确。
- [ ] **P6-10** 用户reduced经MotionScope接到context.motionDuration，系统切换中不留下半开thumb或timer。
- [ ] **P6-11** 全局触觉关闭保持零新增反馈；Switch没有为了仿效果增加未授权的新震动路径。
- [ ] **P6-12** 字体绝对override、大字、屏幕缩放、英文长文下确认按钮不截断，正文可滚动或符合原可读合同。
- [ ] **P6-13** 连续两层确认/菜单→确认/确认→loading的pop与焦点归属测试通过。
- [ ] **P6-14** 保存设置后退出/重启/导入备份复核，旧UI模式仍走原组件与相同业务。

**Gate G6**：确认结果、开关保存、取消和失败语义全部有断言；材质与动画不会改变业务最终值。

**回退**：恢复旧Alert/Switch外观层；现有setting key和值不迁移、无需回写。

### P7 — 普通 Sheet 试点与专用容器边界

**目标**：在真实生产入口证明拖动、滚动、键盘和结果合同，完成所有 Sheet 的分类。  
**前置**：G6。  
**主要文件**：sheet adapter、page_utils 的受控分流、音频收藏入口、FavPanel 控制器接线、vendor的VP-06窄补丁；MiniScaffold/PublishRoute原则上只审查和回归。

- [ ] **P7-01** 为所有候选 Sheet 确定 modal/persistent/video-side 类型、Navigator、dismiss/结果、尺寸、controller和LocalHistory所有者。
- [ ] **P7-02** 音频收藏作为生产试点，保留游客校验、quick-fav点击/长按分流；视频收藏仍走旧实现。
- [ ] **P7-03** 按原移动横屏谓词冻结每次打开的detents：普通[.7,1.0]、移动横屏[1.0]；route子类约束整层视口最大宽度，保留系统安全区，barrier仍全屏。
- [ ] **P7-04** 将SnapSheet提供的controller传给FavPanel真实列表，保留勾选/请求/刷新；成功只由actionFavVideo既有路径关闭一次，失败留面板，不创建第二套选择或自动pop。
- [ ] **P7-05** 验证sheet先展开后内容滚动、顶部下拉、非顶部下拉、fling与取消；不得一手势中途错误接管。
- [ ] **P7-06** 实测Sheet→/createFav完整页面→输入/返回→原Sheet，新文件夹按原规则插入并选中，原选择/滚动保留；键盘显隐不遮操作，不将新建流程改成内联表单。
- [ ] **P7-07** 模拟快速开关、拖动中pop与两方向打开后旋转；保持同一路由/controller及冻结列表，静止/吸附保留stop、拖动遵循上游resize，无重复close/dispose或多重attach。
- [ ] **P7-08** Reduced路径保留直接拖动/滚动，释放直接落正确detent，业务确认不被跳过。
- [ ] **P7-09** 明确保留MiniScaffold的PersistentBottomSheetController/LocalHistoryEntry；返回仅关闭内嵌面板，不退出视频。
- [ ] **P7-10** 回归PublishRoute竖屏70%高、横屏右侧50%宽/最大500dp、Get.arguments与350ms过渡，不能被普通Sheet分流误接管。
- [ ] **P7-11** 核对所有被放入新Sheet的内容不依赖错误GetPageRoute强转；Navigator归属和取消语义按原调用点保持。
- [ ] **P7-12** 产出生产试点录像、controller归属测试和全部保留项台账；至少真实完成音频收藏入口，不能仅有组件gallery。
- [ ] **P7-13** 实施VP-06的每route topPeek，默认10dp原行为不变、试点0时真正达到1.0；不改全局叠层peek，测试单detent与两detent的reach/float/安全区。

**Gate G7**：普通生产Sheet可用、手势协调正确；专用视频容器无回归；未能表达的合同已经解决或形成明确规范变更，不能悄悄缩水试点。

**回退**：音频收藏切回原showModalBottomSheet分支；确认controller没有交叉ownership或遗留LocalHistoryEntry。

### P8 — 媒体表面、路由生命周期与平台兼容专项

**目标**：验证P2的保守策略覆盖全部真实媒体路径，保证播放体验与返回行为。  
**前置**：G7；媒体基本抑制已在G2完成。  
**主要文件**：scene_controller与真实表面注册点，video/live/gallery/播放器的最小生命周期接线；不改解码与业务状态机。

- [ ] **P8-01** 对照锁定media_kit_video的实现与真机，记录Android/iOS/桌面的Texture/PlatformView/native渲染路径，不以RepaintBoundary推断。
- [ ] **P8-02** 验证视频/直播/图库/mini/PiP/平台视图的lease清单完整；只要风险表面即将绘制，捕获已被抑制。
- [ ] **P8-03** 覆盖播放/暂停/缓冲/结束/切集/错误，暂停或首帧未到不错误恢复玻璃。
- [ ] **P8-04** 覆盖opaque route覆盖、Offstage保活、内嵌↔全屏、PiP进出、pop中取消；lease按可见性而非对象是否dispose更新。
- [ ] **P8-05** 同时存在两个风险表面或路由过渡lease时，先释放一个不会提前恢复；离场最后一帧后才恢复。
- [ ] **P8-06** 主题/玻璃/减弱动效/触觉切换时Player与VideoController identity不变，播放位置连续、音频不中断、无多余URL请求。
- [ ] **P8-07** 完整回归seek/取消、亮度/音量/全屏纵滑、长按倍速、双击、双指缩放、弹幕点选、锁屏和鼠标/键盘。
- [ ] **P8-08** 弹出Prism菜单/Alert后底层输入不会误seek/暂停；关闭恢复原焦点与输入，手势热区不扩张。
- [ ] **P8-09** 保留先解锁→退出desktopPiP→退出全屏→返回的优先级，以及视频/直播didPushNext/didPopNext的暂停/恢复规则。
- [ ] **P8-10** 音频后台、PiP、字幕、弹幕时间、心跳和下载不受纯UI ticker/不可见策略影响。
- [ ] **P8-11** 全屏、横屏右侧Sheet、内嵌persistent面板、外部路由返回的操作顺序与基线一致。
- [ ] **P8-12** 在硬解/软解、常用分辨率、弹幕开关、直播重连及图库视频切换下检查黑帧/缺图/冻结与内存释放。
- [ ] **P8-13** 核对Windows/Linux renderer禁用开关未改；macOS/iOS按实测填支持表，未测试能力明确未验证。
- [ ] **P8-14** 对出现媒体兼容问题的入口优先缩小Prism表面或修正lease，保留业务fallback；不以修改播放器核心绕过问题。

**Gate G8**：媒体矩阵内的实际支持路径通过，风险表面捕获为零且业务连续；真视频背景折射仍不属于v1已支持能力。

**回退**：保留全局实体fallback，必要时按入口回到旧UI；业务Player和数据格式无需迁移。

### P9 — 性能、资源、无障碍与视觉一致性

**目标**：把“看起来能用”变成可测、可解释的支持范围。  
**前置**：G8。  
**主要文件**：受证据指向的局部实现、tests/integration_test、verification；不做无关全仓重构。

- [ ] **P9-01** 执行§15固定脚本，分别记录原基线、Prism-Off、Standard、Ultra；同设备/分辨率/刷新率/数据条件交替比较。
- [ ] **P9-02** 在至少一台主要Android设备及另一GPU/性能等级设备记录数据；120Hz目标只在实际120Hz运行条件下评估。
- [ ] **P9-03** 分开冷启动首次展示与预热后的持续交互；不把首次Shader加载成本从报告里删除。
- [ ] **P9-04** 收集UI/build/layout、raster/capture、实际presented missed-vsync与内存；不能只报平均FPS。
- [ ] **P9-05** 证明拖Dock主要重绘相关区域，无关页面不每帧build；idle状态无装饰ticker持续请求帧。
- [ ] **P9-06** 只对确实同层的pane使用稳定Group，审查没有重复Host、无效重叠采样和每卡捕获。
- [ ] **P9-07** 连续开关菜单/Alert/Sheet后capture/held-image回到预期，监听器、timer、OverlayEntry、Scene lease没有增长。
- [ ] **P9-08** 查明并修复含玻璃淡出被普通Opacity截断、主题切换反复捕获、缩放坐标错位等具体问题。
- [ ] **P9-09** 如果延后非关键列表显示提交，只延后presentation snapshot；网络真实状态、播放、音频、心跳、字幕和弹幕仍更新。
- [ ] **P9-10** 全组件运行时切换system reduced/用户reduced，确认终态、回调、焦点和取消语义不变。
- [ ] **P9-11** 检查TalkBack/VoiceOver适用路径的名称、选中、未读、禁用和modal边界；每项只读一次，隐藏层不读。
- [ ] **P9-12** 验证键盘Tab/方向键/Enter/Space/Esc、鼠标hover/右键和移动触摸各自独立合同。
- [ ] **P9-13** 大字、UI缩放、RTL测试布局、窄屏、横屏/折叠和三键导航不溢出；不得为通过截图强制缩小全局文字。
- [ ] **P9-14** 高对比模式按政策实体化；浅/深/纯黑和不同种子色的文字/焦点/危险动作可辨，证据覆盖真实内容背景。
- [ ] **P9-15** 按本文性能门槛作通过/阻塞判断；不达标先定位面积、捕获层数、重绘和首次build，不偷偷削减标准参数或关闭测试。
- [ ] **P9-16** 生成设备支持表和已知限制；Ultra性能不达标的设备明确实验/不推荐，保留用户请求值，不假装所有设备都满帧。

**Gate G9**：Android主支持路径满足明确功能/视觉/性能标准；所有资源与无障碍阻塞已解决。未测或不达标路径只能按证据标注，不能挪用FlClash模拟器数字证明本项目。

**回退**：按同一场景保留Off/实体或旧adapter；禁止通过删除旧路径让用户失去可用回退。

### P10 — 跨平台验证、范围闭环与交接

**目标**：让实现可维护、可回退，并明确真正完成的范围。  
**前置**：G9。  
**主要文件**：验证workflow、README/第三方说明、surface_inventory、verification、spec完成标记；产品变化仅限已定位的发布阻塞。

- [ ] **P10-01** 重新核对所有R需求与阶段TODO，已勾选项有commit/测试/必要设备证据；未通过项不能标为完成。
- [ ] **P10-02** 所有台账入口必须落入已迁移或明确保留两种结论，不能剩“接了外观但业务待补”。
- [ ] **P10-03** 对Android与仓库既有iOS/macOS/Windows/Linux构建执行相应验证；保留原SDK/补丁和renderer选择。
- [ ] **P10-04** Android主要支持路径完成真机验证；其他平台分别标明构建、交互、折射三个状态，不能以构建成功代替支持声明。
- [ ] **P10-05** 对Windows/Linux实体fallback、鼠标/键盘、窗口resize/minimize/restore/DPI变化做已支持范围内回归。
- [ ] **P10-06** 复核设置从旧版导入、新设置未知值、重启生效的pending/applied、关闭Prism恢复旧底栏等升级路径。
- [ ] **P10-07** 演练关闭玻璃、关闭Prism重启、回退单个adapter三个层级，验证账号/配置/历史/播放数据不丢。
- [ ] **P10-08** 审查PATCHES账本与vendor差异，确认没有未登记Shader/物理参数修改，第三方许可和NOTICE齐全。
- [ ] **P10-09** 更新面向用户的设置说明与支持范围，默认仍为Prism=false、glass=off；不默认强开Ultra。
- [ ] **P10-10** 清理临时日志/数据/调试入口暴露；保留内部可重复验证方式，不包含账号cookie、签名材料或个人内容。
- [ ] **P10-11** 准备交接说明：当前提交、SDK/补丁、测试命令、未解决事项、上游升级流程和下一次安全开发入口。
- [ ] **P10-12** 形成候选构建与完整评审材料；正式发布是单独的交付动作，必须使用用户实际指定的版本/渠道，不由本规范自动触发。

**Gate G10**：v1范围闭环、支持声明准确、回退演练通过，候选版本可供用户评审。本文编写阶段不执行任何产品发布。

**回退**：候选版本不满足验收时撤回候选、保留已验证提交；运行中的用户可以关闭Prism重启恢复原UI。正式版本回退必须保留同一设置/账号/历史格式，不通过清数据解决问题。

## 15. 测试矩阵、性能门槛与证据格式

### 15.1 测试层次

| 层次 | 能证明什么 | 不能单独证明什么 |
|---|---|---|
| 纯逻辑测试 | 设置解析、策略、身份映射、lease计数、状态结果 | 真正Shader外观和GPU成本 |
| widget/gesture/semantics | 回调次数、手势竞技场、布局、焦点、结果与释放 | 真实设备纹理路径与呈现帧率 |
| 固定条件golden | 结构、字重/颜色/尺寸、浅深主题 | 动态折射正确、连续交互体验 |
| 真机integration/profile | 媒体、Shader、系统返回/键盘、实际流畅性 | 所有未测试设备自动等价 |
| 代码/依赖差异审查 | 参数未漂移、补丁范围、来源可追踪 | 未运行代码已经通过 |

不为每个常量写镜像实现测试。把测试资源集中在此次跨库接入最可能出错的事件、生命周期、绘制、设置与业务合同。

### 15.2 核心场景矩阵

每个T编号至少关联一个测试文件或手工脚本。表内“请求次数”使用stub/记录器证明，不能用真实账号重复提交危险动作。

| 测试 ID | 操作与输入 | 必须得到的结果 | 对应需求 |
|---|---|---|---|
| T01 | 原版和迁移版在固定补丁SDK构建 | 环境可复现，无未解释依赖漂移 | R01/R02 |
| T02 | 混合GetMaterialApp打开全部迁移组件 | 无缺delegate/Measure/ViewScope；路由key稳定 | R03/R05 |
| T03 | 浅/深/纯黑/动态色/局部深色主题 | Prism与现有主题语义一致，旧IconTheme不污染 | R04 |
| T04 | 字体、绝对字重w300/w600、大字、UI scale变化 | 测量与绘制一致，hit test和anchor无二次缩放 | R04/R22 |
| T05 | 缺失/未知/错误类型设置、备份导入 | 合法安全默认；pending与applied不混淆 | R06 |
| T06 | 首次请求Standard，初始Shader未加载 | ensureLoaded只启动一次；实体→ready正常，无启动死锁 | R07/R08 |
| T07 | 加载中切Off、失败、renderer不支持 | 不重新启用、不每帧重试；交互完整 | R07/R24 |
| T08 | 两个视频lease+过渡lease交错释放 | 最后一项风险消失前capture始终停 | R09 |
| T09 | highContrast/应用不可见再恢复 | 分别解除自身原因，其他抑制仍有效 | R09/R22 |
| T10 | Nav顺序[mine,home,dynamics]，默认home | 启动home，返回首项为mine | R10/R14 |
| T11 | 0/1/2/3项、隐藏mine/home、非法旧值 | 不触发Dock断言，合法顺序与独立mine入口保留 | R10 |
| T12 | 同项单击、500ms内二次重选 | 原回顶/刷新与throttle合同，单次分发 | R11 |
| T13 | 拖过多项后回原项、pointerCancel、第二指 | 只改视觉预览，取消零业务，不伪造双击 | R11 |
| T14 | 快速A→C→B及过渡中旋转 | 最终B；状态/透镜一致，无旧completion回滚 | R13 |
| T15 | 切换后返回首页/动态/我的 | 同State/controller/滚动位置/内部Tab | R13 |
| T16 | dynCount已有值切hidden、账号切换、迟到响应 | 徽标不绘制/不读屏；number/dot语义正确 | R12 |
| T17 | 开/关触觉，Dock tap/重选/键盘/跨项/fling/取消、菜单滑选/开关 | 关闭全部0；普通激活保留一次，跨项保留原节奏且终点不叠加，取消无activation反馈 | R12 |
| T18 | 底栏隐藏、三键导航、列表滚到底、侧栏转换 | 末项可点、无双inset、隐藏导航不抢触摸/焦点 | R14 |
| T19 | Material按钮包PopupAnchor负例与正式Prism目标 | 负例被识别；正式按下滑选有效 | R15/R16 |
| T20 | 列表纵滑、长按菜单、菜单内滚动、越界释放 | 正确arena胜者；取消不执行action | R16 |
| T21 | anchor菜单选项→新弹窗；point菜单→新route | 先正确收旧层，动作一次，不误pop新层 | R16 |
| T22 | menu打开后tile重排/删除、网络失败/成功 | 操作原identity；失败不移除、成功按原逻辑移除 | R16 |
| T23 | PopupListTile<T>取消/同值/新值/disabled | 0/0/1次业务写入，T不失真，焦点合同保持 | R17 |
| T24 | 确认/取消/系统返回/barrier/不可取消Alert | Future结果正确；onConfirm不双调用 | R18 |
| T25 | 开关整行/本体/拖动、确认拒绝、写入失败 | 一次事件，最后确认值真实，无假成功 | R18 |
| T26 | 音频收藏quick-fav/长按/游客、普通Sheet拖滚、提交成功/失败 | 原分流与controller一致；成功业务只pop一次，失败保留面板和选择 | R19 |
| T27 | Sheet最大高度、拖动中pop、两方向打开后旋转 | topPeek=0达到1.0；冻结列表/route/controller，无重复close/dispose | R19 |
| T28 | 视频内嵌Sheet→返回、横屏视频Sheet | 只关局部面板；右侧50%/最大500dp保留 | R20 |
| T29 | 视频/直播/图库、暂停/缓冲/切集/全屏 | capture禁用，无缺图/黑帧/冻结 | R09/R21 |
| T30 | 播放时改变主题/玻璃/motion、开关菜单 | Player identity/位置/音频连续 | R21 |
| T31 | 播放器全部手势、锁屏/PiP/全屏返回链 | 原输入与返回优先级不变 | R21 |
| T32 | 后台音频/PiP、前后台切换、重连 | 纯UI策略不停止业务时钟/服务 | R21 |
| T33 | 系统reduced/用户reduced中途切换 | 完整终态，无悬停ticker/隐藏source，结果正常 | R22 |
| T34 | 读屏、键盘、鼠标、长中英文/大字/RTL | 单一可理解语义、焦点恢复、无隐藏层干扰 | R22 |
| T35 | 固定脚本baseline/Off/Standard/Ultra比较 | 指标满足门槛或明确阻塞/实验范围 | R23 |
| T36 | 关闭单个弹层/全部pane、100次开关 | 被移除pane held=0；其余全局回基线，Off/全离树归零，无未解释内存增长 | R23 |
| T37 | Windows/Linux非Impeller与其他平台构建 | 实体fallback准确，支持状态不夸大 | R24 |
| T38 | 关闭玻璃、关闭Prism重启、回退adapter | 原设置/账号/历史保留，原UI可用 | R25 |
| T39 | 带onTap的设置项，val=false/true与isSplit两种布局 | 详情区按原规则可用；Switch仍可启用，不把详情点击改成toggle | R18 |
| T40 | 根浅色/源局部深色打开Popup/Alert/Sheet，再切Off/reduced | 整层颜色一致；局部主题快照与根策略热更新互不干扰 | R04/R07/R22 |
| T41 | 音频Sheet→/createFav输入→返回 | 新文件夹插入/选中、原选择/滚动保留，键盘与返回栈正确 | R19 |
| T42 | profile显式启用诊断、开关玻璃/卸载pane | 数值计数确实变化，capture pass与snapshot区分，不额外持有图像 | R23 |

### 15.3 必须覆盖的配置维度

不要求把所有维度做笛卡尔积。采用核心路径全覆盖、风险相关组合追加：

| 维度 | 最低覆盖 |
|---|---|
| 主题 | light / dark / pure black；至少一个高亮种子色和动态取色 |
| 玻璃 | UI关闭、Prism-Off、Standard、Ultra、加载失败、renderer unsupported |
| 运动 | standard、系统disableAnimations、用户reduced、运行中切换 |
| 布局 | 竖屏底部、横屏/侧栏、单导航项、窄屏、大字 |
| 缩放 | 默认、一个非1 UI scale；textScale 1.0/1.3/2.0；至少一次组合缩放 |
| 输入 | touch、pointer cancel、mouse、keyboard、screen reader |
| 系统 | 手势导航/三键导航、键盘显隐、前后台、旋转、窗口resize |
| 内容 | 长列表、超长标题、大量未读、异步刷新、空态、错误态 |
| 媒体 | 视频/直播/图库、硬解/软解、弹幕、全屏、PiP、后台音频 |

现有应用内容以中文为主，英文和RTL的测试用于组件布局与语义可靠性，不声称本次已完成整个应用多语言翻译。

### 15.4 性能测量协议

以下为**本项目拟定的验收协议**，不是已经测得的成绩：

1. 固定commit、SDK补丁、构建模式、手机/OS/GPU、分辨率、实际刷新率、字体与UI缩放、亮度/温度区间、内容fixture。
2. 使用profile或等效可分析构建，不用debug的帧时间宣称发布性能；同时留一轮release体验观察。
3. 原基线、Prism-Off、Standard、Ultra在同机交替运行，每种至少三轮；保留逐帧原始数据。先算每轮p50/p95/p99与jank比例，再报告三轮各统计量的中位数；不将三轮无标记混池，也不只挑最好一轮。
4. 单轮持续场景至少30秒，窗口内持续执行约定操作，不能以大量静止时间稀释卡顿；冷首次与已预热分开报告。菜单/Alert/Sheet至少20次重复开合，每次从输入到动效/内容稳定为有效窗口；泄漏检查100次。
5. 场景包括：推荐/动态快速滚动、连续拖Dock、快速跨Tab、菜单开合与菜单内滚动、Alert、Switch、Sheet+键盘、播放同时打开实体菜单。
6. 至少同时报告UI与raster的p50/p95/p99、jank比例、最长连续超预算帧数、内存峰值与稳定后值。P0冻结采集器与计算脚本版本、有效窗口、刷新率变化处理和分母；所有配对档位用同一口径。最长连续值取所有有效窗口/三轮中的最大值，不用中位数掩盖一次明显停顿。
7. 区分平台实际呈现jank与Flutter FrameTiming代理指标。有平台trace时按其固定present-deadline口径计算；仅FrameTiming时以UI或raster任一超过该轮固定刷新率预算为bad frame、分母为有效窗口的FrameTiming样本数，明确标为代理。代理不能证明完整呈现链路无卡顿；不混用两类数值计算表中的百分点差。主要Android正式支持结论需要至少一组实际呈现trace佐证；可变刷新率不明的记录不得硬套固定预算。
8. profile计数通过VP-04显式开启，记录capture pass、实际snapshot、pane/held引用、关键组件build/repaint。不得读取仅assert更新的debug字段当profile证据；诊断计数不保留图像。对性能结论补一轮关闭诊断的同脚本记录，若诊断本身显著改变结果，以关闭诊断性能trace为准、计数另列。

120Hz单帧时限约8.33ms、60Hz约16.67ms，这只是刷新率的时间预算。UI线程与raster线程需要分别评估，不能简单相加后冒充用户看到的帧间隔。

### 15.5 发布阻塞阈值与处理

为避免开发最后才临时降低标准，v1先采用以下门槛；修改门槛必须有原始数据与决定记录：

| 项目 | 门槛 | 未达到时 |
|---|---|---|
| 业务正确性 | 已列功能/结果/输入回归为0 | 阻塞对应阶段 |
| Off持续性能相对原基线 | p95 UI和raster分别不劣于基线 `max(10%, 0.5ms)`；jank增加≤1个百分点 | 定位桥接/多余build/隐藏ticker；不可用关测试解决 |
| Standard主要Android支持设备 | 每个持续脚本jank≤5%，相对Prism-Off增加≤2个百分点；最长连续超预算帧数≤`max(2, Off同脚本最长连续值)` | 减少不必要pane/重绘/层数；仍不达标则不能称该设备已支持流畅Standard |
| Ultra | 正确性、资源与业务必须通过；按同一帧指标报告 | 未达到Standard门槛时标实验/不推荐，不默认开启 |
| 静止态 | 不因纯装饰动画持续调度帧；允许真实播放/loading等业务更新 | 查残留ticker/timer/hover状态 |
| 关闭/离树 | 被移除pane的held引用=0；全局资源回到操作前基线。Off/Host禁用/全部pane离树时，全局held=0且此后capture增量=0；lease、Overlay、监听器回到各自正确基线 | 阻塞，不能只靠重启释放；底部Dock仍可见时不错误要求全局清零 |
| 内存 | 预热后100次开合，不存在可复现、未解释的逐批持续增长；保存分批图和资源计数 | 分辨缓存/引用泄漏后修复；不以单次GC截图判断 |
| 首次打开 | 单独记录加载、首个移动帧与交互等待；不得出现永久空白/不可点/未解释超时 | 检查加载状态与首次build；不虚构warmup成功 |

例如基线p95 raster=6ms，则Off允许的增量是max(.6,.5)=.6ms；若为2ms则允许增量.5ms。以上只用于同设备同条件对照，不可拿不同手机或不同刷新率互比。

FlClash曾记录SwiftShader软件模拟器相对Off的额外开销，例如滚动底栏背景Standard/Ultra约7.5/11.6ms、拖导航透镜约16.5/34.5ms。它的文档明确这些不是手机GPU成绩；本项目不把它们当目标、实测结果或支持保证。[F-PERF]

### 15.6 可以复用的测试资产

- Prism上游`test/widgets/liquid_glass_host_test.dart`和`popup_test.dart`等用于验证上游渲染/路由合同。
- FlClash的navigation_dock、snap_sheet、liquid_glass_host和popup测试提供行为场景；其HostApp、Riverpod和自有Navigator不能原样当成本项目集成环境。
- 当前Prism独立库没有与FlClash同等完整的Dock/SnapSheet/Switch测试集合，不能在脚本里假定这些文件都存在。
- 新应用测试必须至少有一套真实GetMaterialApp + SmartDialog + 缩放/桥接的harness；仅跑PrismApp示例不能覆盖本次集成。

来源：[U-TEST-HOST]、[U-TEST-POPUP]、[F-TEST-DOCK]、[F-TEST-SHEET]、[F-POPUP-TEST]。

### 15.7 验证命令与执行条件

以下命令供实施阶段在**G0已建立的隔离、已打补丁SDK环境**执行；本文交付时未运行。测试目录由对应阶段创建，不在尚不存在时伪报通过。

应用根目录：

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test test/prism
flutter test
flutter build apk --release --split-per-abi --android-project-arg dev=1 --no-pub
```

vendored包根目录另运行其pub get/analyze以及与VP补丁直接相关的测试，避免误用应用测试替代包测试。具体integration脚本/设备ID由P0环境清单给出；各平台继续按现有workflow的构建约定执行。

格式检查只针对本次改动的Dart文件；不批量重格式化全部vendor/历史业务代码。现有基线警告保留清单，新增错误/警告按当前项目规则处理，不通过全局ignore隐藏。

### 15.8 每阶段的证据文件

建议每阶段一个验证记录，结构固定：

```markdown
# Pn verification

- Application commit:
- Prism upstream SHA / patch revision:
- Flutter / Dart / engine / applied patches:
- Build mode and command:
- Device / OS / GPU / renderer / refresh rate:
- Related TODO IDs and requirement IDs:
- Automated test commands and results:
- Manual scenario IDs and results:
- Screenshots / recordings / raw traces:
- Baseline comparison:
- Known limitations and unexecuted checks:
- Rollback exercise:
```

没有设备、签名或某平台工具链时，写“未执行：缺少……”，对应支持声明保持未验证。不能写“应当通过”替代结果。

## 16. 风险、待实测问题与固定处置

### 16.1 风险清单

| 风险 ID | 触发条件 | 已决定的处置 | 阻塞位置 |
|---|---|---|---|
| K01 | SDK或pub-cache补丁未重现 | 专属环境按原脚本构建，不混升SDK | G0 |
| K02 | 两套Theme/ColorScheme/IconTheme混用 | 明确别名、逐角色映射、旧IconTheme恢复 | G1 |
| K03 | 缺UiLocalizations/Measure/ViewScope | 作为基础契约安装和混合harness验证 | G1 |
| K04 | Shader ready前不创建pane导致从未加载 | VP-04主动幂等ensureLoaded | G1/G2 |
| K05 | 自定义ticker忽略reduced或用户触觉 | VP-02覆盖helper和自建状态机入口 | G1/G9 |
| K06 | Dock缺重选/徽标而退化业务 | VP-01窄补丁，事件合同与badge唯一绘制 | G3 |
| K07 | 业务setIndex在拖动每帧触发 | preview本地化，只在commit/reselect调用业务 | G3 |
| K08 | 跨页动画卸载State或旧completion回滚 | 稳定identity、lazy-retained slots、generation | G4 |
| K09 | 底栏留白叠加或末项被挡 | metrics统一，逐页面登记旧padding | G3/G4 |
| K10 | PopupAnchor包Material按钮但触摸滑选无效 | 使用上游可识别的Prism press target | G5 |
| K11 | 菜单回收后使用失效context/错误内容 | 稳定payload、typed结果、一次性分发 | G5 |
| K12 | 新菜单先开新层再Get.back误关 | 明确closed与action完成时点 | G5/G6 |
| K13 | 两类专用Sheet被换成普通modal | v1保留，音频收藏单独生产试点 | G7/G8 |
| K14 | 视频/平台视图未进入capture重放 | 根级保守lease抑制，真实媒体验证 | G2/G8 |
| K15 | lease绑定对象生命周期而非可见绘制 | 覆盖opaque/Offstage/fullscreen/PiP/离场动画 | G8 |
| K16 | Opacity截断玻璃采样根 | 使用专用fade/veil并在真内容背景验证 | G5/G9 |
| K17 | 为视觉修改Windows/Linux renderer | 本轮明确不改，实体fallback | G10 |
| K18 | 设置导入热切重启生效配置 | persistedPending/appliedAtStartup分开 | G2/G10 |
| K19 | 列表性能优化误停媒体/业务时钟 | 仅装饰ticker与非关键展示可节流 | G8/G9 |
| K20 | 只看demo就称完成全迁移 | 入口台账、T矩阵与逐阶段证据闭环 | G10 |
| K21 | detent=1仍受固定10dp上限，横屏/宽度缩水 | VP-06 topPeek=0及route整层宽度约束；旋转列表冻结 | G7 |
| K22 | 局部主题只包内容，弹层底盘颜色来自根 | VP-07捕获主题，整层颜色在内部context读取 | G1/G5/G6/G7 |
| K23 | profile读取assert计数0形成无捕获假证据 | VP-04数值诊断与实际trace，固定口径/分母 | G1/G9 |

### 16.2 待实测问题不是悬空设计

以下问题无法靠静态阅读诚实给出“已通过”，但已有固定执行方式和失败处理：

| 问题 | 负责阶段 | 必须获得的证据 | 失败时的下一步 |
|---|---|---|---|
| SDK3.47.9+现有补丁+Prism是否共同编译 | P0/P1 | lock差异、analyze、实际APK | 定位最小兼容点；不全量升级 |
| SmartDialog与Navigator实际叠层是否符合设计 | P1/P2 | mixed harness与真机交互 | 修正bridge位置，不新增App |
| Prism在已缩放DPR下捕获/anchor是否准确 | P2/P3 | 非1 UI scale的移动纹理与命中记录 | 统一坐标来源，不加随机补偿值 |
| 音频收藏已决定的topPeek/宽度/旋转方案是否正确运行 | P7 | 真实入口、两方向旋转、单/双detent、controller与关闭用例 | 修正VP-06/route包装的最小问题；仍失败则阻塞，不缩成demo |
| 锁定媒体依赖各平台到底产出何种layer | P0/P8 | 固定源码+运行期layer/trace证据 | 保持禁用捕获；不推测可重放 |
| 主要Android机型Standard是否过性能门槛 | P9 | 原始profile与配对对照 | 局部优化后重测；不改默认强度数值掩盖 |
| 大字/纯黑/高对比是否可读 | P9 | 真背景截图+语义/焦点检查 | 确定主题/布局修正；高对比仍实体 |
| 非Android平台的玻璃能力与手势完整度 | P10 | 分平台构建和设备记录 | 分别标未验证/实体支持，不笼统宣称全平台 |

不要求在本文编写阶段伪造这些实验结果。要求是：开发开始前已经知道谁来做、做到什么、失败如何收敛，以及哪些能力在证据到来前不允许被宣传为完成。

## 17. 变更控制、交接与最终验收

### 17.1 已冻结的决定摘要

| 决定 ID | 本规范决定 |
|---|---|
| D01 | SDK固定3.47.9，复用现有隔离补丁构建 |
| D02 | 保留GetMaterialApp/GetPageRoute/GetX和播放器 |
| D03 | 固定SHA的packages/prism_ui受控vendor |
| D04 | 必要scope/delegate/主题/缩放/Overlay完整桥接 |
| D05 | v1 Prism默认false、glass默认off；两者独立 |
| D06 | 单Host质量，原生preset，不存在全局强度倍率 |
| D07 | 内容ink、普通按钮tint、浮动操作elastic |
| D08 | 标准物理参数保持；系统或用户reduced走真实受控路径 |
| D09 | 导航身份来自配置，commit/reselect与preview分离 |
| D10 | 三个根Tab使用稳定lazy-retained slots，不复制snapshot/远跳重排 |
| D11 | 音频收藏是普通Sheet试点；两类视频专用容器保留 |
| D12 | 视频/平台表面及过渡根级捕获抑制 |
| D13 | Windows/Linux不启用Impeller，不把frost当完整折射 |
| D14 | pending与startup-applied配置区分，重启设置不热拆树 |
| D15 | 用户非normal字重绝对覆盖；normal保持Prism原字阶 |
| D16 | Shader幂等主动加载；不靠首个pane打破加载等待 |
| D17 | highContrast与应用不可见禁用捕获，保留业务服务 |
| D18 | 参数、性能门槛、scope和例外改变必须留决定记录 |
| D19 | Sheet每次打开冻结detents；旋转不重建route，音频topPeek=0 |
| D20 | 临时弹层捕获局部主题，根玻璃/动效/场景保持实时订阅 |
| D21 | profile不使用assert-only计数作证据；资源按被移除pane与全局基线分别验收 |

### 17.2 什么情况下允许改规范

允许因新的固定源码证据、真实实验失败、用户明确的新目标或更小且满足同一合同的实现方式而修订。修订至少记录：原条款、证据、备选方案、选择、影响的R/T/TODO、回退与需重跑的验证。

不得使用以下理由直接偏移：

- “上游内部参数不好改，所以删掉原业务能力。”
- “新组件看起来差不多，所以不测drag/cancel/键盘。”
- “运行太卡，所以把Standard悄悄改为普通透明度。”
- “为了省事统一使用rootNavigator / Get.back / SnapSheet。”
- “所有测试依赖旧架构，所以把它们删掉或全跳过。”
- “先上Ultra，性能以后再说。”

普通实现细节不需要反复询问用户；只要仍满足冻结合同即可推进。涉及产品范围、原有功能删除、架构替换或支持声明变化时，必须形成可审查的具体变更，不以模糊“以后优化”代替决定。

### 17.3 PR拆分和协作约束

推荐按P阶段提交，VP补丁可作为P1内部的小提交；每次评审都能分辨vendor改动、桥接改动和业务接线。多人/多agent并行时：

- 预先指定文件owner；同一阶段只有一个任务修改shared vendor motion、scene controller和main.dart。
- 独立adapter可并行，但共享类型先冻结；禁止各写一套glass/motion enum。
- 文档任务不夹带SDK升级、格式化或平台renderer开关。
- 每个PR说明“原问题/本次行为/对应TODO/已执行验证/未执行限制/回退”，不贴无证据的流畅性结论。
- 对上游Prism更新单开依赖PR，比较固定SHA差异、应用patch账本并重跑关联测试；不要改为追随main。

### 17.4 阶段交接最小模板

```markdown
## 本次阶段
- Stage / gate:
- Base / head commits:
- Completed TODO IDs:
- Requirement IDs:

## 发生的实际变化
- Vendor API/patch changes:
- App adapter changes:
- Business call sites:

## 证据
- Executed commands and results:
- Manual T-scenarios/device evidence:
- Unexecuted checks and exact reason:

## 接下来
- Remaining TODO IDs:
- Known blocking issue with reproduction:
- Next allowed file scope:
- Rollback path:
```

### 17.5 最终验收清单

- [ ] **FINAL-01** R01—R25均有证据覆盖，P0—P10 gate全部有真实结论。
- [ ] **FINAL-02** 用户看到的导航、菜单、Alert、Switch、普通Sheet与真实业务一致，交互连续且可取消。
- [ ] **FINAL-03** 玻璃与动效采用固定的分场景配方；没有散落的任意强度值或未登记私有补丁。
- [ ] **FINAL-04** 所有原有导航配置、主题/字体/缩放、触觉、返回与播放器关键行为保留。
- [ ] **FINAL-05** 默认Off、失败、视频/平台表面、highContrast和不支持renderer均有完整可用的实体路径。
- [ ] **FINAL-06** 性能、资源、读屏/键盘和设备支持范围都有可复查记录，未测项目明确列出。
- [ ] **FINAL-07** 专用视频Sheet与全局路由仍在原架构，未被“统一UI”暗中替换。
- [ ] **FINAL-08** 关闭Prism后的旧UI、用户数据与设置可恢复；上游来源和补丁可维护。

## 18. 固定源码索引

以下链接全部固定到本规范审查提交，不使用会漂移的main分支。文件链接用于定位实现，相关正文进一步指出了函数或机制。上游测试链接表示“源码中有该测试意图”，不表示已在本项目运行。

### 18.1 PiliPlus应用

| 引用 | 主要用途 |
|---|---|
| [P-PUB]、[P-LOCK]、[P-FVM] | SDK、包、锁定Git依赖 |
| [P-PATCH]、[P-CI] | 实际补丁构建与CI触发 |
| [P-ROOT]、[P-THEME]、[P-SCALE] | 根装配、颜色/字体、坐标体系 |
| [P-STORAGE]、[P-PREF]、[P-STYLE] | 设置导入/持久化/选项 |
| [P-NAV-M]、[P-NAV-C]、[P-NAV-V] | 导航身份、副作用和布局 |
| [P-LAYOUT]、[P-SAFE]、[P-MINE]、[P-COMMON-PAGE] | 底栏叠绘、留白、隐藏 |
| [P-ROUTE]、[P-SIZE]、[P-FEEDBACK] | 路由假设、布局判定、触觉偏好 |
| [P-VIDEO-MENU]、[P-POPUP-ITEM]、[P-SWITCH-ITEM]、[P-DIALOG] | 通用业务控件合同 |
| [P-MINI]、[P-SHEET]、[P-PAGE-UTILS]、[P-PUBLISH] | 三类Sheet与返回栈 |
| [P-AUDIO-C]、[P-FAV]、[P-COMMON-INTRO] | 生产Sheet试点、收藏结果与关闭所有者 |
| [P-PLAYER-V]、[P-PLAYER-C]、[P-VIDEO-V]、[P-LIVE]、[P-GALLERY] | 媒体渲染、输入和生命周期 |
| [P-WIN]、[P-LINUX] | 本项目现有Impeller开关 |

### 18.2 Prism组件与FlClash参照

| 引用 | 主要用途 |
|---|---|
| [U-PUB]、[U-NOTICE]、[U-PRESS-FIX] | 包约束、来源声明、参照版本差异 |
| [U-BARREL]、[U-APP]、[U-THEME]、[U-COLORS] | 可用导出与环境装配 |
| [U-L10N]、[U-MEASURE]、[U-VIEW]、[U-TYPE]、[U-CONTEXT] | 必须桥接的运行环境 |
| [U-GLASS]、[U-CAPTURE]、[U-SHADER]、[U-GOO] | 材质、捕获、渲染与质量 |
| [U-DOCK]、[U-POPUP]、[U-ALERT]、[U-SWITCH]、[U-SNAP]、[U-SHAPE] | 真实组件与运动参数 |
| [U-TEST-HOST]、[U-TEST-POPUP] | 独立库已有测试 |
| [F-PUB]、[F-SUB]、[F-GITLINK]、[F-CI]、[F-CONFIG] | FlClash版本/依赖/子模块提交/默认值 |
| [F-APP]、[F-HOME]、[F-PRESS]、[F-SURFACES] | 接入、页面呈现和反馈分配 |
| [F-GLASS]、[F-CAPTURE]、[F-PERF]、[F-STATUS] | 材质预算、性能证据边界、异步反馈 |
| [F-POPUP-TEST]、[F-TEST-DOCK]、[F-TEST-SHEET] | 可迁移的行为测试意图 |
| [D-SMART] | PiliPlus锁定SmartDialog的实际Builder/Overlay结构 |

[P-PUB]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/pubspec.yaml
[P-LOCK]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/pubspec.lock
[P-FVM]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/.fvmrc
[P-PATCH]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/scripts/patch.ps1
[P-CI]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/.github/workflows/build.yml
[P-ROOT]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/main.dart
[P-THEME]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/utils/theme_utils.dart
[P-SCALE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/scale_app.dart
[P-STORAGE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/utils/storage.dart
[P-PREF]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/utils/storage_pref.dart
[P-STYLE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/setting/models/style_settings.dart
[P-NAV-M]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/models/common/nav_bar_config.dart
[P-NAV-C]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/main/controller.dart
[P-NAV-V]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/main/view.dart
[P-LAYOUT]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/main_layout.dart
[P-SAFE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/view_sliver_safe_area.dart
[P-MINE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/mine/view.dart
[P-COMMON-PAGE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/common/common_page.dart
[P-ROUTE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/route_aware_mixin.dart
[P-SIZE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/utils/extension/size_ext.dart
[P-FEEDBACK]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/utils/feed_back.dart
[P-VIDEO-MENU]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/video_popup_menu.dart
[P-POPUP-ITEM]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/setting/widgets/popup_item.dart
[P-SWITCH-ITEM]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/setting/widgets/switch_item.dart
[P-DIALOG]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/dialog/dialog.dart
[P-MINI]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/scaffold/mini_scaffold.dart
[P-SHEET]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/scaffold/bottom_sheet.dart
[P-PAGE-UTILS]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/utils/page_utils.dart
[P-PUBLISH]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/common/publish/publish_route.dart
[P-AUDIO-C]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/audio/controller.dart
[P-FAV]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/fav_panel/view.dart
[P-COMMON-INTRO]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/common/common_intro_controller.dart
[P-PLAYER-V]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/plugin/pl_player/view/view.dart
[P-PLAYER-C]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/plugin/pl_player/controller.dart
[P-VIDEO-V]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/video/view.dart
[P-LIVE]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/pages/live_room/view.dart
[P-GALLERY]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/lib/common/widgets/image_viewer/gallery_viewer.dart
[P-WIN]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/windows/runner/main.cpp
[P-LINUX]: https://github.com/carry-yu-0239/PiliPlus-prism_ui/blob/cab0114a21ce7fad5b90b9a4d788d35d313d25f9/linux/runner/my_application.cc
[U-PUB]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/pubspec.yaml
[U-NOTICE]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/NOTICE
[U-PRESS-FIX]: https://github.com/chen08209/prism_ui/commit/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6
[U-BARREL]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/prism_ui.dart
[U-APP]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/app.dart
[U-THEME]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/theme_data.dart
[U-COLORS]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/color_scheme.dart
[U-L10N]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/l10n.dart
[U-MEASURE]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/measure.dart
[U-VIEW]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/view_scope.dart
[U-TYPE]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/typography.dart
[U-CONTEXT]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/context.dart
[U-GLASS]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/liquid_glass.dart
[U-CAPTURE]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/liquid_glass_capture.dart
[U-SHADER]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/shaders/liquid_glass.frag
[U-GOO]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/goo.dart
[U-DOCK]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/navigation_dock.dart
[U-POPUP]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/popup.dart
[U-ALERT]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/dialog.dart
[U-SWITCH]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/switch.dart
[U-SNAP]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/snap_sheet.dart
[U-SHAPE]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/lib/shape.dart
[U-TEST-HOST]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/test/widgets/liquid_glass_host_test.dart
[U-TEST-POPUP]: https://github.com/chen08209/prism_ui/blob/5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6/test/widgets/popup_test.dart
[F-PUB]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/pubspec.yaml
[F-SUB]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.gitmodules
[F-GITLINK]: https://api.github.com/repos/chen08209/FlClash/git/trees/be84736605527034689c95bf27828ff27d912c5e?recursive=1
[F-CI]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.github/workflows/build.yaml
[F-CONFIG]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/models/config.dart
[F-APP]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/application.dart
[F-HOME]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/pages/home.dart
[F-PRESS]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.agents/surfaces.md#L170-L198
[F-SURFACES]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.agents/surfaces.md
[F-GLASS]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.agents/architecture.md#L674-L717
[F-CAPTURE]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.agents/architecture.md#L691-L772
[F-PERF]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/.agents/architecture.md#L701-L754
[F-STATUS]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/lib/views/dashboard/widgets/core_status_button.dart
[F-POPUP-TEST]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/test/widgets/popup_test.dart
[F-TEST-DOCK]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/test/widgets/navigation_dock_test.dart
[F-TEST-SHEET]: https://github.com/chen08209/FlClash/blob/be84736605527034689c95bf27828ff27d912c5e/test/widgets/snap_sheet_test.dart
[D-SMART]: https://github.com/bggRGjQaUbCoE/flutter_smart_dialog/blob/5a1be84314e8c53efa3b7324cd8dc535fefe931a/lib/src/init_dialog.dart




