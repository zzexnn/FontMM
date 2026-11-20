# FontMM for HyperOS 4 · 修改记录

## v26.8.0-beta.10-hos4.1 (2026-11-20)

- 非官方的 HyperOS 4 / Android 17 覆盖升级模块；保留上游 FontMM v26.8.0-beta.10 的 WebUI、字体文件和组件。
- 添加 Xiaomi HyperOS MiSans / Roboto / Noto systemless 挂载文件名匹配，支持 system/product/system_ext。
- 不将 ColorOS 的字体 XML 覆盖带入 HyperOS；保留原版中文/英文槽位回退和英文子集化。
- 提供安装检查、状态输出和自动构建脚本。
- 实测范围：单台 HyperOS 4 设备正常开机，设置界面字体替换、多档字重预览有效；未验证所有 ROM / App。原版高级自定义字重 XML 映射未移植。

**上游**：https://github.com/YuleBest/FontMM · Yule · GPL-3.0。本项目与原作者无官方关联。
