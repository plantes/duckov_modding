@echo off
chcp 65001 >nul
echo ====================================
echo  RunWhileEating Mod 部署脚本
echo ====================================
echo.

REM ============ 配置区域 ============
REM 请修改为你的游戏安装路径
set "GAME_PATH=e:\Downloads\逃离鸭科夫Escape From Duckov-v1.0.26+MOD整理\EscapeFD"

REM Mod 目录路径（通常不需要修改）
set "MODS_PATH=%GAME_PATH%\Duckov_Data\Mods"
set "MOD_NAME=RunWhileEating"
REM ==================================

echo 游戏路径: %GAME_PATH%
echo Mods 路径: %MODS_PATH%
echo Mod 名称: %MOD_NAME%
echo.

REM 检查游戏路径
if not exist "%GAME_PATH%\Duckov.exe" (
    echo [错误] 未找到游戏！
    echo 请确认游戏路径配置正确（第10行）
    echo.
    pause
    exit /b 1
)

echo ✓ 游戏路径验证通过
echo.

REM 检查编译输出
if not exist "RunWhileEating\ReleaseExample\RunWhileEating\RunWhileEating.dll" (
    echo [错误] 未找到编译输出
    echo 请先运行 build.bat 编译项目
    echo.
    pause
    exit /b 1
)

echo ✓ 编译输出验证通过
echo.

REM 创建 Mods 目录（如果不存在）
if not exist "%MODS_PATH%" (
    echo 创建 Mods 目录...
    mkdir "%MODS_PATH%"
)

REM 备份旧版本
if exist "%MODS_PATH%\%MOD_NAME%" (
    echo 发现旧版本，创建备份...
    set "BACKUP_NAME=%MOD_NAME%_backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
    set "BACKUP_NAME=!BACKUP_NAME: =0!"
    if exist "%MODS_PATH%\!BACKUP_NAME!" rmdir /s /q "%MODS_PATH%\!BACKUP_NAME!"
    move "%MODS_PATH%\%MOD_NAME%" "%MODS_PATH%\!BACKUP_NAME!" >nul
    echo ✓ 旧版本已备份到: !BACKUP_NAME!
)

REM 复制 Mod 文件
echo.
echo 开始部署 Mod...
xcopy /E /I /Y "RunWhileEating\ReleaseExample\RunWhileEating" "%MODS_PATH%\%MOD_NAME%" >nul

if %ERRORLEVEL% NEQ 0 (
    echo [错误] 部署失败
    pause
    exit /b 1
)

echo.
echo ====================================
echo  部署成功！✓
echo ====================================
echo.
echo Mod 已安装到: %MODS_PATH%\%MOD_NAME%
echo.
echo 下一步：
echo 1. 启动游戏
echo 2. 主菜单 → Mods
echo 3. 找到"吃东西时可以跑"并启用
echo 4. 重启游戏
echo 5. 游戏中按 F11 查看 Mod 状态
echo.
echo 功能：使用任何消耗品时可以正常跑动
echo.
pause
