# FontMM for HyperOS 4 · v2.1 (non-official beta)

独立 ZIP，不需要先刷原版 FontMM。原作：[YuleBest/FontMM](https://github.com/YuleBest/FontMM)（Yule，GPL-3.0）；适配：zzexnn。

本版修复英文槽位“没有映射也报告成功”，增加 SourceSansPro / DroidSans 等常见西文目标。同时在显式设置独立英文字体时，由重新编译的 `fontmm-subset` 生成中文字体去西文字形副本，减少 MiSansVF 抢占拉丁字符的情况。原来的汉字字体文件不会被修改，未单独选英文时不执行任何西文字形剥离。

**可能的局限：** 字体 fallback 在不同 HyperOS ROM / 应用中不同；无西文字形副本依赖系统正确回退到已映射的英文目标，无法保证所有应用都使用该字体。若 ROM 没有可匹配西文目标，应用明确失败而非误报成功。高级 XML wght 映射仍未完整适配。

安装：HyperOS 4 / Android 17 (SDK 37)，KernelSU/Magisk。首次安装直接刷入本独立 ZIP；已有 v2 可覆盖升级并继承之前的字体选择，重启后进入 WebUI 选择字体、点击「应用字体」、再次重启。KernelSU 元模块和 Zygisk 提供者依系统环境提供。

**测试状态：** CI 检查包体、脚本、ARM64 字体工具构建，并模拟英文不存在、中文抢占的处理路径；仍无该版真机验证，请以预发布版对待。卡开机可尝试 KernelSU 安全模式或使用 root ADB 禁用 FontMM。
