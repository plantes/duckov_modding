@echo off
chcp 65001 >nul
echo ====================================
echo  打包 Mod 发布版本
echo ====================================
echo.

REM 检查编译输出
if not exist "HeadshotTip\ReleaseExample\HeadshotTip\HeadshotTip.dll" (
    echo [错误] 未找到编译输出
    echo 请先运行 build.bat 编译项目
    pause
    exit /b 1
)

REM 检查必需文件
echo [1/4] 检查必需文件...

set "MISSING="

if not exist "HeadshotTip\ReleaseExample\HeadshotTip\info.ini" (
    echo [错误] 缺少 info.ini
    set MISSING=1
)

if not exist "HeadshotTip\ReleaseExample\HeadshotTip\config.json" (
    echo [错误] 缺少 config.json
    set MISSING=1
)

if not exist "HeadshotTip\ReleaseExample\HeadshotTip\preview.png" (
    echo [警告] 缺少 preview.png
    echo 建议添加预览图后再打包
    set /p continue="是否继续打包? (y/n): "
    if /i not "%continue%"=="y" exit /b 0
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

set "PACKAGE_DIR=HeadshotTip_Release"
set "TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "PACKAGE_NAME=HeadshotTip_v1.0_%TIMESTAMP%"

if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%\HeadshotTip"

REM 复制文件
echo [3/4] 复制文件...

xcopy /E /I /Y "HeadshotTip\ReleaseExample\HeadshotTip" "%PACKAGE_DIR%\HeadshotTip" >nul

REM 添加说明文件
echo [4/4] 生成说明文件...

(
echo ====================================
echo  HeadshotTip - 爆头击杀鼓励提示
echo ====================================
echo.
echo 安装方法:
echo 1. 将 HeadshotTip 文件夹复制到游戏的 Mods 目录
echo    位置: {游戏目录}\Duckov_Data\Mods\
echo.
echo 2. 启动游戏，在主菜单 Mods 中启用
echo.
echo 3. 重启游戏
echo.
echo 测试方法:
echo - 按 F8: 在玩家位置测试
echo - 按 F9: 在瞄准目标测试
echo - 按 F10: 显示配置信息
echo.
echo 配置文件:
echo - config.json 可以自定义文字和参数
echo.
echo 支持:
echo - GitHub: https://github.com/你的用户名/duckov_modding
echo.
echo 祝游戏愉快！
) > "%PACKAGE_DIR%\安装说明.txt"

REM 创建压缩包（如果有 7z 或 PowerShell）
where 7z >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo 正在使用 7z 创建压缩包...
    7z a -tzip "%PACKAGE_NAME%.zip" "%PACKAGE_DIR%\*" >nul
    echo ✓ 已创建: %PACKAGE_NAME%.zip
) else (
    echo 正在使用 PowerShell 创建压缩包...
    powershell -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%PACKAGE_NAME%.zip' -Force"
    if %ERRORLEVEL% EQU 0 (
        echo ✓ 已创建: %PACKAGE_NAME%.zip
    ) else (
        echo [提示] 无法自动创建压缩包
        echo 请手动压缩 %PACKAGE_DIR% 目录
    )
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
echo 可以将压缩包分享给其他玩家，或上传到 Steam 创意工坊
echo.
pause
