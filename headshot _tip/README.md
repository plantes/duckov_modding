# HeadshotTip - 爆头击杀鼓励提示

每次爆头击杀敌人时，在敌人头上显示随机鼓励文字的 Mod。

![Preview](HeadshotTip/ReleaseExample/HeadshotTip/preview.png)

## 功能特性

- ✅ 爆头击杀时自动显示气泡对话框
- ✅ 随机显示鼓励文字（"三爷好棒"、"三爷V5"、"三爷牛逼"等）
- ✅ 可通过配置文件自定义文字列表
- ✅ 可调整显示时长和位置

## 安装方法

### 方式一：Steam 创意工坊（推荐）
1. 在 Steam 创意工坊中订阅此 Mod
2. 启动游戏，在主菜单的 "Mods" 中启用

### 方式二：手动安装
1. 下载 `HeadshotTip` 文件夹
2. 将整个文件夹复制到游戏目录：
   - Windows: `{游戏目录}\Duckov_Data\Mods\`
   - macOS: `{游戏目录}/Duckov.app/Contents/Mods/`
3. 启动游戏，在 Mods 菜单中启用

## 配置说明

Mod 文件夹中的 `config.json` 可以自定义设置：

```json
{
  "enabled": true,          // 是否启用 Mod
  "duration": 2.0,          // 对话框显示时长（秒）
  "yOffset": 1.5,           // 对话框垂直偏移（相对敌人位置）
  "messages": [             // 自定义鼓励文字列表
    "三爷好棒",
    "三爷V5",
    "三爷牛逼"
  ]
}
```

修改配置后重启游戏生效。

## 开发状态

⚠️ **当前为初始版本，需要进一步开发**

### 已完成
- ✅ 项目结构和配置系统
- ✅ 气泡对话框显示逻辑
- ✅ 配置文件读取和管理
- ✅ Harmony 框架集成

### 待完成
- ⏳ 爆头击杀事件检测（需要反编译游戏代码）
- ⏳ 实际游戏测试和调试
- ⏳ 预览图制作

### 下一步开发

1. **反编译游戏 DLL**
   - 使用 ILSpy 或 dnSpy 打开 `{游戏目录}\Duckov_Data\Managed\TeamSoda.*.dll`
   - 查找以下相关内容：
     - `CharacterMainControl` 类的死亡相关方法
     - `Health` 或 `DamageSystem` 类
     - 伤害信息结构（是否包含爆头标识）

2. **修改 Harmony Patch**
   - 在 `ModBehaviour.cs` 中取消注释对应的 Patch
   - 根据实际方法签名调整参数
   - 添加爆头检测逻辑

3. **编译和测试**
   ```bash
   # 在 headshot _tip 目录下
   dotnet build HeadshotTip.sln
   ```

4. **部署测试**
   - 将 `ReleaseExample/HeadshotTip/` 复制到游戏 Mods 目录
   - 启动游戏测试功能
   - 查看日志：`AppData\LocalLow\TeamSoda\Duckov\Player.log`

## 开发说明

### 项目结构
```
headshot _tip/
├── HeadshotTip/
│   ├── ModBehaviour.cs          # 主逻辑和 Harmony Patches
│   ├── ConfigManager.cs         # 配置管理
│   ├── HeadshotTip.csproj       # 项目配置
│   └── ReleaseExample/
│       └── HeadshotTip/
│           ├── HeadshotTip.dll  # 编译输出（自动生成）
│           ├── info.ini          # Mod 元数据
│           ├── config.json       # 用户配置
│           └── preview.png       # 预览图（待添加）
└── HeadshotTip.sln              # 解决方案文件
```

### 依赖库
- **0Harmony (v2.4.1)** - 运行时方法 Hook
- **Newtonsoft.Json (v13.0.3)** - JSON 配置解析
- **游戏 DLL** - TeamSoda.*, Unity*, ItemStatsSystem.dll

### 修改配置路径

如果你的游戏安装在不同位置，修改 `HeadshotTip.csproj` 中的 `DuckovPath`：

```xml
<!-- Windows -->
<DuckovPath>你的游戏路径</DuckovPath>

<!-- macOS -->
<DuckovPath Condition="'$(IsMac)'">你的游戏路径</DuckovPath>
```

## 调试技巧

1. **查看日志**
   - Windows: `C:\Users\{用户名}\AppData\LocalLow\TeamSoda\Duckov\Player.log`
   - macOS: `~/Library/Logs/TeamSoda/Duckov/Player.log`

2. **启用测试模式**
   - 在 `ModBehaviour.cs` 中取消注释测试 Patch
   - 游戏中按 `F8` 键触发测试提示

3. **常见问题**
   - Mod 未显示：检查文件夹名称是否与 info.ini 中的 name 一致
   - 编译失败：检查 DuckovPath 是否正确
   - 运行时错误：查看 Player.log 中的错误堆栈

## 技术参考

- [游戏 Mod 开发文档](../0template/API_Reference.md)
- [Harmony 文档](https://harmony.pardeike.net/)
- [游戏 API 参考](../0template/Documents/NotableAPIs_CN.md)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可

本 Mod 仅供学习交流使用，请遵守游戏社区规则。

---

**作者**: 三爷
**版本**: v0.1.0 (开发中)
**更新日期**: 2025-11-27
