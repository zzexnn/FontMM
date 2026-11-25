# FontMM for HyperOS 4 v2.2 · 诊断日志版

非官方 GPL-3.0 衍生适配，原作 YuleBest/FontMM，原作者 Yule，适配者 zzexnn。

**WebUI 首页 → 故障反馈 · 诊断日志**：点击「导出诊断日志」后生成本地 TXT，包含系统版本、模块版本、字体槽位是否存在、已匹配的系统字体、安装记录和最近两次应用日志。默认不收集系统 logcat，也不会上传或导出字体文件。文件保存在 `Download/FontMM/FontMM-diagnostics-*.txt`。

「附加系统字体日志」需要用户二次确认，会从 logcat 选取最多 160 行字体相关日志，其中可能包含应用名称、文件路径等敏感信息。分享前请自行检查。

可以在 GitHub Issues（https://github.com/zzexnn/FontMM/issues）报告问题：附上设备型号、ROM 版本、复现步骤、截图以及审阅后的诊断日志。也可使用酷安私信反馈。

独立单 ZIP；支持直接从 v2.0/v2.1 覆盖升级。仅面向 HyperOS 4 / Android 17，仍需 KernelSU/Magisk 的相应挂载和 Zygisk 环境；此新功能未经过所有机型真机测试，暂标为预发布版。
