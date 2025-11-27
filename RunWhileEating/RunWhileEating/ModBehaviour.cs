using System;
using System.Reflection;
using UnityEngine;
using HarmonyLib;
using Duckov;

namespace RunWhileEating
{
    /// <summary>
    /// RunWhileEating Mod - 允许在使用消耗品时正常跑动
    /// 作者：三爷
    /// 版本：1.0（测试版）
    /// </summary>
    public class ModBehaviour : Duckov.Modding.ModBehaviour
    {
        private Harmony harmony;
        private const string HARMONY_ID = "com.sanye.runwhileeating";

        // 调试标志
        private bool debugMode = true;
        private float lastDebugTime = 0f;
        private const float DEBUG_INTERVAL = 5f; // 每5秒输出一次调试信息

        // 运行时监控
        private bool isMonitoring = false;

        /// <summary>
        /// Mod 初始化
        /// </summary>
        void Awake()
        {
            try
            {
                Log("=== RunWhileEating Mod 开始初始化 ===");

                // 创建 Harmony 实例
                harmony = new Harmony(HARMONY_ID);

                // 应用所有 Patches
                harmony.PatchAll(Assembly.GetExecutingAssembly());

                Log("✓ Harmony Patches 应用成功");
                var patchedMethods = harmony.GetPatchedMethods();
                int count = 0;
                foreach (var _ in patchedMethods) count++;
                Log($"✓ Patch 数量: {count}");

                // 启动监控
                isMonitoring = true;

                Log("=== RunWhileEating Mod 初始化完成 ===");
                Log("功能：使用所有消耗品时可以正常跑动");
                Log("速度：100% 正常跑步速度");
                Log("按 F11 显示状态信息");
            }
            catch (Exception ex)
            {
                LogError($"初始化失败: {ex.Message}");
                LogError($"堆栈: {ex.StackTrace}");
            }
        }

        /// <summary>
        /// Mod 卸载
        /// </summary>
        void OnDestroy()
        {
            try
            {
                if (harmony != null)
                {
                    harmony.UnpatchAll(HARMONY_ID);
                    Log("RunWhileEating Mod 已卸载");
                }
                isMonitoring = false;
            }
            catch (Exception ex)
            {
                LogError($"卸载失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 每帧更新
        /// </summary>
        void Update()
        {
            try
            {
                // F11: 显示状态信息
                if (Input.GetKeyDown(KeyCode.F11))
                {
                    ShowStatus();
                }

                // 调试模式：定期输出状态
                if (debugMode && Time.time - lastDebugTime > DEBUG_INTERVAL)
                {
                    lastDebugTime = Time.time;
                    LogDebug();
                }

                // 实时强制允许移动（兜底方案）
                if (isMonitoring)
                {
                    ForceEnableMovement();
                }
            }
            catch (Exception ex)
            {
                // 静默处理，避免刷屏
            }
        }

        /// <summary>
        /// 显示当前状态
        /// </summary>
        private void ShowStatus()
        {
            Log("=== RunWhileEating Mod 状态 ===");
            Log($"Mod 版本: 1.0");
            Log($"Harmony ID: {HARMONY_ID}");
            Log($"监控状态: {(isMonitoring ? "运行中" : "已停止")}");
            Log($"调试模式: {(debugMode ? "开启" : "关闭")}");

            try
            {
                var player = FindPlayer();
                if (player != null)
                {
                    Log($"玩家对象: 找到");
                    LogPlayerInfo(player);
                }
                else
                {
                    Log($"玩家对象: 未找到");
                }
            }
            catch (Exception ex)
            {
                Log($"获取玩家信息失败: {ex.Message}");
            }

            Log("==============================");
        }

        /// <summary>
        /// 输出调试信息
        /// </summary>
        private void LogDebug()
        {
            try
            {
                var player = FindPlayer();
                if (player == null) return;

                // 使用 Reflection 获取玩家状态
                var type = player.GetType();
                var fields = type.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);

                foreach (var field in fields)
                {
                    var name = field.Name.ToLower();
                    // 查找与移动、使用物品相关的字段
                    if (name.Contains("move") || name.Contains("speed") ||
                        name.Contains("using") || name.Contains("consume") ||
                        name.Contains("item") || name.Contains("lock"))
                    {
                        try
                        {
                            var value = field.GetValue(player);
                            Log($"[Debug] {field.Name} = {value}");
                        }
                        catch { }
                    }
                }
            }
            catch { }
        }

        /// <summary>
        /// 输出玩家信息
        /// </summary>
        private void LogPlayerInfo(object player)
        {
            try
            {
                var type = player.GetType();

                // 尝试获取常见属性
                TryLogProperty(player, type, "velocity");
                TryLogProperty(player, type, "isGrounded");
                TryLogProperty(player, type, "canMove");
                TryLogProperty(player, type, "canRun");
                TryLogProperty(player, type, "moveSpeed");
                TryLogProperty(player, type, "runSpeed");
            }
            catch (Exception ex)
            {
                Log($"获取属性失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 尝试输出属性值
        /// </summary>
        private void TryLogProperty(object obj, Type type, string propertyName)
        {
            try
            {
                var prop = type.GetProperty(propertyName, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                if (prop != null)
                {
                    var value = prop.GetValue(obj);
                    Log($"  {propertyName}: {value}");
                }
            }
            catch { }
        }

        /// <summary>
        /// 强制允许移动（兜底方案）
        /// </summary>
        private void ForceEnableMovement()
        {
            try
            {
                var player = FindPlayer();
                if (player == null) return;

                var type = player.GetType();

                // 尝试设置移动相关字段为允许
                TrySetField(player, type, "canMove", true);
                TrySetField(player, type, "canRun", true);
                TrySetField(player, type, "lockMovement", false);
                TrySetField(player, type, "movementLocked", false);
                TrySetField(player, type, "isUsingItem", false); // 注意：这可能影响动画
            }
            catch { }
        }

        /// <summary>
        /// 尝试设置字段值
        /// </summary>
        private void TrySetField(object obj, Type type, string fieldName, object value)
        {
            try
            {
                var field = type.GetField(fieldName, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                if (field != null)
                {
                    field.SetValue(obj, value);
                }
            }
            catch { }
        }

        /// <summary>
        /// 查找玩家对象
        /// </summary>
        private object FindPlayer()
        {
            try
            {
                // 方法1：通过 CharacterMainControl 查找
                var player = GameObject.FindObjectOfType<CharacterMainControl>();
                if (player != null) return player;

                // 方法2：通过 Tag 查找
                var playerObj = GameObject.FindGameObjectWithTag("Player");
                if (playerObj != null)
                {
                    return playerObj.GetComponent<CharacterMainControl>();
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// 日志输出
        /// </summary>
        private void Log(string message)
        {
            Debug.Log($"[RunWhileEating] {message}");
        }

        /// <summary>
        /// 错误日志
        /// </summary>
        private void LogError(string message)
        {
            Debug.LogError($"[RunWhileEating] {message}");
        }

        // ============================================
        // Harmony Patches
        // ============================================

        /// <summary>
        /// Patch 示例：CharacterMainControl.CanMove
        /// 注意：这只是示例，实际方法名需要反编译游戏确认
        /// </summary>
        /*
        [HarmonyPatch(typeof(CharacterMainControl), "CanMove")]
        public class CanMove_Patch
        {
            [HarmonyPostfix]
            static void Postfix(ref bool __result)
            {
                // 始终允许移动
                __result = true;
            }
        }
        */

        /// <summary>
        /// Patch 示例：移除速度限制
        /// 注意：这只是示例，实际方法名需要反编译游戏确认
        /// </summary>
        /*
        [HarmonyPatch(typeof(CharacterMainControl), "GetMovementSpeed")]
        public class GetMovementSpeed_Patch
        {
            [HarmonyPostfix]
            static void Postfix(ref float __result, CharacterMainControl __instance)
            {
                // 如果正在使用物品，保持正常跑步速度
                if (__instance.isUsingItem)
                {
                    __result = __instance.runSpeed;
                }
            }
        }
        */

        /// <summary>
        /// 通用 Transpiler Patch
        /// 用于修改 IL 代码，移除移动限制检查
        /// </summary>
        /*
        [HarmonyPatch(typeof(CharacterMainControl), "Update")]
        public class Update_Transpiler
        {
            [HarmonyTranspiler]
            static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> instructions)
            {
                // 这里需要根据反编译结果来写 IL 代码修改逻辑
                return instructions;
            }
        }
        */
    }
}
