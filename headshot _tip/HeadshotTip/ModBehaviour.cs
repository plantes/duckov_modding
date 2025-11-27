using System;
using UnityEngine;
using HarmonyLib;
using Duckov.UI.DialogueBubbles;
using Cysharp.Threading.Tasks;

namespace HeadshotTip
{
    /// <summary>
    /// HeadshotTip Mod - 测试版本
    /// 使用按键测试，无需反编译游戏代码
    /// </summary>
    public class ModBehaviour : Duckov.Modding.ModBehaviour
    {
        private Harmony harmony;
        private ConfigManager configManager;
        private const string HARMONY_ID = "com.sanye.headshotTip";

        // 测试模式开关
        private bool testMode = true;
        private float lastTestTime = 0f;
        private const float TEST_COOLDOWN = 0.5f;

        void Awake()
        {
            Debug.Log("=== HeadshotTip Mod 已加载 (测试版本) ===");

            try
            {
                // 初始化配置管理器
                configManager = new ConfigManager();
                Debug.Log($"[HeadshotTip] 配置加载完成，启用状态: {configManager.IsEnabled}");

                // 初始化 Harmony
                harmony = new Harmony(HARMONY_ID);

                // 应用所有 Patch
                harmony.PatchAll();
                Debug.Log("[HeadshotTip] Harmony Patches 应用成功");

                // 将配置管理器存储为静态引用，供 Patch 使用
                HeadshotDetector.Initialize(configManager);

                Debug.Log("[HeadshotTip] 测试模式已启用:");
                Debug.Log("[HeadshotTip] - 按 F8: 在玩家位置测试气泡");
                Debug.Log("[HeadshotTip] - 按 F9: 在鼠标指向的敌人处测试");
                Debug.Log("[HeadshotTip] - 按 F10: 显示当前配置");
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] 初始化失败: {ex.Message}\n{ex.StackTrace}");
            }
        }

        void Update()
        {
            if (!testMode || Time.time - lastTestTime < TEST_COOLDOWN)
                return;

            try
            {
                // F8: 在玩家位置测试
                if (Input.GetKeyDown(KeyCode.F8))
                {
                    lastTestTime = Time.time;
                    TestShowTipAtPlayer();
                }

                // F9: 在瞄准的目标处测试
                if (Input.GetKeyDown(KeyCode.F9))
                {
                    lastTestTime = Time.time;
                    TestShowTipAtTarget();
                }

                // F10: 显示配置信息
                if (Input.GetKeyDown(KeyCode.F10))
                {
                    ShowConfigInfo();
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] Update 错误: {ex.Message}");
            }
        }

        void OnDestroy()
        {
            try
            {
                // 清理 Harmony patches
                if (harmony != null)
                {
                    harmony.UnpatchAll(HARMONY_ID);
                    Debug.Log("[HeadshotTip] Harmony Patches 已清理");
                }

                HeadshotDetector.Cleanup();
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] 清理失败: {ex.Message}");
            }

            Debug.Log("=== HeadshotTip Mod 已卸载 ===");
        }

        /// <summary>
        /// 测试：在玩家位置显示提示
        /// </summary>
        private void TestShowTipAtPlayer()
        {
            Debug.Log("[HeadshotTip] F8 - 测试在玩家位置显示提示");

            // 查找玩家角色
            var player = FindObjectOfType<CharacterMainControl>();
            if (player != null)
            {
                HeadshotDetector.ShowHeadshotTipPublic(player.transform);
                Debug.Log("[HeadshotTip] 在玩家位置显示测试提示");
            }
            else
            {
                Debug.LogWarning("[HeadshotTip] 未找到玩家角色");
            }
        }

        /// <summary>
        /// 测试：在鼠标指向的目标处显示提示
        /// </summary>
        private void TestShowTipAtTarget()
        {
            Debug.Log("[HeadshotTip] F9 - 测试在瞄准目标显示提示");

            // 从相机发射射线
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit, 100f))
            {
                // 检查是否击中角色
                var character = hit.collider.GetComponentInParent<CharacterMainControl>();
                if (character != null)
                {
                    HeadshotDetector.ShowHeadshotTipPublic(character.transform);
                    Debug.Log($"[HeadshotTip] 在目标 {character.name} 处显示测试提示");
                }
                else
                {
                    // 即使不是角色，也在击中位置显示
                    HeadshotDetector.ShowHeadshotTipPublic(hit.transform);
                    Debug.Log($"[HeadshotTip] 在物体 {hit.transform.name} 处显示测试提示");
                }
            }
            else
            {
                Debug.LogWarning("[HeadshotTip] 未击中任何目标");
            }
        }

        /// <summary>
        /// 显示当前配置信息
        /// </summary>
        private void ShowConfigInfo()
        {
            Debug.Log("=== HeadshotTip 当前配置 ===");
            Debug.Log($"启用: {configManager.IsEnabled}");
            Debug.Log($"持续时间: {configManager.Duration} 秒");
            Debug.Log($"高度偏移: {configManager.YOffset}");
            Debug.Log($"消息数量: {configManager.Messages.Count}");
            Debug.Log($"随机消息示例: {configManager.GetRandomMessage()}");
            Debug.Log("==========================");
        }
    }

    /// <summary>
    /// 爆头检测器 - 测试版本
    /// </summary>
    public static class HeadshotDetector
    {
        private static ConfigManager config;

        public static void Initialize(ConfigManager configManager)
        {
            config = configManager;
        }

        public static void Cleanup()
        {
            config = null;
        }

        /// <summary>
        /// 公开的测试方法
        /// </summary>
        public static void ShowHeadshotTipPublic(Transform target)
        {
            ShowHeadshotTip(target);
        }

        /// <summary>
        /// 显示爆头提示
        /// </summary>
        private static async void ShowHeadshotTip(Transform enemyTransform)
        {
            if (config == null || !config.IsEnabled)
            {
                Debug.LogWarning("[HeadshotTip] Config 未初始化或已禁用");
                return;
            }

            if (enemyTransform == null)
            {
                Debug.LogWarning("[HeadshotTip] 目标 Transform 为空");
                return;
            }

            try
            {
                string message = config.GetRandomMessage();
                float duration = config.Duration;
                float yOffset = config.YOffset;

                Debug.Log($"[HeadshotTip] 显示提示: {message} (持续 {duration}秒, 偏移 {yOffset})");

                // 显示气泡对话框
                await DialogueBubblesManager.Show(
                    text: message,
                    target: enemyTransform,
                    yOffset: yOffset,
                    needInteraction: false,
                    skippable: true,
                    speed: -1,
                    duration: duration
                );

                Debug.Log("[HeadshotTip] 提示显示完成");
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] 显示提示失败: {ex.Message}\n{ex.StackTrace}");
            }
        }

        // ===== 以下是真实的 Harmony Patches（需要反编译游戏后启用）=====

        /*
        /// <summary>
        /// 方案 1: Hook 角色死亡方法
        /// 适用场景：游戏有明确的死亡回调方法
        /// </summary>
        [HarmonyPatch(typeof(CharacterMainControl), "OnDeath")]  // 替换为实际的类名和方法名
        [HarmonyPostfix]
        static void OnDeath_Postfix(CharacterMainControl __instance, object damageInfo)
        {
            try
            {
                // 检查是否为爆头
                // 根据实际的 damageInfo 结构调整
                bool isHeadshot = CheckIfHeadshot(damageInfo);

                if (isHeadshot)
                {
                    Debug.Log($"[HeadshotTip] 检测到爆头击杀: {__instance.name}");
                    ShowHeadshotTip(__instance.transform);
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] OnDeath Patch 错误: {ex.Message}");
            }
        }
        */

        /*
        /// <summary>
        /// 方案 2: Hook 伤害方法
        /// 适用场景：通过伤害方法判断击中部位
        /// </summary>
        [HarmonyPatch(typeof(Health), "TakeDamage")]  // 替换为实际的类名
        [HarmonyPostfix]
        static void TakeDamage_Postfix(Health __instance, float damage, string hitLocation)
        {
            try
            {
                // 检查是否死亡且击中头部
                if (__instance.CurrentHealth <= 0 && hitLocation == "Head")
                {
                    Debug.Log($"[HeadshotTip] 爆头击杀");
                    var character = __instance.GetComponent<CharacterMainControl>();
                    if (character != null)
                    {
                        ShowHeadshotTip(character.transform);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] TakeDamage Patch 错误: {ex.Message}");
            }
        }
        */

        /*
        /// <summary>
        /// 方案 3: Hook 击杀统计
        /// 适用场景：游戏有击杀统计系统
        /// </summary>
        [HarmonyPatch(typeof(KillTracker), "OnKill")]  // 替换为实际的类名
        [HarmonyPostfix]
        static void OnKill_Postfix(Transform victim, bool isHeadshot)
        {
            try
            {
                if (isHeadshot)
                {
                    Debug.Log("[HeadshotTip] 统计系统检测到爆头");
                    ShowHeadshotTip(victim);
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] OnKill Patch 错误: {ex.Message}");
            }
        }
        */

        /// <summary>
        /// 辅助方法：检查是否为爆头
        /// 根据游戏实际的伤害信息结构实现
        /// </summary>
        private static bool CheckIfHeadshot(object damageInfo)
        {
            // TODO: 根据实际的 DamageInfo 结构实现
            // 可能的字段名：isHeadshot, hitLocation, bodyPart, damageType 等

            /*
            // 示例实现 1: DamageInfo 有 isHeadshot 字段
            if (damageInfo is DamageInfo info)
            {
                return info.isHeadshot;
            }

            // 示例实现 2: 检查击中部位
            if (damageInfo is DamageInfo info)
            {
                return info.hitLocation == HitLocation.Head;
            }

            // 示例实现 3: 通过反射访问字段
            var type = damageInfo.GetType();
            var field = type.GetField("isHeadshot");
            if (field != null)
            {
                return (bool)field.GetValue(damageInfo);
            }
            */

            return false;
        }
    }
}
