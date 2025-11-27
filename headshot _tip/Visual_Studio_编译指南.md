# Visual Studio 编译指南

## 🚀 快速编译（5步完成）

### 第 1 步：检查游戏路径 ⚙️

1. 打开文件：`HeadshotTip\HeadshotTip.csproj`
2. 找到第 10 行：
   ```xml
   <DuckovPath>E:\Program Files (x86)\Steam\steamapps\common\Escape from Duckov</DuckovPath>
   ```

3. **如果你的游戏不在这个路径**，修改为实际路径

   **如何找到游戏路径：**
   - Steam → 库 → 右键"逃离鸭科夫" → 管理 → 浏览本地文件
   - 复制地址栏的路径

4. 保存文件

---

### 第 2 步：打开项目 📂

双击打开：
```
HeadshotTip.sln
```

Visual Studio 会自动打开项目。

**首次打开可能需要：**
- 还原 NuGet 包（会自动提示，点"还原"即可）
- 等待 IntelliSense 加载完成

---

### 第 3 步：切换到 Release 配置 🔧

在 Visual Studio 顶部工具栏：
- 找到配置下拉框（通常显示"Debug"）
- 切换为 **Release**

```
[Debug ▼]  改为  [Release ▼]
```

---

### 第 4 步：编译项目 🔨

方式 A（推荐）：
- 菜单栏 → **生成** → **生成解决方案**
- 快捷键：`Ctrl + Shift + B`

方式 B：
- 右键项目"HeadshotTip" → **生成**

**等待编译完成**，输出窗口会显示：
```
已成功生成 1 个
```

---

### 第 5 步：验证输出 ✅

编译成功后，检查以下文件夹：
```
HeadshotTip\ReleaseExample\HeadshotTip\
```

应该包含：
- ✅ `HeadshotTip.dll` ← 主要文件
- ✅ `0Harmony.dll` ← Harmony 库
- ✅ `Newtonsoft.Json.dll` ← JSON 库
- ✅ `config.json`
- ✅ `info.ini`
- ✅ `preview.png`

**现在可以使用了！**

---

## 📦 使用编译好的 Mod

### 方式 A：手动复制（推荐新手）

1. 复制整个文件夹：
   ```
   HeadshotTip\ReleaseExample\HeadshotTip\
   ```

2. 粘贴到游戏 Mods 目录：
   ```
   {游戏目录}\Duckov_Data\Mods\
   ```

   最终路径应该是：
   ```
   {游戏目录}\Duckov_Data\Mods\HeadshotTip\
   ```

3. 启动游戏，在主菜单 → Mods → 启用"爆头击杀鼓励提示"

4. 重启游戏

5. 游戏中按 **F8** 或 **F9** 测试

---

### 方式 B：使用部署脚本（推荐熟手）

1. 编辑 `deploy.bat`，修改第 8 行游戏路径

2. 双击运行 `deploy.bat`

3. 按提示操作

---

## 🐛 常见编译问题

### 问题 1：找不到类型 'TeamSoda'

**错误信息**：
```
error CS0246: The type or namespace name 'TeamSoda' could not be found
```

**原因**：游戏路径配置错误

**解决**：
1. 检查 `HeadshotTip.csproj` 中的 `<DuckovPath>`
2. 确认路径正确且游戏已安装
3. 检查 `{游戏路径}\Duckov_Data\Managed\` 是否存在
4. 重新生成项目

---

### 问题 2：无法还原 NuGet 包

**错误信息**：
```
Unable to find package Lib.Harmony
```

**解决**：
1. 菜单栏 → 工具 → NuGet 包管理器 → 程序包管理器控制台
2. 输入命令：
   ```
   Update-Package -reinstall
   ```
3. 等待完成后重新生成

---

### 问题 3：编译成功但没有输出文件

**检查**：
1. 输出窗口是否真的显示"成功"
2. 是否选择了 **Release** 配置（不是 Debug）
3. 查看 `HeadshotTip\bin\Release\netstandard2.1\` 是否有文件
   - 如果有，说明输出路径配置问题
   - 检查 `.csproj` 中的 `<OutputPath>`

---

### 问题 4：引用错误 - Unity DLL 找不到

**错误信息**：
```
Cannot resolve reference UnityEngine
```

**解决**：
1. 确认游戏路径中 `Duckov_Data\Managed\` 文件夹存在
2. 确认该文件夹包含 `UnityEngine.dll` 等文件
3. 尝试：右键项目 → 属性 → 引用路径 → 检查路径

---

## 🔧 高级配置

### 修改输出路径

如果想改变输出位置，编辑 `.csproj` 文件：

```xml
<!-- 默认配置 -->
<OutputPath>ReleaseExample\HeadshotTip\</OutputPath>

<!-- 改为其他位置（示例） -->
<OutputPath>C:\MyMods\HeadshotTip\</OutputPath>
```

---

### 添加后期生成事件

自动复制到游戏目录：

1. 右键项目 → 属性 → 生成事件
2. 在"后期生成事件命令行"添加：

```batch
xcopy /Y /E "$(ProjectDir)ReleaseExample\HeadshotTip\*" "你的游戏路径\Duckov_Data\Mods\HeadshotTip\"
```

每次编译后会自动复制到游戏。

---

## 📊 项目结构说明

```
HeadshotTip/
├── ConfigManager.cs          # 配置管理（源代码）
├── ModBehaviour.cs           # 主逻辑（源代码）
├── HeadshotTip.csproj        # 项目配置
│
├── bin/                      # 编译临时输出
│   └── Release/
│       └── netstandard2.1/
│           └── HeadshotTip.dll
│
└── ReleaseExample/           # 最终输出（用于发布）
    └── HeadshotTip/
        ├── HeadshotTip.dll   ← 编译后自动复制到这里
        ├── 0Harmony.dll      ← NuGet 包自动复制
        ├── Newtonsoft.Json.dll ← NuGet 包自动复制
        ├── config.json       ← 手动创建
        ├── info.ini          ← 手动创建
        └── preview.png       ← 手动添加
```

**ReleaseExample** 文件夹就是完整的 Mod，可以直接复制到游戏使用！

---

## ✅ 编译成功检查清单

编译完成后，确认以下文件都存在：

- [ ] `HeadshotTip.dll` (约 10-20 KB)
- [ ] `0Harmony.dll` (约 170 KB)
- [ ] `Newtonsoft.Json.dll` (约 700 KB)
- [ ] `config.json`
- [ ] `info.ini`
- [ ] `preview.png`

**全部存在 = 可以使用！** ✅

---

## 🎯 下一步

编译成功后：

1. **立即测试**
   - 复制到游戏 Mods 文件夹
   - 启动游戏启用 Mod
   - 游戏中按 F8/F9 测试

2. **修改配置**
   - 编辑 `config.json`
   - 自定义鼓励文字

3. **实现真实检测**
   - 参考 [QUICKSTART.md](QUICKSTART.md)
   - 反编译游戏找爆头方法
   - 修改 `ModBehaviour.cs`

4. **分享**
   - 使用 `package.bat` 打包
   - 上传到 Steam Workshop

---

## 💡 提示

### 快速重新编译

修改代码后：
1. 保存文件（`Ctrl + S`）
2. 按 `Ctrl + Shift + B` 重新编译
3. 如果游戏正在运行，需要重启游戏加载新版本

### 调试技巧

1. **查看编译输出**
   - 视图 → 输出（`Ctrl + W, O`）
   - 查看详细的编译过程和错误

2. **查看错误列表**
   - 视图 → 错误列表（`Ctrl + \, E`）
   - 双击错误可跳转到代码位置

3. **清理后重新生成**
   - 如果遇到奇怪问题
   - 生成 → 清理解决方案
   - 生成 → 重新生成解决方案

---

## 📞 需要帮助？

- **编译问题**：查看本文档的"常见编译问题"
- **使用问题**：查看 [使用指南.md](使用指南.md)
- **开发问题**：查看 [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)

---

**祝编译顺利！** 🎉

编译成功后就可以立即在游戏中使用了！
