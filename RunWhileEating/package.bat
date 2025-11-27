@echo off
chcp 65001 >nul
echo ====================================
echo  打包 Mod 发布版本
echo ====================================
echo.

REM 检查编译输出
if not exist "RunWhileEating\ReleaseExample\RunWhileEating\RunWhileEating.dll" (
    echo [错误] 未找到编译输出
    echo 请先运行 build.bat 编译项目
    pause
    exit /b 1
)

REM 检查必需文件
echo [1/4] 检查必需文件...

set "MISSING="

if not exist "RunWhileEating\ReleaseExample\RunWhileEating\info.ini" (
    echo [错误] 缺少 info.ini
    set MISSING=1
)

if defined MISSING (
    echo.
    echo 存在缺失文件，无法打包
    pause
    exit /b 1
)

echo ✓ 必需文件检查完成

REM 创建打包目录
echo [2/4] 创建打包目录...

set "PACKAGE_DIR=RunWhileEating_Release"
set "TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "PACKAGE_NAME=RunWhileEating_v1.0_%TIMESTAMP%"

if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%\RunWhileEating"

REM 复制文件
echo [3/4] 复制文件...

xcopy /E /I /Y "RunWhileEating\ReleaseExample\RunWhileEating" "%PACKAGE_DIR%\RunWhileEating" >nul

REM 添加说明文件
echo [4/4] 生成说明文件...

(
echo ====================================
echo  RunWhileEating - 吃东西时可以跑
echo ====================================
echo.
echo 功能说明:
echo - 使用所有消耗品（食物、药品、饮料）时可以保持正常跑步速度
echo - 100%% 正常速度，无限制
echo - 简单易用，安装即生效
echo.
echo 安装方法:
echo 1. 将 RunWhileEating 文件夹复制到游戏的 Mods 目录
echo    位置: {游戏目录}\Duckov_Data\Mods\
echo.
echo 2. 启动游戏，在主菜单 Mods 中启用
echo.
echo 3. 重启游戏
echo.
echo 使用方法:
echo - 游戏中按 F11 查看 Mod 状态
echo - 使用任何消耗品时即可感受到效果
echo.
echo 兼容性:
echo - 游戏版本: 逃离鸭科夫 v1.0.26+
echo - 不需要配置文件
echo - 与其他 Mod 兼容性良好
echo.
echo 技术信息:
echo - 使用 Harmony 框架
echo - 运行时方法 Patch
echo - 无性能影响
echo.
echo 支持:
echo - GitHub: https://github.com/plantes/duckov_modding
echo - 作者: 三爷
echo.
echo 祝游戏愉快！
) > "%PACKAGE_DIR%\安装说明.txt"

REM 创建压缩包（使用 PowerShell）
echo 正在创建压缩包...
powershell -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%PACKAGE_NAME%.zip' -Force"

if %ERRORLEVEL% EQU 0 (
    echo ✓ 已创建: %PACKAGE_NAME%.zip
) else (
    echo [提示] 无法自动创建压缩包
    echo 请手动压缩 %PACKAGE_DIR% 目录
)

echo.
echo ====================================
echo  打包完成！
echo ====================================
echo.
echo 打包目录: %PACKAGE_DIR%
if exist "%PACKAGE_NAME%.zip" (
    echo 压缩文件: %PACKAGE_NAME%.zip
)
echo.
echo 可以将压缩包分享给其他玩家
echo.
pause
