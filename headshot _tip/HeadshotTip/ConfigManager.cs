using System;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;
using UnityEngine;

namespace HeadshotTip
{
    /// <summary>
    /// 配置管理类 - 负责读取和管理 config.json
    /// </summary>
    public class ConfigManager
    {
        private const string CONFIG_FILE_NAME = "config.json";
        private HeadshotTipConfig config;
        private string configPath;

        public ConfigManager()
        {
            // 配置文件路径：与 DLL 同目录
            string modDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            configPath = Path.Combine(modDirectory, CONFIG_FILE_NAME);

            LoadConfig();
        }

        /// <summary>
        /// 加载配置文件
        /// </summary>
        private void LoadConfig()
        {
            try
            {
                if (File.Exists(configPath))
                {
                    string json = File.ReadAllText(configPath);
                    config = JsonConvert.DeserializeObject<HeadshotTipConfig>(json);
                    Debug.Log($"[HeadshotTip] 配置文件加载成功: {configPath}");
                }
                else
                {
                    // 配置文件不存在，使用默认值并创建
                    config = GetDefaultConfig();
                    SaveConfig();
                    Debug.LogWarning($"[HeadshotTip] 配置文件不存在，已创建默认配置: {configPath}");
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] 加载配置文件失败: {ex.Message}");
                config = GetDefaultConfig();
            }
        }

        /// <summary>
        /// 保存配置文件
        /// </summary>
        public void SaveConfig()
        {
            try
            {
                string json = JsonConvert.SerializeObject(config, Formatting.Indented);
                File.WriteAllText(configPath, json);
                Debug.Log($"[HeadshotTip] 配置文件保存成功: {configPath}");
            }
            catch (Exception ex)
            {
                Debug.LogError($"[HeadshotTip] 保存配置文件失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 获取默认配置
        /// </summary>
        private HeadshotTipConfig GetDefaultConfig()
        {
            return new HeadshotTipConfig
            {
                Enabled = true,
                Duration = 2.0f,
                YOffset = 1.5f,
                Messages = new List<string>
                {
                    "三爷好棒",
                    "三爷V5",
                    "三爷牛逼",
                    "三爷无敌",
                    "三爷真强",
                    "三爷太秀了",
                    "三爷神枪手",
                    "三爷好准",
                    "完美爆头",
                    "漂亮！"
                }
            };
        }

        // 配置属性访问
        public bool IsEnabled => config?.Enabled ?? true;
        public float Duration => config?.Duration ?? 2.0f;
        public float YOffset => config?.YOffset ?? 1.5f;
        public List<string> Messages => config?.Messages ?? GetDefaultConfig().Messages;

        /// <summary>
        /// 获取随机鼓励消息
        /// </summary>
        public string GetRandomMessage()
        {
            if (Messages == null || Messages.Count == 0)
            {
                return "三爷好棒！"; // 默认消息
            }

            int index = UnityEngine.Random.Range(0, Messages.Count);
            return Messages[index];
        }
    }

    /// <summary>
    /// 配置文件数据结构
    /// </summary>
    [Serializable]
    public class HeadshotTipConfig
    {
        [JsonProperty("enabled")]
        public bool Enabled { get; set; }

        [JsonProperty("duration")]
        public float Duration { get; set; }

        [JsonProperty("yOffset")]
        public float YOffset { get; set; }

        [JsonProperty("messages")]
        public List<string> Messages { get; set; }
    }
}
