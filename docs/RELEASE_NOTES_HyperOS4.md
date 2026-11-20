# FontMM for HyperOS 4 — v26.8.0-beta.10-hos4.1

**非官方兼容补丁，非独立安装模块。** 基于 YuleBest/FontMM (Yule, GPL-3.0)；需先安装原版 v26.8.0-beta.10。

改动：继承原版 WebUI 和字体；通过 systemless 覆盖 HyperOS 的 MiSans / Roboto / Noto 实际字体文件名；不挂载 ColorOS 的字体 XML；保留多字重字体文件与测试页面。

单设备反馈已确认正常启动、设置字体变化和 100–900 / 可变字重预览；未完整验证所有机型和 App，原版高级自定义 XML 字重映射仍未适配。

升级：在 KernelSU 中直接安装 ZIP，不要先卸载原版，重启后继续在 WebUI 选字体并应用。回退：禁用 FontMM 并重启；恢复原版需重装上游 ZIP。

来源： https://github.com/YuleBest/FontMM · GPL-3.0 · https://github.com/zzexnn/FontMM
