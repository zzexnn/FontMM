# FontMM for HyperOS 4 · v2.2.0 Diagnostics（独立版）

**WebUI 首页新增“导出诊断日志”，无需电脑或手动终端命令。**

- 本地生成 TXT 文件至 Download/FontMM：模块与 ROM 版本、字体槽位状态、系统字体覆盖结果、安装记录和最近两次字体应用日志。
- 默认导出不调用 logcat、不包含字体文件内容、不自动上传。
- 点击“附加系统字体日志”并再次确认后，可以加入最多 160 条字体相关 Android logcat；可能包含隐私信息，发送前请检查。
- GitHub 新增标准化 Issue 表单，方便反馈设备、系统、复现步骤及日志。
- 保留 v2.1 的英文数字兼容修复，可以从 v2.0 / v2.1 直接覆盖升级，首次安装也只需要一个 ZIP。

系统要求 HyperOS 4 / Android 17 (SDK 37)，KernelSU/Magisk 及适配的挂载和 Zygisk 环境。本版 CI 检查 WebUI 构建、ZIP 完整性、诊断输出与保留日志；**尚未经过全面真机验证，属于非官方预发布版**。

原项目：[YuleBest/FontMM](https://github.com/YuleBest/FontMM)，作者 Yule，GPL-3.0；适配 [zzexnn/FontMM](https://github.com/zzexnn/FontMM)。
