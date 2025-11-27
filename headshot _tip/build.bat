@echo off
chcp 65001 >nul
echo ====================================
echo  HeadshotTip Mod 编译脚本
echo ====================================
echo.

REM 检查 dotnet 是否可用
where dotnet >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 dotnet 命令
    echo 请安装 .NET SDK: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)

echo [1/3] 清理旧的编译输出...
if exist "HeadshotTip\bin" rmdir /s /q "HeadshotTip\bin"
if exist "HeadshotTip\obj" rmdir /s /q "HeadshotTip\obj"
if exist "HeadshotTip\ReleaseExample\HeadshotTip\*.dll" del /q "HeadshotTip\ReleaseExample\HeadshotTip\*.dll"
if exist "HeadshotTip\ReleaseExample\HeadshotTip\*.pdb" del /q "HeadshotTip\ReleaseExample\HeadshotTip\*.pdb"

echo [2/3] 编译项目 (Release 配置)...
dotnet build HeadshotTip.sln -c Release

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 编译失败！
    echo 请检查:
    echo 1. DuckovPath 配置是否正确 (HeadshotTip.csproj)
    echo 2. 游戏是否已安装
    echo 3. 编译错误信息
    pause
    exit /b 1
)

echo [3/3] 检查输出文件...
if exist "HeadshotTip\ReleaseExample\HeadshotTip\HeadshotTip.dll" (
    echo.
    echo ✓ 编译成功！
    echo.
    echo 输出位置: HeadshotTip\ReleaseExample\HeadshotTip\
    echo.
    dir /b "HeadshotTip\ReleaseExample\HeadshotTip\*.dll"
    echo.
) else (
    echo [错误] 未找到编译输出文件
    pause
    exit /b 1
)

echo ====================================
echo  编译完成！
echo ====================================
echo.
echo 下一步：
echo 1. 运行 deploy.bat 将 Mod 部署到游戏目录
echo 2. 或手动复制 HeadshotTip\ReleaseExample\HeadshotTip 到游戏 Mods 文件夹
echo.
pause
