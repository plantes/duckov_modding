# 🎯 从这里开始 - HeadshotTip Mod

欢迎使用 HeadshotTip（爆头击杀鼓励提示）Mod！

---

## 🚀 快速开始（仅需 3 步）

### 第 1 步：编译
双击运行：
```
build.bat
```

### 第 2 步：配置游戏路径
编辑 `deploy.bat` 文件，修改第 8 行：
```batch
set "GAME_PATH=你的游戏路径"
```

### 第 3 步：部署并测试
双击运行：
```
deploy.bat
```

然后：
1. 启动游戏
2. 主菜单 → Mods → 启用"爆头击杀鼓励提示"
3. 重启游戏
4. 游戏中按 **F8** 或 **F9** 测试

---

## 📚 文档导航

### 🔰 新手入门
- **[使用指南.md](使用指南.md)** ← 推荐从这里开始
  - 快速上手 3 步骤
  - 测试按键说明
  - 配置文件详解
  - 常见问题解答

### ⚡ 快速开发（5分钟）
- **[QUICKSTART.md](QUICKSTART.md)**
  - 最简化的开发流程
  - 反编译游戏代码
  - 快速修改和测试

### 📖 详细开发指南
- **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)**
  - 完整的开发流程
  - 3 种 Patch 实现方案
  - 性能优化和功能扩展
  - 发布到 Steam Workshop

### 📄 项目说明
- **[README.md](README.md)**
  - 功能介绍
  - 安装方法
  - 技术栈说明

### 📊 项目总结
- **[项目完成总结.md](项目完成总结.md)**
  - 完成内容清单
  - 项目统计
  - 文件清单

---

## 🎮 测试功能

当前为**测试版本**，提供按键测试：

| 按键 | 功能 |
|------|------|
| **F8** | 在玩家位置测试气泡 |
| **F9** | 在瞄准目标测试气泡 |
| **F10** | 显示当前配置 |

---

## 🔧 实用脚本

| 脚本 | 功能 | 何时使用 |
|------|------|---------|
| `build.bat` | 编译项目 | 修改代码后 |
| `deploy.bat` | 部署到游戏 | 编译完成后 |
| `clean.bat` | 清理编译输出 | 重新编译前 |
| `package.bat` | 打包发布版本 | 准备发布时 |
| `view-logs.bat` | 查看游戏日志 | 调试问题时 |

---

## ⚙️ 配置文件

### config.json
位置：`HeadshotTip\ReleaseExample\HeadshotTip\config.json`

可以自定义：
- 鼓励文字列表
- 显示时长
- 位置偏移
- 启用/禁用

修改后需要重启游戏！

---

## 🐛 遇到问题？

### 快速诊断
1. 运行 `view-logs.bat` 查看日志
2. 游戏中按 `F10` 查看配置是否加载
3. 按 `F8` 测试气泡是否显示

### 常见问题
- **编译失败**：检查游戏路径配置（HeadshotTip.csproj）
- **Mod 不显示**：检查文件是否完整（dll、ini、png）
- **按键无反应**：查看日志确认 Mod 是否加载
- **气泡不显示**：检查 config.json 格式和配置

### 详细解答
查看 [使用指南.md](使用指南.md) 的"常见问题"章节

---

## 📦 项目结构

```
headshot _tip/
│
├── 📜 文档（5个）
│   ├── START_HERE.md          ← 你在这里
│   ├── 使用指南.md             ← 推荐新手阅读
│   ├── QUICKSTART.md          ← 5分钟快速开始
│   ├── DEVELOPMENT_GUIDE.md   ← 详细开发指南
│   ├── README.md              ← 项目说明
│   └── 项目完成总结.md         ← 完成清单
│
├── 🔧 脚本（5个）
│   ├── build.bat              ← 编译
│   ├── deploy.bat             ← 部署
│   ├── clean.bat              ← 清理
│   ├── package.bat            ← 打包
│   └── view-logs.bat          ← 查看日志
│
└── 📂 HeadshotTip/            ← 源代码
    ├── ConfigManager.cs       ← 配置管理
    ├── ModBehaviour.cs        ← 主逻辑（测试版）
    ├── HeadshotTip.csproj     ← 项目配置
    └── ReleaseExample/        ← 发布文件
        └── HeadshotTip/
            ├── config.json    ← 用户配置
            ├── info.ini       ← Mod 信息
            └── preview.png    ← 预览图
```

---

## 🎯 开发路线图

### ✅ 已完成
- [x] 项目框架
- [x] 配置系统
- [x] 气泡显示功能
- [x] 测试按键系统
- [x] 自动化脚本
- [x] 完整文档
- [x] 预览图

### ⏳ 待完成
- [ ] 爆头击杀检测（需反编译游戏）
- [ ] 真实游戏测试
- [ ] 性能优化
- [ ] 发布到 Steam Workshop

### 💡 可选功能
- [ ] 连杀提示
- [ ] 音效支持
- [ ] 粒子特效
- [ ] 统计功能

---

## 📞 获取帮助

1. **查看文档**
   - [使用指南.md](使用指南.md) - 最详细
   - [QUICKSTART.md](QUICKSTART.md) - 最快速
   - [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - 最专业

2. **查看日志**
   - 运行 `view-logs.bat`
   - 位置：`%USERPROFILE%\AppData\LocalLow\TeamSoda\Duckov\Player.log`

3. **社区支持**
   - GitHub Issues
   - Steam 社区
   - Mod 开发交流

---

## ✨ 特别提示

### 对于新手
直接看 **[使用指南.md](使用指南.md)**，按步骤操作即可

### 对于开发者
看 **[QUICKSTART.md](QUICKSTART.md)**，5 分钟完成开发

### 对于高级用户
看 **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)**，了解所有细节

---

**祝你使用愉快！** 🎮

有问题随时查阅文档或寻求帮助！

---

*更新时间：2025-11-27*
*作者：三爷 + Claude Code*
