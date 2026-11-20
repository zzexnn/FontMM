# FontMM for HyperOS 4 — 完整独立安装包

这是基于 [YuleBest/FontMM](https://github.com/YuleBest/FontMM) 的非官方 GPL-3.0 衍生版本。原作者 Yule；HyperOS 适配者 zzexnn。

该 ZIP 内置上游 v26.8.0-beta.10 preplace 官方安装包的 WebUI、工具、Zygisk 预加载器、补充字库和预置字体，再整合 HyperOS 4 适配。**首次刷入不需要先安装原版 FontMM。**

安装：HyperOS 4 / Android 17（API 37）设备在 KernelSU 或 Magisk 中刷一个 ZIP，重启；进入 FontMM WebUI，选择字体、应用、重启。KernelSU 仍需要可用元模块，字体预加载仍需要独立的 Zygisk 提供者（如 Zygisk Next）。

已有 FontMM 的设备也可覆盖升级，安装器继承已选择的字体和字重设置。模块 ID 仍为 FontMM，无法与原版并行。

本独立版未经额外真机验证；旧版覆盖升级补丁已获单台 HyperOS 4 手机正常开机和系统设置字体替换的反馈。高级 XML 自定义字重映射尚未完整适配。刷机前保留备份；如卡开机可通过 KernelSU 安全模式或 root ADB 禁用 FontMM。

[源码仓库](https://github.com/zzexnn/FontMM) · [原作者项目](https://github.com/YuleBest/FontMM) · GPL-3.0
