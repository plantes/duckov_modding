# 逃离鸭科夫 Mod 开发 API 完整参考文档

> 本文档整合了官方文档、社区示例和实际代码分析，为 mod 开发者提供完整的 API 参考。
>
> 最后更新：2025-11-27

---

## 目录

- [一、物品系统 API](#一物品系统-api)
- [二、角色系统 API](#二角色系统-api)
- [三、对话系统 API](#三对话系统-api)
- [四、UI 系统 API](#四ui-系统-api)
- [五、本地化 API](#五本地化-api)
- [六、工具类 API](#六工具类-api)
- [七、Unity 生命周期](#七unity-生命周期)
- [八、高级功能](#八高级功能)
- [九、社区资源](#九社区资源)
- [十、常见问题](#十常见问题)

---

## 一、物品系统 API

### 1.1 ItemAssetsCollection - 物品生成

**命名空间**: `ItemStatsSystem`

#### 异步生成物品（推荐）

```csharp
public static async UniTask<Item> InstantiateAsync(int typeID)
```

**参数**:
- `typeID` - 物品类型 ID（可以从游戏数据中查找）

**返回**: `UniTask<Item>` - 生成的物品实例

**示例**:
```csharp
using ItemStatsSystem;
using Cysharp.Threading.Tasks;

// 生成一个 Glick (Item #254)
Item glick = await ItemAssetsCollection.InstantiateAsync(254);

// 将物品送给玩家
ItemUtilities.SendToPlayer(glick);
```

#### 同步生成物品

```csharp
public static Item InstantiateSync(int typeID)
```

**注意**: 仅在无法使用异步的情况下使用，可能造成性能问题。

**示例**:
```csharp
Item item = ItemAssetsCollection.InstantiateSync(100);
```

#### 自定义物品管理

```csharp
// 添加自定义物品到游戏
public static void AddDynamicEntry(Item prefab)

// 移除自定义物品
public static void RemoveDynamicEntry(Item prefab)
```

**重要事项**:
- 自定义物品的 prefab 必须配置唯一的 TypeID
- TypeID 应避免与游戏本体和其他 MOD 冲突
- 如果进入游戏时未加载对应 MOD，存档中的自定义物品会直接消失

**示例**:
```csharp
// 在 ModBehaviour.Start() 中添加自定义物品
void Start()
{
    Item myCustomItem = CreateCustomItemPrefab();
    ItemStatsSystem.ItemAssetsCollection.AddDynamicEntry(myCustomItem);
}

// 在 ModBehaviour.OnDestroy() 中移除
void OnDestroy()
{
    ItemStatsSystem.ItemAssetsCollection.RemoveDynamicEntry(myCustomItem);
}
```

---

### 1.2 ItemUtilities - 物品操作工具

**命名空间**: `ItemStatsSystem`

#### 发送物品给玩家

```csharp
// 发送给玩家并自动选择存储位置
public static void SendToPlayer(Item item, bool dontMerge = false, bool sendToStorage = true)

// 发送到玩家角色（包括背包和装备）
public static bool SendToPlayerCharacter(Item item, bool dontMerge = false)

// 仅发送到玩家背包
public static bool SendToPlayerCharacterInventory(Item item, bool dontMerge = false)
```

**参数**:
- `item` - 要发送的物品
- `dontMerge` - 是否禁止与现有物品合并（默认 false）
- `sendToStorage` - 背包满时是否发送到仓库（默认 true）

**返回**: `bool` - 是否成功发送

**示例**:
```csharp
Item coin = await ItemAssetsCollection.InstantiateAsync(1); // 假设1是货币ID
ItemUtilities.SendToPlayer(coin); // 自动处理存储位置
```

#### 检查物品位置

```csharp
// 检查物品是否在玩家角色上（背包或装备）
public static bool IsInPlayerCharacter(this Item item)

// 检查物品是否在玩家仓库中
public static bool IsInPlayerStorage(this Item item)
```

**示例**:
```csharp
if (item.IsInPlayerCharacter())
{
    Debug.Log("物品在玩家身上");
}

if (item.IsInPlayerStorage())
{
    Debug.Log("物品在仓库中");
}
```

#### 物品插槽操作

```csharp
public static bool TryPlug(
    this Item main,              // 主物品
    Item part,                   // 要插入的零件
    bool emptyOnly = false,      // 仅插入空槽位
    Inventory backupInventory = null,  // 备用背包
    int preferredFirstIndex = 0  // 首选插槽索引
)
```

**返回**: `bool` - 是否成功插入

**示例**:
```csharp
// 尝试将瞄准镜插到枪上
Item gun = await ItemAssetsCollection.InstantiateAsync(300);
Item scope = await ItemAssetsCollection.InstantiateAsync(301);

if (gun.TryPlug(scope))
{
    Debug.Log("成功安装瞄准镜");
}
```

---

### 1.3 Item 类

**命名空间**: `ItemStatsSystem`

#### 基本方法

```csharp
// 从当前容器/槽位中移除物品
public void Detach()

// 获取物品总价值
public int GetTotalRawValue()
```

**示例**:
```csharp
// 从背包中移除物品
item.Detach();

// 获取物品价值
int value = item.GetTotalRawValue();
Debug.Log($"物品价值: ${value / 2}"); // 游戏中卖价通常是一半
```

---

## 二、角色系统 API

### 2.1 CharacterMainControl - 角色核心控制

**命名空间**: `Duckov`

CharacterMainControl 是所有角色的核心组件。

#### 设置阵营

```csharp
public void SetTeam(Teams _team)
```

**参数**:
- `_team` - 阵营枚举值

**示例**:
```csharp
CharacterMainControl character = someGameObject.GetComponent<CharacterMainControl>();
character.SetTeam(Teams.Friendly); // 设置为友方
```

**可用阵营**:
- `Teams.Friendly` - 友方
- `Teams.Enemy` - 敌方
- `Teams.Neutral` - 中立

---

### 2.2 敌人生成

> **注意**: 敌人生成相关 API 尚未完全文档化，建议通过反编译游戏 DLL 查找相关接口。

---

## 三、对话系统 API

### 3.1 DialogueUI - 大对话框

**命名空间**: `Dialogues`

#### 显示字幕对话

```csharp
public async UniTask DoSubtitle(SubtitlesRequestInfo info)
```

**重要提醒**:
- 这是一个异步函数
- 多次调用会相互影响，需要小心处理
- 自 v1.0.29 开始此函数变为公开

**示例**:
```csharp
using Dialogues;
using NodeCanvas.DialogueTrees;

// 创建对话信息
SubtitlesRequestInfo content = new SubtitlesRequestInfo
{
    text = "你好，欢迎来到鸭科夫！",
    // 配置其他参数...
};

// 显示对话
await DialogueUI.instance.DoSubtitle(content);
```

---

### 3.2 DialogueBubblesManager - 气泡对话

**命名空间**: `Duckov.UI.DialogueBubbles`

#### 显示气泡对话

```csharp
public static async UniTask Show(
    string text,                  // 对话文本
    Transform target,             // 目标对象
    float yOffset = -1,           // Y轴偏移
    bool needInteraction = false, // 是否需要交互
    bool skippable = false,       // 是否可跳过
    float speed = -1,             // 文字速度
    float duration = 2f           // 持续时间
)
```

**示例**:
```csharp
using Duckov.UI.DialogueBubbles;

// 在 NPC 头上显示气泡对话
await DialogueBubblesManager.Show(
    "你好啊，陌生人！",
    npcTransform,
    yOffset: 1.5f,
    duration: 3f
);
```

---

## 四、UI 系统 API

### 4.1 ItemHoveringUI - 物品悬停界面

**命名空间**: `Duckov.UI`

#### 事件订阅

```csharp
// 当物品悬停 UI 设置时触发
public static event Action<ItemHoveringUI, Item> onSetupItem

// 当元数据悬停 UI 设置时触发
public static event Action<ItemHoveringUI, ItemMetaData> onSetupMeta
```

#### UI 组件

```csharp
public Transform LayoutParent  // 布局父节点，用于添加自定义 UI 元素
```

**完整示例**:
```csharp
using Duckov.UI;
using ItemStatsSystem;
using TMPro;

public class ModBehaviour : Duckov.Modding.ModBehaviour
{
    private TextMeshProUGUI customText;

    void OnEnable()
    {
        // 订阅物品悬停事件
        ItemHoveringUI.onSetupItem += OnSetupItemHoveringUI;
        ItemHoveringUI.onSetupMeta += OnSetupMeta;
    }

    void OnDisable()
    {
        // 取消订阅，防止内存泄漏
        ItemHoveringUI.onSetupItem -= OnSetupItemHoveringUI;
        ItemHoveringUI.onSetupMeta -= OnSetupMeta;
    }

    private void OnSetupItemHoveringUI(ItemHoveringUI uiInstance, Item item)
    {
        if (item == null)
        {
            customText.gameObject.SetActive(false);
            return;
        }

        // 显示自定义信息
        customText.gameObject.SetActive(true);
        customText.transform.SetParent(uiInstance.LayoutParent);
        customText.transform.localScale = Vector3.one;
        customText.text = $"价值: ${item.GetTotalRawValue() / 2}";
        customText.fontSize = 20f;
    }

    private void OnSetupMeta(ItemHoveringUI uI, ItemMetaData data)
    {
        // 处理元数据显示
        customText.gameObject.SetActive(false);
    }
}
```

---

### 4.2 GameplayDataSettings - 游戏数据设置

**命名空间**: `Duckov`

#### UI 样式模板

```csharp
// 获取 UI 样式
public static UIStyle UIStyle { get; }

// UIStyle 包含的模板
public TextMeshProUGUI TemplateTextUGUI; // 文本模板
```

**示例**:
```csharp
// 使用游戏默认的文本样式创建文本
TextMeshProUGUI text = Instantiate(GameplayDataSettings.UIStyle.TemplateTextUGUI);
text.text = "自定义文本";
```

---

## 五、本地化 API

### 5.1 LocalizationManager - 本地化管理器

**命名空间**: `SodaCraft.Localizations`

#### 覆盖本地化文本

```csharp
public static void SetOverrideText(string key, string value)
```

**参数**:
- `key` - 本地化键
- `value` - 要显示的文本

**示例**:
```csharp
using SodaCraft.Localizations;

// 覆盖游戏中的某个文本
LocalizationManager.SetOverrideText("UI_MainMenu_Start", "开始冒险");
```

#### 语言切换事件

```csharp
public static System.Action<SystemLanguage> OnSetLanguage
```

**示例**:
```csharp
void Start()
{
    // 监听语言切换
    LocalizationManager.OnSetLanguage += OnLanguageChanged;
}

void OnDestroy()
{
    LocalizationManager.OnSetLanguage -= OnLanguageChanged;
}

private void OnLanguageChanged(SystemLanguage newLanguage)
{
    Debug.Log($"语言已切换到: {newLanguage}");
    // 更新你的 mod 的本地化内容
}
```

---

## 六、工具类 API

### 6.1 Debug 日志

**Unity 标准 Debug 类**

```csharp
Debug.Log("普通日志");
Debug.LogWarning("警告信息");
Debug.LogError("错误信息");
```

**日志文件位置**:
- **Windows**: `C:\Users\<用户名>\AppData\LocalLow\TeamSoda\Duckov\Player.log`
- **macOS**: `~/Library/Logs/TeamSoda/Duckov/Player.log`
- 上一次会话: `Player-prev.log`

**示例**:
```csharp
void Awake()
{
    Debug.Log("DisplayItemValue Mod 已加载!");
}
```

---

## 七、Unity 生命周期

### 7.1 ModBehaviour 类

所有 mod 的主类必须继承自 `Duckov.Modding.ModBehaviour`，它继承自 Unity 的 `MonoBehaviour`。

#### 标准 Unity 生命周期方法

```csharp
public class ModBehaviour : Duckov.Modding.ModBehaviour
{
    // 在脚本实例化时调用（最早）
    void Awake()
    {
        Debug.Log("Mod 已唤醒");
    }

    // 在第一帧更新前调用
    void Start()
    {
        Debug.Log("Mod 已启动");
        // 在这里进行初始化
    }

    // 当脚本启用时调用
    void OnEnable()
    {
        // 订阅游戏事件
        ItemHoveringUI.onSetupItem += OnSetupItem;
    }

    // 当脚本禁用时调用
    void OnDisable()
    {
        // 取消订阅，防止内存泄漏
        ItemHoveringUI.onSetupItem -= OnSetupItem;
    }

    // 每帧调用
    void Update()
    {
        // 处理每帧逻辑
    }

    // 固定时间间隔调用（用于物理）
    void FixedUpdate()
    {
        // 物理相关逻辑
    }

    // 在所有 Update 之后调用
    void LateUpdate()
    {
        // 相机跟随等逻辑
    }

    // 脚本销毁时调用
    void OnDestroy()
    {
        Debug.Log("Mod 已卸载");
        // 清理资源
    }
}
```

---

## 八、高级功能

### 8.1 ItemBuilder API（v1.2.5+）

**版本要求**: 游戏版本 1.2.5 及以上

ItemBuilder 是一套用于快速创建自定义物品 prefab 的工具集。

> **注意**: 具体 API 尚未完全公开，建议通过反编译查看或等待官方更新文档。

---

### 8.2 使用 Harmony 进行运行时修改

**Harmony 版本**: 社区推荐 v2.4.1

游戏本体不包含 Harmony 库，需要自行引入。

**安装**:
```xml
<!-- 在 .csproj 中添加 -->
<ItemGroup>
  <PackageReference Include="Lib.Harmony" Version="2.4.1" />
</ItemGroup>
```

**基本用法**:
```csharp
using HarmonyLib;

public class ModBehaviour : Duckov.Modding.ModBehaviour
{
    private Harmony harmony;

    void Awake()
    {
        harmony = new Harmony("com.yourname.modname");
        harmony.PatchAll(); // 应用所有 Patch
    }

    void OnDestroy()
    {
        harmony?.UnpatchAll(harmony.Id);
    }
}

// Patch 示例
[HarmonyPatch(typeof(SomeClass), "SomeMethod")]
class SomeClass_SomeMethod_Patch
{
    static void Prefix()
    {
        Debug.Log("方法调用前");
    }

    static void Postfix()
    {
        Debug.Log("方法调用后");
    }
}
```

**重要提醒**:
- 不同版本的 Harmony 会冲突
- 建议与社区协调使用统一版本
- 谨慎使用 Harmony，可能导致游戏不稳定

---

### 8.3 异步操作与 UniTask

游戏使用 **Cysharp.Threading.Tasks (UniTask)** 处理异步操作。

```csharp
using Cysharp.Threading.Tasks;

public async UniTaskVoid LoadItemAsync()
{
    // 异步生成物品
    Item item = await ItemAssetsCollection.InstantiateAsync(100);

    // 等待一段时间
    await UniTask.Delay(1000); // 等待1秒

    // 在主线程执行
    await UniTask.SwitchToMainThread();

    // 送给玩家
    ItemUtilities.SendToPlayer(item);
}
```

---

## 九、社区资源

### 9.1 官方资源

- **官方模组模板**: https://github.com/xvrsl/duckov_modding
- **Steam 创意工坊**: https://steamcommunity.com/app/3167020/workshop/
- **游戏 Steam 页面**: https://store.steampowered.com/app/3167020/

### 9.2 社区 Mod 仓库

**推荐学习的开源 mod**:

| 仓库 | 描述 | 难度 |
|------|------|------|
| [xvrsl/duckov_modding](https://github.com/xvrsl/duckov_modding) | 官方示例：显示物品价值 | ⭐ 入门 |
| [Oeddish/Duckov](https://github.com/Oeddish/Duckov) | 多 mod 解决方案模板 | ⭐⭐ 进阶 |
| [zhaohanyun/DUCKOV_MODS](https://github.com/zhaohanyun/DUCKOV_MODS) | Mod 合集 | ⭐⭐ 进阶 |
| [Mr-sans-and-InitLoader-s-team/Escape-From-Duckov-Coop-Mod](https://github.com/Mr-sans-and-InitLoader-s-team/Escape-From-Duckov-Coop-Mod-Preview) | 联机 mod（开源） | ⭐⭐⭐⭐ 高级 |

### 9.3 中文教程

- **CSDN**: 搜索"逃离鸭科夫 mod 制作"可找到社区教程
- **Bilibili**: 有 mod 开发视频教程
- **知乎**: 联机教程和技术讨论

---

## 十、常见问题

### 10.1 开发环境问题

**Q: .csproj 文件路径无法识别？**

A: 文件编码问题。使用 VS Code 将文件从 UTF-8 with BOM 改为 UTF-8（无 BOM）。

**Q: 找不到游戏 DLL 引用？**

A: 检查 .csproj 中的 `<DuckovPath>` 是否正确指向游戏安装目录。

```xml
<!-- Windows -->
<DuckovPath>E:\Program Files (x86)\Steam\steamapps\common\Escape from Duckov</DuckovPath>

<!-- macOS -->
<DuckovPath>/Users/Somebody/Library/Application Support/Steam/steamapps/common/Escape from Duckov</DuckovPath>
```

---

### 10.2 Mod 加载问题

**Q: Mod 没有在游戏中显示？**

A: 检查以下几点：
1. info.ini 中的 `name` 参数是否与命名空间匹配
2. DLL 文件、info.ini、preview.png 是否都在同一文件夹
3. 文件夹是否放在正确位置：`Duckov_Data/Mods/YourModName/`

**Q: Mod 导致游戏崩溃？**

A:
1. 检查 `Player.log` 查看错误信息
2. 确认是否正确取消订阅了事件（OnDisable）
3. 检查是否有空引用异常

---

### 10.3 API 使用问题

**Q: 如何找到物品的 TypeID？**

A:
1. 使用反编译工具（ILSpy、dnSpy）查看 `ItemStatsSystem.dll`
2. 查看社区整理的物品 ID 列表
3. 使用作弊菜单 mod 查看

**Q: 自定义物品在重启后消失？**

A: 这是正常行为。自定义物品依赖于 mod 加载，如果 mod 未加载，物品会消失。解决方案：
1. 确保 mod 始终加载
2. 在 mod 卸载前将自定义物品转换为游戏内物品

---

### 10.4 发布问题

**Q: 上传 Steam Workshop 后 info.ini 内容丢失？**

A: Steam Workshop 会覆写 info.ini。不要在其中存储自定义数据，仅使用官方支持的字段：
- name
- displayName
- description
- publishedFileId
- tags

**Q: 如何设置 Workshop Tags？**

A: 在 info.ini 中使用逗号分隔：

```ini
tags=Quality of Life,Utility
```

可用 Tags：
- Weapon
- Equipment & Gear
- Loot & Economy
- Quality of Life
- Cheats & Exploits
- Visual Enhancements
- Sound
- Quest & Progression
- Companion & NPC
- Collectibles
- Gameplay
- Multiplayer & Co-op
- Utility
- Medical & Survival

---

## 附录：完整示例 Mod

### 简单示例：显示物品耐久度

```csharp
using UnityEngine;
using Duckov.UI;
using ItemStatsSystem;
using TMPro;

namespace ShowItemDurability
{
    public class ModBehaviour : Duckov.Modding.ModBehaviour
    {
        private TextMeshProUGUI durabilityText;

        void Awake()
        {
            Debug.Log("ShowItemDurability Mod Loaded!");

            // 创建文本对象
            durabilityText = Instantiate(GameplayDataSettings.UIStyle.TemplateTextUGUI);
        }

        void OnEnable()
        {
            ItemHoveringUI.onSetupItem += OnItemHover;
        }

        void OnDisable()
        {
            ItemHoveringUI.onSetupItem -= OnItemHover;
        }

        void OnDestroy()
        {
            if (durabilityText != null)
                Destroy(durabilityText.gameObject);
        }

        private void OnItemHover(ItemHoveringUI ui, Item item)
        {
            if (item == null)
            {
                durabilityText.gameObject.SetActive(false);
                return;
            }

            // 显示耐久度信息
            durabilityText.gameObject.SetActive(true);
            durabilityText.transform.SetParent(ui.LayoutParent);
            durabilityText.transform.localScale = Vector3.one;

            // 假设物品有 durability 属性
            durabilityText.text = $"耐久度: {item.durability}%";
            durabilityText.fontSize = 18f;
            durabilityText.color = Color.yellow;
        }
    }
}
```

---

## 版本历史

### v1.2.5 (游戏版本)
- ✨ 新增 ItemBuilder API
- 🔧 改进 mod 加载顺序稳定性
- 🛡️ 新增 mod 恢复机制

### v1.0.29 (游戏版本)
- 🔓 DialogueUI.DoSubtitle 变为公开方法

---

## 贡献与反馈

如发现文档错误或有补充内容，请：
1. 在 GitHub 仓库提交 Issue
2. 在 Steam 社区讨论区反馈
3. 联系 mod 社区贡献者

---

**文档维护者**: Claude Code
**数据来源**: 官方文档 + 社区整理 + 代码分析
**协议**: 仅供学习交流使用

---

## 快速查询索引

| 功能 | API | 所在章节 |
|------|-----|---------|
| 生成物品 | `ItemAssetsCollection.InstantiateAsync()` | [1.1](#11-itemassetscollection---物品生成) |
| 送物品给玩家 | `ItemUtilities.SendToPlayer()` | [1.2](#12-itemutilities---物品操作工具) |
| 显示对话 | `DialogueUI.DoSubtitle()` | [3.1](#31-dialogueui---大对话框) |
| 气泡对话 | `DialogueBubblesManager.Show()` | [3.2](#32-dialoguebubblesmanager---气泡对话) |
| 物品悬停事件 | `ItemHoveringUI.onSetupItem` | [4.1](#41-itemhoveringui---物品悬停界面) |
| 本地化文本 | `LocalizationManager.SetOverrideText()` | [5.1](#51-localizationmanager---本地化管理器) |
| 设置角色阵营 | `CharacterMainControl.SetTeam()` | [2.1](#21-charactermaincontrol---角色核心控制) |
| 自定义物品 | `ItemAssetsCollection.AddDynamicEntry()` | [1.1](#11-itemassetscollection---物品生成) |
