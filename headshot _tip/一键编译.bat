@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  HeadshotTip Mod 一键编译
echo ========================================
echo.

REM ===== 第 1 步：查找 MSBuild =====
echo [1/4] 正在查找 Visual Studio...

set "MSBUILD="

REM 尝试使用 vswhere（Visual Studio 2017+）
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    echo 找到 vswhere，正在定位 MSBuild...
    for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
        set "MSBUILD=%%i"
    )
)

REM 如果 vswhere 没找到，尝试常见路径
if not defined MSBUILD (
    echo vswhere 未找到 MSBuild，尝试常见路径...

    REM Visual Studio 2022
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
        set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    ) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
        set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    ) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
        set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    )

    REM Visual Studio 2019
    if not defined MSBUILD (
        if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
            set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
        ) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
            set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
        ) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
            set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
        )
    )

    REM Visual Studio 2017
    if not defined MSBUILD (
        if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" (
            set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"
        ) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe" (
            set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe"
        )
    )
)

if not defined MSBUILD (
    echo.
    echo [错误] 未找到 MSBuild！
    echo.
    echo 请确认已安装 Visual Studio，包括以下组件：
    echo - .NET 桌面开发
    echo - .NET Core 跨平台开发
    echo.
    echo 如果已安装，可以手动指定 MSBuild.exe 路径：
    echo 编辑本脚本，在顶部添加：
    echo set "MSBUILD=C:\你的\MSBuild.exe路径"
    echo.
    pause
    exit /b 1
)

echo ✓ 找到 MSBuild:
echo   !MSBUILD!
echo.

REM ===== 第 2 步：还原 NuGet 包 =====
echo [2/4] 还原 NuGet 包...

"%MSBUILD%" HeadshotTip.sln -t:restore -p:Configuration=Release >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [警告] NuGet 还原可能失败，但继续尝试编译...
) else (
    echo ✓ NuGet 包还原完成
)
echo.

REM ===== 第 3 步：清理旧输出 =====
echo [3/4] 清理旧的编译输出...

if exist "HeadshotTip\bin" rmdir /s /q "HeadshotTip\bin" 2>nul
if exist "HeadshotTip\obj" rmdir /s /q "HeadshotTip\obj" 2>nul
if exist "HeadshotTip\ReleaseExample\HeadshotTip\*.dll" del /q "HeadshotTip\ReleaseExample\HeadshotTip\*.dll" 2>nul
if exist "HeadshotTip\ReleaseExample\HeadshotTip\*.pdb" del /q "HeadshotTip\ReleaseExample\HeadshotTip\*.pdb" 2>nul

echo ✓ 清理完成
echo.

REM ===== 第 4 步：编译项目 =====
echo [4/4] 开始编译项目（Release 配置）...
echo.
echo ----------------------------------------

"%MSBUILD%" HeadshotTip.sln -p:Configuration=Release -v:minimal

echo ----------------------------------------
echo.

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 编译失败！
    echo.
    echo 可能的原因：
    echo 1. 游戏路径配置错误
    echo    - 检查 HeadshotTip\HeadshotTip.csproj 中的 DuckovPath
    echo    - 确保游戏已安装且路径正确
    echo.
    echo 2. 缺少游戏 DLL 文件
    echo    - 检查 {游戏目录}\Duckov_Data\Managed\ 是否存在
    echo.
    echo 3. NuGet 包问题
    echo    - 尝试在 Visual Studio 中打开项目并还原包
    echo.
    echo 查看上面的错误信息获取详细原因
    echo.
    pause
    exit /b 1
)

REM ===== 验证输出 =====
echo.
echo ========================================
echo  编译成功！正在验证输出...
echo ========================================
echo.

set "OUTPUT_DIR=HeadshotTip\ReleaseExample\HeadshotTip"
set "MISSING="

if not exist "%OUTPUT_DIR%\HeadshotTip.dll" (
    echo [错误] 缺少 HeadshotTip.dll
    set MISSING=1
)

if not exist "%OUTPUT_DIR%\0Harmony.dll" (
    echo [错误] 缺少 0Harmony.dll
    set MISSING=1
)

if not exist "%OUTPUT_DIR%\Newtonsoft.Json.dll" (
    echo [错误] 缺少 Newtonsoft.Json.dll
    set MISSING=1
)

if not exist "%OUTPUT_DIR%\config.json" (
    echo [警告] 缺少 config.json（会自动生成）
)

if not exist "%OUTPUT_DIR%\info.ini" (
    echo [错误] 缺少 info.ini
    set MISSING=1
)

if not exist "%OUTPUT_DIR%\preview.png" (
    echo [警告] 缺少 preview.png（可选）
)

if defined MISSING (
    echo.
    echo 编译完成但缺少必要文件！
    pause
    exit /b 1
)

echo ✓ 所有必需文件已生成
echo.
echo 输出文件列表：
echo ----------------------------------------
dir /b "%OUTPUT_DIR%\*.dll" 2>nul
dir /b "%OUTPUT_DIR%\*.json" 2>nul
dir /b "%OUTPUT_DIR%\*.ini" 2>nul
dir /b "%OUTPUT_DIR%\*.png" 2>nul
echo ----------------------------------------
echo.

REM 显示文件大小
echo 文件大小：
for %%F in ("%OUTPUT_DIR%\HeadshotTip.dll") do echo   HeadshotTip.dll: %%~zF 字节
for %%F in ("%OUTPUT_DIR%\0Harmony.dll") do echo   0Harmony.dll: %%~zF 字节
for %%F in ("%OUTPUT_DIR%\Newtonsoft.Json.dll") do echo   Newtonsoft.Json.dll: %%~zF 字节
echo.

echo ========================================
echo  编译完成！✓
echo ========================================
echo.
echo Mod 位置: %OUTPUT_DIR%
echo.
echo 下一步：
echo 1. 运行 deploy.bat 部署到游戏（需先配置游戏路径）
echo 2. 或手动复制 %OUTPUT_DIR% 文件夹
echo    到游戏的 Duckov_Data\Mods\ 目录
echo.
echo 3. 启动游戏，在 Mods 菜单中启用
echo 4. 游戏中按 F8/F9 测试功能
echo.
pause
