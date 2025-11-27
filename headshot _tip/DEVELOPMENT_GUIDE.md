# HeadshotTip 开发指南

本文档详细说明如何完成 HeadshotTip Mod 的开发。

## 当前进度

### ✅ 已完成
- [x] 项目结构创建
- [x] ConfigManager 配置管理系统
- [x] ModBehaviour 框架代码
- [x] Harmony 集成
- [x] 气泡对话框显示逻辑
- [x] info.ini 和 config.json

### ⏳ 待完成
- [ ] 爆头击杀事件检测（关键）
- [ ] 实际测试和调试
- [ ] 预览图制作
- [ ] 性能优化

---

## 第一步：反编译游戏代码

### 工具准备

下载并安装以下工具之一：
- **ILSpy** (推荐): https://github.com/icsharpcode/ILSpy/releases
- **dnSpy**: https://github.com/dnSpy/dnSpy/releases

### 反编译步骤

1. **打开游戏 DLL**
   - 启动 ILSpy 或 dnSpy
   - 打开文件：`{游戏目录}\Duckov_Data\Managed\`
   - 加载所有 `TeamSoda.*.dll` 文件

2. **查找关键类**

   需要查找以下内容：

   #### a) CharacterMainControl 类
   ```csharp
   // 查找死亡相关方法，可能的名称：
   - OnDeath()
   - Die()
   - HandleDeath()
   - OnKilled()
   - ProcessDeath()
   ```

   #### b) Health 或 DamageSystem 类
   ```csharp
   // 查找伤害处理方法，可能的名称：
   - TakeDamage()
   - ApplyDamage()
   - ReceiveDamage()
   - OnDamage()
   ```

   #### c) 伤害信息结构
   ```csharp
   // 查找是否有类似的结构：
   class DamageInfo {
       bool isHeadshot;
       bool isHeadshotKill;
       HitLocation hitLocation;
       BodyPart bodyPart;
       // ...
   }
   ```

3. **记录方法签名**

   将找到的方法完整签名记录下来，例如：
   ```csharp
   // 示例 1
   public void OnDeath(DamageInfo damageInfo, Transform killer)

   // 示例 2
   public void TakeDamage(float amount, bool isHeadshot, Vector3 hitPoint)

   // 示例 3
   public void HandleKill(CharacterMainControl victim, WeaponType weapon, bool headshot)
   ```

---

## 第二步：修改 Harmony Patch

根据第一步找到的方法，修改 `ModBehaviour.cs` 中的 Patch。

### 示例场景 1：找到了 OnDeath 方法

**假设找到的方法**：
```csharp
namespace TeamSoda.Character
{
    public class CharacterMainControl
    {
        public void OnDeath(DamageInfo damageInfo)
        {
            // 游戏代码...
        }
    }
}

public class DamageInfo
{
    public bool isHeadshot;
    public Transform attacker;
    // ...
}
```

**修改 ModBehaviour.cs**：

在 `ModBehaviour.cs` 中找到 `CharacterMainControl_Death_Patch` 类，取消注释并修改：

```csharp
[HarmonyPatch(typeof(TeamSoda.Character.CharacterMainControl), "OnDeath")]
[HarmonyPostfix]
static void Postfix(TeamSoda.Character.CharacterMainControl __instance, DamageInfo damageInfo)
{
    try
    {
        // 检查是否为爆头击杀
        if (damageInfo != null && damageInfo.isHeadshot)
        {
            Debug.Log("[HeadshotTip] 检测到爆头击杀！");
            ShowHeadshotTip(__instance.transform);
        }
    }
    catch (Exception ex)
    {
        Debug.LogError($"[HeadshotTip] Patch 错误: {ex.Message}");
    }
}
```

### 示例场景 2：找到了 TakeDamage 方法

**假设找到的方法**：
```csharp
public class Health : MonoBehaviour
{
    public bool isDead;

    public void TakeDamage(float amount, HitLocation location, Transform attacker)
    {
        // 游戏代码...
    }
}

public enum HitLocation
{
    Body,
    Head,
    Leg,
    Arm
}
```

**修改 ModBehaviour.cs**：

```csharp
[HarmonyPatch(typeof(Health), "TakeDamage")]
[HarmonyPostfix]
static void Postfix(Health __instance, float amount, HitLocation location, Transform attacker)
{
    try
    {
        // 检查是否死亡且击中头部
        if (__instance.isDead && location == HitLocation.Head)
        {
            Debug.Log("[HeadshotTip] 检测到爆头击杀！");
            ShowHeadshotTip(__instance.transform);
        }
    }
    catch (Exception ex)
    {
        Debug.LogError($"[HeadshotTip] Patch 错误: {ex.Message}");
    }
}
```

### 示例场景 3：找到了击杀事件

某些游戏会有专门的击杀事件系统：

```csharp
public class KillEventManager
{
    public static event Action<KillInfo> OnKill;
}

public class KillInfo
{
    public CharacterMainControl victim;
    public CharacterMainControl killer;
    public bool isHeadshot;
    public WeaponType weapon;
}
```

**订阅事件方式**：

```csharp
void Awake()
{
    // ... 其他初始化代码 ...

    // 订阅击杀事件
    KillEventManager.OnKill += OnKillEvent;
}

void OnDestroy()
{
    // 取消订阅
    KillEventManager.OnKill -= OnKillEvent;

    // ... 其他清理代码 ...
}

private void OnKillEvent(KillInfo killInfo)
{
    if (killInfo.isHeadshot && configManager.IsEnabled)
    {
        ShowHeadshotTip(killInfo.victim.transform);
    }
}
```

---

## 第三步：编译项目

### 使用 Visual Studio

1. 打开 `HeadshotTip.sln`
2. 确认 `DuckovPath` 设置正确
3. 选择 `Release` 配置
4. 点击 `生成` → `生成解决方案`

### 使用命令行

```bash
cd "E:\work\0duckov_modding\headshot _tip"
dotnet build HeadshotTip.sln -c Release
```

### 编译输出

成功编译后，文件会输出到：
```
HeadshotTip/ReleaseExample/HeadshotTip/
├── HeadshotTip.dll       # 主 DLL
├── 0Harmony.dll          # Harmony 库
├── Newtonsoft.Json.dll   # JSON 库
├── info.ini
├── config.json
└── preview.png (需要手动添加)
```

---

## 第四步：测试 Mod

### 部署到游戏

1. **复制文件夹**
   ```bash
   # Windows
   xcopy /E /I "HeadshotTip\ReleaseExample\HeadshotTip" "{游戏目录}\Duckov_Data\Mods\HeadshotTip"

   # macOS/Linux
   cp -r "HeadshotTip/ReleaseExample/HeadshotTip" "{游戏目录}/Duckov.app/Contents/Mods/HeadshotTip"
   ```

2. **启动游戏**
   - 进入主菜单
   - 点击 "Mods"
   - 找到 "爆头击杀鼓励提示"
   - 启用 Mod
   - 重启游戏

3. **测试功能**
   - 开始游戏
   - 尝试爆头击杀敌人
   - 观察是否显示气泡对话框

### 查看日志

**Windows**:
```bash
type "C:\Users\{用户名}\AppData\LocalLow\TeamSoda\Duckov\Player.log" | findstr HeadshotTip
```

**macOS/Linux**:
```bash
cat "~/Library/Logs/TeamSoda/Duckov/Player.log" | grep HeadshotTip
```

### 调试技巧

#### 1. 启用测试模式

在 `ModBehaviour.cs` 中取消注释测试 Patch：

```csharp
[HarmonyPatch(typeof(CharacterMainControl), "Update")]
[HarmonyPostfix]
static void TestPatch(CharacterMainControl __instance)
{
    // 按 F8 显示测试提示
    if (Input.GetKeyDown(KeyCode.F8))
    {
        Debug.Log("[HeadshotTip] 测试键按下");
        ShowHeadshotTip(__instance.transform);
    }
}
```

重新编译，游戏中按 `F8` 测试气泡显示是否正常。

#### 2. 添加调试日志

在关键位置添加日志输出：

```csharp
[HarmonyPostfix]
static void Postfix(CharacterMainControl __instance, DamageInfo damageInfo)
{
    Debug.Log($"[HeadshotTip] OnDeath 被调用");
    Debug.Log($"[HeadshotTip] damageInfo: {damageInfo}");
    Debug.Log($"[HeadshotTip] isHeadshot: {damageInfo?.isHeadshot}");

    if (damageInfo != null && damageInfo.isHeadshot)
    {
        Debug.Log("[HeadshotTip] 触发爆头提示");
        ShowHeadshotTip(__instance.transform);
    }
}
```

#### 3. 验证 Harmony Patch 是否生效

```csharp
void Awake()
{
    // ... 初始化代码 ...

    harmony.PatchAll();

    // 打印所有已应用的 Patch
    var patches = Harmony.GetAllPatchedMethods();
    foreach (var method in patches)
    {
        Debug.Log($"[HeadshotTip] Patched: {method.DeclaringType?.Name}.{method.Name}");
    }
}
```

---

## 第五步：优化和完善

### 性能优化

1. **避免频繁对象创建**
   ```csharp
   // 不好的做法
   await DialogueBubblesManager.Show(new string("文本"), ...);

   // 好的做法
   string message = config.GetRandomMessage(); // 复用
   await DialogueBubblesManager.Show(message, ...);
   ```

2. **限制触发频率**
   ```csharp
   private static float lastTriggerTime = 0;
   private const float MIN_INTERVAL = 0.5f; // 最小间隔 0.5 秒

   private static async void ShowHeadshotTip(Transform enemyTransform)
   {
       float currentTime = Time.time;
       if (currentTime - lastTriggerTime < MIN_INTERVAL)
       {
           return; // 太频繁，跳过
       }
       lastTriggerTime = currentTime;

       // ... 显示逻辑 ...
   }
   ```

### 功能扩展

1. **添加音效**
   ```csharp
   private static AudioClip headshotSound;

   private static async void ShowHeadshotTip(Transform enemyTransform)
   {
       // 显示对话框
       await DialogueBubblesManager.Show(...);

       // 播放音效
       if (headshotSound != null)
       {
           AudioSource.PlayClipAtPoint(headshotSound, enemyTransform.position);
       }
   }
   ```

2. **添加特效**
   ```csharp
   // 在爆头位置生成粒子特效
   GameObject particle = Instantiate(particlePrefab, enemyTransform.position, Quaternion.identity);
   Destroy(particle, 2f);
   ```

3. **统计功能**
   ```csharp
   public class HeadshotStats
   {
       public int totalHeadshots = 0;
       public int currentStreak = 0;
       public int maxStreak = 0;
   }

   private static void OnHeadshot()
   {
       stats.totalHeadshots++;
       stats.currentStreak++;
       stats.maxStreak = Mathf.Max(stats.maxStreak, stats.currentStreak);

       // 连杀特殊消息
       if (stats.currentStreak >= 5)
       {
           ShowHeadshotTip(enemyTransform, "连杀！！！");
       }
   }
   ```

---

## 常见问题

### Q1: 编译时找不到游戏 DLL

**错误**:
```
error CS0246: The type or namespace name 'TeamSoda' could not be found
```

**解决方案**:
1. 检查 `DuckovPath` 是否正确
2. 确认游戏已安装
3. 检查 DLL 文件是否存在于 `{DuckovPath}\Duckov_Data\Managed\`

### Q2: Mod 不显示在游戏中

**检查清单**:
1. 文件夹名称是否为 `HeadshotTip`（与 info.ini 中的 name 一致）
2. 是否包含 `HeadshotTip.dll`、`info.ini`、`preview.png`
3. 文件夹是否在正确位置：`Duckov_Data\Mods\HeadshotTip\`

### Q3: Patch 没有生效

**调试步骤**:
1. 查看日志中是否有 "Harmony Patches 应用成功"
2. 检查 Patch 的类型和方法名是否正确
3. 确认方法签名（参数类型、顺序）是否匹配
4. 尝试使用 `[HarmonyPrefix]` 代替 `[HarmonyPostfix]`

### Q4: 气泡对话框不显示

**可能原因**:
1. `enemyTransform` 为 null - 添加 null 检查
2. `config.IsEnabled` 为 false - 检查 config.json
3. UniTask 异常 - 查看日志中的错误信息

### Q5: 游戏崩溃

**排查步骤**:
1. 查看 `Player-prev.log`（上次运行的日志）
2. 检查是否有空引用异常
3. 确认 async 方法使用正确
4. 暂时禁用 Mod，确认是否为 Mod 导致

---

## 预览图制作

### 要求
- 尺寸：256x256 像素（正方形）
- 格式：PNG
- 内容：展示 Mod 效果的游戏截图

### 制作步骤
1. 启用 Mod 进入游戏
2. 触发爆头击杀，使气泡对话框显示
3. 截图（确保包含气泡对话框）
4. 使用图片编辑软件裁剪为 256x256
5. 保存为 `preview.png`
6. 放置在 `ReleaseExample/HeadshotTip/` 目录

### 推荐工具
- **截图**: Windows 截图工具、macOS 截图
- **编辑**: GIMP、Paint.NET、Photoshop

---

## 发布到 Steam 创意工坊

### 准备工作
1. 确保 `info.ini` 完整
2. 添加 `preview.png`
3. 测试 Mod 功能正常
4. 准备详细的描述文本

### 上传步骤
1. 启动游戏
2. 主菜单 → Mods → Workshop
3. 选择"上传新 Mod"
4. 选择 `ReleaseExample/HeadshotTip` 文件夹
5. 填写描述和标签
6. 点击发布

### 注意事项
⚠️ Steam Workshop 会覆写 `info.ini`，不要在其中存储自定义数据

---

## 下一步计划

- [ ] 反编译游戏代码，找到爆头击杀相关方法
- [ ] 修改 Harmony Patch，实现爆头检测
- [ ] 编译并测试 Mod
- [ ] 制作预览图
- [ ] 发布到 Steam 创意工坊
- [ ] 收集用户反馈，持续优化

---

**祝开发顺利！** 🎯

如有问题，请查看：
- [游戏 API 参考](../0template/API_Reference.md)
- [Harmony 文档](https://harmony.pardeike.net/articles/intro.html)
- [Unity 脚本文档](https://docs.unity3d.com/ScriptReference/)
