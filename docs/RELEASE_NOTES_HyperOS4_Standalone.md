# FontMM for HyperOS 4 v2.0 · 完整独立版

**单个 ZIP 安装，无需先刷原版 FontMM。**

基于 YuleBest/FontMM v26.8.0-beta.10（原作者 Yule，GPL-3.0），非官方 HyperOS 4 适配：zzexnn。官方原版 preplace ZIP 经固定 SHA256 校验后合入 WebUI、预置字体、可变字体和字重工具、Zygisk 预加载及 HyperOS 4 系统字体文件覆盖补丁。

支持 HyperOS 4 / Android 17 / SDK 37。KernelSU 需要元模块，Zygisk 预加载需要 Zygisk 提供者。已有 FontMM 用户可以直接覆盖升级，尝试保留已选字体。安装后重启，在 FontMM WebUI 选择字体、点击应用并重启。

**状态：预发布版。** 之前的覆盖升级版已收到单设备成功开机和字体替换反馈；此新打包方式尚无真机实测。自定义高级 XML 字重映射尚未完整适配 HyperOS 4，出现问题可使用 KernelSU 安全模式禁用 FontMM。

源码：https://github.com/zzexnn/FontMM · 上游：https://github.com/YuleBest/FontMM · GPL-3.0
