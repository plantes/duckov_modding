@echo off
chcp 65001 >nul
echo ====================================
echo  HeadshotTip Mod 部署脚本
echo ====================================
echo.

REM ============ 配置区域 ============
REM 请修改为你的游戏安装路径
set "GAME_PATH=e:\Downloads\逃离鸭科夫Escape From Duckov-v1.0.26+MOD整理\EscapeFD"

REM Mod 目录路径（通常不需要修改）
set "MODS_PATH=%GAME_PATH%\Duckov_Data\Mods"
set "MOD_NAME=HeadshotTip"
REM ==================================

echo 游戏路径: %GAME_PATH%
echo Mods 路径: %MODS_PATH%
echo Mod 名称: %MOD_NAME%
echo.

REM 检查游戏路径是否存在
if not exist "%GAME_PATH%" (
    echo [错误] 游戏路径不存在！
    echo.
    echo 请编辑 deploy.bat 文件，修改 GAME_PATH 为你的游戏实际路径
    echo 当前配置: %GAME_PATH%
    echo.
    pause
    exit /b 1
)

REM 检查 Mods 目录
if not exist "%MODS_PATH%" (
    echo [警告] Mods 目录不存在，尝试创建...
    mkdir "%MODS_PATH%"
    if %ERRORLEVEL% NEQ 0 (
        echo [错误] 无法创建 Mods 目录
        pause
        exit /b 1
    )
    echo ✓ Mods 目录已创建
)

REM 检查编译输出
if not exist "HeadshotTip\ReleaseExample\HeadshotTip\HeadshotTip.dll" (
    echo [错误] 未找到编译输出文件
    echo.
    echo 请先运行 build.bat 编译项目
    echo.
    pause
    exit /b 1
)

REM 备份旧版本（如果存在）
if exist "%MODS_PATH%\%MOD_NAME%" (
    echo [1/3] 备份旧版本...
    if exist "%MODS_PATH%\%MOD_NAME%_backup" rmdir /s /q "%MODS_PATH%\%MOD_NAME%_backup"
    move "%MODS_PATH%\%MOD_NAME%" "%MODS_PATH%\%MOD_NAME%_backup" >nul
    echo ✓ 旧版本已备份到: %MOD_NAME%_backup
)

REM 复制 Mod 文件
echo [2/3] 复制 Mod 文件到游戏目录...
xcopy /E /I /Y "HeadshotTip\ReleaseExample\HeadshotTip" "%MODS_PATH%\%MOD_NAME%" >nul

if %ERRORLEVEL% NEQ 0 (
    echo [错误] 复制文件失败
    pause
    exit /b 1
)

REM 检查部署结果
echo [3/3] 验证部署...
if exist "%MODS_PATH%\%MOD_NAME%\HeadshotTip.dll" (
    echo ✓ Mod 部署成功！
    echo.
    echo 部署位置: %MODS_PATH%\%MOD_NAME%
    echo.
    echo 文件列表:
    dir /b "%MODS_PATH%\%MOD_NAME%"
) else (
    echo [错误] 部署验证失败
    pause
    exit /b 1
)

echo.
echo ====================================
echo  部署完成！
echo ====================================
echo.
echo 下一步：
echo 1. 启动游戏
echo 2. 主菜单 → Mods
echo 3. 找到"爆头击杀鼓励提示"并启用
echo 4. 重启游戏
echo 5. 游戏中按 F8/F9 测试功能
echo.
echo 日志位置:
echo %USERPROFILE%\AppData\LocalLow\TeamSoda\Duckov\Player.log
echo.
pause
