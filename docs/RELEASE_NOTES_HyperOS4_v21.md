# FontMM for HyperOS 4 · v2.1.0 (Standalone, non-official beta)

**修复英文字体可能失效**，仍为单 ZIP 独立安装版；可以直接覆盖 v2，并保留用户已设置的字体。

- 英文独立槽位加入覆盖前预检查、独立覆盖统计，**未匹配到英文路径时明确失败，不再误报“应用成功”**。
- 新增 SourceSansPro、DroidSans 等已知英文字体名。
- 显式选择 `en.ttf` 时，使用 HarfBuzz 子集工具生成中文字体的“无西文字形副本”，减少中文字体含拉丁字形导致系统不回退英文槽位的情况；原始字体保留。
- 未设置英文字体时不执行 Latin 字形剥离；可变字体 `wght` 轴由 HarfBuzz 子集工具保留。
- 自测范围：CI 编译 Android ARM64 子集工具、通过 ZIP 结构校验、Shell 语法与模拟 ROM 英文缺失/替换/重复应用测试。**尚未经过 HyperOS 4 真机验证，仍属预发布版。**
- 部分应用自带字体、MiSans 定制字体框架仍可能有差异；原版高级 XML 自定义字重映射尚未完整适配。

安装：HyperOS 4 / Android 17，KernelSU 或 Magisk。下载 `FontMM_HyperOS4_Standalone_v2.1.zip` 直接刷入，重启后在 FontMM WebUI 设置中英文并点击应用，重启生效。已有 v2 用户直接覆盖即可。

上游：[YuleBest/FontMM](https://github.com/YuleBest/FontMM)，原作者 Yule，GPL-3.0；非官方适配：[zzexnn/FontMM](https://github.com/zzexnn/FontMM)。
