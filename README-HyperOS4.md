# FontMM for HyperOS 4（非官方适配）

## v2.1 英数独立替换修复（预发布）

**[下载 v2.1 独立版](https://github.com/zzexnn/FontMM/releases/tag/hos4-v2.1.0-standalone)**。修复独立英文字体目标缺失但误报成功、增加已知英文目标名，并在明确选了 `en.ttf` 时生成不含拉丁字形的中文副本，避免抢占系统英文回退。原字体文件不会改变，源码见 [适配脚本](./hyperos4/module/hyperos-package/hyperos_apply.sh) 和 [HarfBuzz 字体工具](./native/src/subset/fontmm-subset.cc)。本版本仍需 HyperOS 4 实机进一步验证。


## v2 完整独立安装版（推荐）

**[下载 v2 独立安装版](https://github.com/zzexnn/FontMM/releases/tag/hos4-v2.0.0-standalone)**：包含原版 FontMM 的 WebUI、预置字体、Zygisk 组件和 HyperOS 4 补丁，首次安装只刷一个 ZIP，无需先安装原版 FontMM。详情见 [独立版说明](./hyperos4/standalone/README.md)。

## v1 历史覆盖升级版

> 基于 [YuleBest/FontMM](https://github.com/YuleBest/FontMM) 的 **GPL-3.0** 衍生适配。原作者为 **Yule**，HyperOS 4 兼容补丁由 zzexnn 发布，与原作者无官方关联。

本分支面向 **HyperOS 4 / Android 17 (API 37)**。这是在现有 FontMM 上应用的**覆盖升级包**，不是一个能独立安装的完整模块。必须先安装 [上游 FontMM v26.8.0-beta.10](https://github.com/YuleBest/FontMM/releases) 并在原版 WebUI 应用过简体中文字体。

## 使用

1. 保留原版 FontMM ZIP 与已经选择的字体；确认 KernelSU 的元模块正常。
2. 不要卸载原版，在 KernelSU 的模块页选择本项目 Release 中的 **FontMM_HyperOS4_Update_v1.zip** 进行覆盖安装。
3. **完整重启**。FontMM WebUI 可以继续使用：选择字体 →「应用字体」→ 重启生效。
4. 在设置、通知栏、控制中心及常用 App 中检查字体；系统滑块调整字重时对比字形是否保持一致。

模块 ID 仍为 `FontMM`，不能和原版并行安装。安装前请确认设备与 Android 版本符合要求。

## 实现

- 继承原版 WebUI、字体、fontmm-wght、字体子集化工具和 Zygisk 预加载器，尽量保持原有使用流程。
- 使用新增的 `hyperos4/module/hyperos-package/hyperos_apply.sh`，仅为设备**实际存在**的 MiSans、Roboto、Noto 等名称生成模块内的 systemless 字体覆盖文件，支持 system/product/system_ext 字体目录；不替换 TTC 集合。
- 不覆盖 HyperOS 的原生 `fonts.xml` 或 `hyper_fonts.xml`，不直接修改只读系统分区。
- 英文字体存在 CJK 字形时仍保留原版的字体子集化处理，避免意外覆盖中文字形。
- 没有包含商业字体文件，用户自备支持中文和所需字重的合法字体。

## 测试状态（2026-11-20）

**单设备实际反馈**：安装后正常开机；系统设置字体被替换；FontMM 100–900 字重和可变字重预览工作；系统字体粗细滑块调整后，用户未观察到切回小米原厂字体。

**未完整验证**：所有 HyperOS 4 版本、多机型、所有第三方 App、通知/锁屏全覆盖，以及原版高级自定义 `wght` XML 映射。字体预览正常不等于系统所有界面都使用相同的字体轴值。

## 风险及回退

这是 root 级兼容补丁，存在不兼容、文字缺失或卡开机风险。如果还能进系统，先在 KernelSU 禁用 `FontMM` 并重启。如卡开机，尝试 KernelSU 安全模式（开机早期连续短按音量下），或在有 root 权限的 ADB shell 中执行 `ksud module disable FontMM`。禁用只能撤销字体覆盖；要恢复原版 FontMM，请重新安装上游 ZIP。

## 源码 / 发布

- 本项目的改动源码在 [`hyperos4/module/`](./hyperos4/module/)；上游源码保留在 Fork 的原始目录中。
- [`scripts/build_hyperos4.py`](./scripts/build_hyperos4.py) 可以从适配源码创建安装 ZIP，不会打包第三方字体。
- 许可：[GPL-3.0](./LICENSE)，原作者 Yule，修改者 zzexnn。变更记录见 [CHANGELOG-HyperOS4.md](./CHANGELOG-HyperOS4.md)。
