# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modding template for "Escape From Duckov" (逃离鸭科夫), a Unity-based game. The template demonstrates how to create mods using C# that extend game functionality through the game's modding system.

## Core Architecture

### Mod Loading System
The game's mod system loads mods using a namespace-based approach:
- The mod's namespace MUST match the `name` parameter in `info.ini`
- Example: if `info.ini` contains `name=MyMod`, the game loads `MyMod.ModBehaviour` from `MyMod.dll`
- Every mod must have a class named `ModBehaviour` that inherits from `Duckov.Modding.ModBehaviour`
- The game creates a GameObject and attaches the ModBehaviour via `GameObject.AddComponent(Type)`

### Required Files for Distribution
Each mod requires exactly three files in its folder:
- `{ModName}.dll` - compiled mod code
- `info.ini` - metadata (name, displayName, description, tags, publishedFileId)
- `preview.png` - square preview image (recommended 256x256)

**CRITICAL**: When uploading to Steam Workshop, `info.ini` gets overwritten. Never store custom data in this file beyond the documented parameters.

## Building Mods

### Prerequisites
1. Set `DuckovPath` in the `.csproj` file to your game installation directory (the folder containing `Duckov.exe` on Windows or `Duckov.app` on macOS)
2. Visual Studio or compatible IDE with .NET Standard 2.1 support

### Build Configuration
- **Target Framework**: netstandard2.1 (REQUIRED)
- **Required References** from `{DuckovPath}\Duckov_Data\Managed\`:
  - `TeamSoda.*`
  - `ItemStatsSystem.dll`
  - `Unity*` (all Unity DLLs)
- **Reference Settings**: Set `<Private>False</Private>` for all game references to prevent copying to output

### Build and Test
```bash
# Build the project
dotnet build

# Copy output to test location
# Windows: {DuckovPath}\Duckov_Data\Mods\{ModName}\
# macOS: {DuckovPath}/Duckov.app/Contents/Mods/{ModName}/
```

The mod can then be loaded from the game's Mods menu.

## Key APIs and Patterns

### Item System (ItemStatsSystem namespace)

**Item Instantiation**:
```csharp
// Async (preferred)
Item item = await ItemAssetsCollection.InstantiateAsync(typeID);
// Sync (use when async not possible)
Item item = ItemAssetsCollection.InstantiateSync(typeID);
```

**Item Operations** (ItemUtilities):
- `SendToPlayer(Item item)` - Give item to player
- `SendToPlayerCharacter(Item item)` - Add to player character inventory
- `SendToPlayerStorage(Item item)` - Add to player storage
- `item.IsInPlayerCharacter()` - Check if item is on player
- `item.TryPlug(Item part)` - Attach item to another item's slot
- `item.Detach()` - Remove item from current container/slot

**Custom Items**:
```csharp
// Add custom item to game
ItemStatsSystem.ItemAssetsCollection.AddDynamicEntry(Item prefab);
// Remove when mod unloads
ItemStatsSystem.ItemAssetsCollection.RemoveDynamicEntry(Item prefab);
```
Custom items require unique TypeID to avoid conflicts. Items disappear from saves if mod not loaded.

### Character System

**CharacterMainControl** - Core component for all characters:
- `SetTeam(Teams _team)` - Change character faction

### Dialogue System

**Large Dialogue** (DialogueUI):
```csharp
var info = new NodeCanvas.DialogueTrees.SubtitlesRequestInfo(...);
await DialogueUI.instance.DoSubtitle(info);
```

**Bubble Dialogue** (DialogueBubblesManager):
```csharp
await DialogueBubblesManager.Show("text", targetTransform, yOffset: -1, duration: 2f);
```

### Localization

```csharp
// Override localization text
SodaCraft.Localizations.LocalizationManager.SetOverrideText(string key, string value);

// Handle language changes
SodaCraft.Localizations.LocalizationManager.OnSetLanguage += (SystemLanguage lang) => { /* ... */ };
```

## Unity Development

When using Unity Editor for mod development, refer to `UnityFiles/manifest.json` for the exact package versions used by the game. Key packages include:
- Unity 2023.x (URP 17.0.3)
- Input System 1.11.1
- TextMeshPro 3.0.9
- Cinemachine 2.10.1
- Addressables 2.2.2

Shaders are available in `Extra/Shaders/` (SodaLit.shader, SodaCharacter.shader).

## Important Notes

### Harmony Library
The game does NOT include Harmony. If using Harmony, coordinate with the community to use a common version (currently 2.4.1) to avoid conflicts between mods.

### File Encoding
If Visual Studio fails to recognize file paths in `.csproj`, the issue is likely UTF-8 with BOM encoding. Convert to UTF-8 without BOM using VS Code or another editor.

### Event Lifecycle
ModBehaviour inherits from MonoBehaviour, so use standard Unity lifecycle methods:
- `Awake()` - Initialize mod (runs before game fully loads)
- `Start()` - Setup after game initialization
- `Update()` - Per-frame logic
- `OnEnable()`/`OnDisable()` - Subscribe/unsubscribe to game events
- `OnDestroy()` - Cleanup when mod unloads

### Log Files
- **Windows**: `C:\Users\{Username}\AppData\LocalLow\TeamSoda\Duckov\Player.log`
- **macOS**: `~/Library/Logs/TeamSoda/Duckov/Player.log`

Use `Debug.Log()` for debugging - logs appear in these files.

## Community Guidelines

Mods must comply with community rules (禁止违法、色情、政治内容). AI-generated content must be labeled. Steam Workshop mods violating rules may be removed without notice.
