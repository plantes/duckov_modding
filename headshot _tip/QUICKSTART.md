# HeadshotTip - 快速开始

## 🚀 5分钟快速开发指南

### 第 1 步：安装反编译工具（2分钟）

下载并安装 **ILSpy**：
- 下载地址：https://github.com/icsharpcode/ILSpy/releases
- 下载 `ILSpy_Installer_*.msi` 并安装

### 第 2 步：查找游戏代码（2分钟）

1. **打开 ILSpy**
2. **加载游戏 DLL**
   - 点击 `File` → `Open`
   - 导航到：`{游戏目录}\Duckov_Data\Managed\`
   - 选择所有 `TeamSoda.*.dll` 文件并打开

3. **搜索关键方法**

   在 ILSpy 搜索框中搜索以下关键词：

   **方式 A：搜索 "headshot"**
   ```
   搜索: headshot
   查找包含 headshot 的属性、方法、类
   ```

   **方式 B：搜索 "OnDeath"**
   ```
   搜索: OnDeath
   查找角色死亡相关方法
   ```

   **方式 C：搜索 "TakeDamage"**
   ```
   搜索: TakeDamage
   查找伤害处理方法
   ```

4. **记录方法信息**

   找到相关方法后，记录完整信息：
   ```csharp
   // 示例：
   类名: TeamSoda.Character.CharacterHealth
   方法名: OnDeath
   参数: (DamageInfo damageInfo)

   // DamageInfo 包含:
   - bool isHeadshot
   - Transform attacker
   ```

### 第 3 步：修改代码（1分钟）

打开 `HeadshotTip\ModBehaviour.cs`，找到这段代码：

```csharp
[HarmonyPatch]
public static class CharacterMainControl_Death_Patch
{
    // TODO: 反编译游戏代码后，替换为实际的方法名
```

**根据第 2 步找到的信息修改：**

```csharp
// 假设你找到的方法是：
// TeamSoda.Character.CharacterHealth.OnDeath(DamageInfo damageInfo)

[HarmonyPatch(typeof(TeamSoda.Character.CharacterHealth), "OnDeath")]
[HarmonyPostfix]
static void Postfix(CharacterHealth __instance, DamageInfo damageInfo)
{
    try
    {
        // 检查是否为爆头击杀
        if (damageInfo != null && damageInfo.isHeadshot)
        {
            Debug.Log("[HeadshotTip] 爆头击杀！");
            ShowHeadshotTip(__instance.transform);
        }
    }
    catch (Exception ex)
    {
        Debug.LogError($"[HeadshotTip] 错误: {ex.Message}");
    }
}
```

**如果找不到 isHeadshot 属性，尝试：**

```csharp
// 方案 B：检查击中部位
if (damageInfo.hitLocation == HitLocation.Head && __instance.isDead)
{
    ShowHeadshotTip(__instance.transform);
}

// 方案 C：检查伤害类型
if (damageInfo.damageType == DamageType.Headshot)
{
    ShowHeadshotTip(__instance.transform);
}
```

### 第 4 步：编译测试

**编译项目：**
```bash
cd "E:\work\0duckov_modding\headshot _tip"
dotnet build HeadshotTip.sln -c Release
```

**复制到游戏：**
```bash
# 替换为你的游戏路径
xcopy /E /I "HeadshotTip\ReleaseExample\HeadshotTip" "C:\Games\Duckov\Duckov_Data\Mods\HeadshotTip"
```

**启动游戏测试！**

---

## 📋 快速检查清单

- [ ] ILSpy 已安装
- [ ] 找到了爆头相关的方法
- [ ] 修改了 ModBehaviour.cs 的 Patch
- [ ] 编译成功（无错误）
- [ ] 文件已复制到游戏 Mods 目录
- [ ] 在游戏中启用了 Mod
- [ ] 测试爆头击杀是否显示提示

---

## 🐛 快速调试

### 问题 1：编译失败 - 找不到类型

**错误信息：**
```
error CS0246: The type or namespace name 'TeamSoda' could not be found
```

**解决：**
检查 `HeadshotTip.csproj` 中的 `DuckovPath` 是否正确：
```xml
<DuckovPath>你的游戏实际路径</DuckovPath>
```

### 问题 2：Mod 不显示

**检查：**
1. 文件夹名称是否为 `HeadshotTip`
2. 是否包含：HeadshotTip.dll、info.ini、preview.png（可用任意图片）

### 问题 3：没有提示显示

**启用测试模式：**

在 `ModBehaviour.cs` 最后添加（取消注释）：

```csharp
[HarmonyPatch(typeof(UnityEngine.MonoBehaviour), "Update")]
[HarmonyPostfix]
static void TestPatch()
{
    if (Input.GetKeyDown(KeyCode.F8))
    {
        Debug.Log("[HeadshotTip] 测试！");
        // 找到玩家角色
        var player = GameObject.FindObjectOfType<CharacterMainControl>();
        if (player != null)
        {
            ShowHeadshotTip(player.transform);
        }
    }
}
```

重新编译，游戏中按 `F8` 测试。

---

## 📝 查看日志

**Windows：**
```bash
notepad "%USERPROFILE%\AppData\LocalLow\TeamSoda\Duckov\Player.log"
```

**搜索日志中的关键信息：**
```
[HeadshotTip] Mod 已加载
[HeadshotTip] 配置加载完成
[HeadshotTip] Harmony Patches 应用成功
```

---

## ❓ 还是不行？

### 最简单的测试方法

1. **禁用所有 Patch**，只测试基本加载：

   在 `ModBehaviour.cs` 的 `Awake()` 中注释掉：
   ```csharp
   // harmony.PatchAll();  // 先注释掉
   ```

2. **添加简单测试**：
   ```csharp
   void Update()
   {
       if (Input.GetKeyDown(KeyCode.F9))
       {
           Debug.Log("[HeadshotTip] F9 按下！");
           string msg = configManager.GetRandomMessage();
           Debug.Log($"[HeadshotTip] 消息: {msg}");
       }
   }
   ```

3. **重新编译测试**，游戏中按 F9，查看日志是否有输出。

---

## 🎯 成功标志

当你看到游戏日志中出现：
```
[HeadshotTip] Mod 已加载
[HeadshotTip] 配置加载完成
[HeadshotTip] Harmony Patches 应用成功
```

并且爆头击杀时能看到气泡对话框显示 "三爷好棒" 等文字，就成功了！

---

## 📚 详细文档

如需更多帮助，查看：
- [完整开发指南](DEVELOPMENT_GUIDE.md)
- [README](README.md)
- [API 参考](../0template/API_Reference.md)

**Good Luck!** 🎮
