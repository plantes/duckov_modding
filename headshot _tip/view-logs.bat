@echo off
chcp 65001 >nul
echo ====================================
echo  查看游戏日志 (HeadshotTip)
echo ====================================
echo.

set "LOG_PATH=%USERPROFILE%\AppData\LocalLow\TeamSoda\Duckov\Player.log"

if not exist "%LOG_PATH%" (
    echo [错误] 日志文件不存在
    echo 路径: %LOG_PATH%
    echo.
    echo 请确认:
    echo 1. 游戏是否已运行过
    echo 2. 路径是否正确
    pause
    exit /b 1
)

echo 日志文件: %LOG_PATH%
echo.
echo ============ 最近的 HeadshotTip 日志 ============
echo.

REM 使用 findstr 过滤包含 HeadshotTip 的行，显示最近 50 条
powershell -Command "Get-Content '%LOG_PATH%' | Select-String 'HeadshotTip' | Select-Object -Last 50"

echo.
echo ============================================
echo.
echo 选项:
echo 1. 按任意键退出
echo 2. 输入 'open' 然后回车，用记事本打开完整日志
echo.
set /p choice=请选择:

if /i "%choice%"=="open" (
    notepad "%LOG_PATH%"
)
