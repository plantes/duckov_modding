@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  RunWhileEating Mod 一键编译
echo ========================================
echo.

REM ===== 检查 .NET SDK =====
echo [1/4] 检查 .NET SDK...

dotnet --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 .NET SDK
    echo.
    echo 请先安装 .NET SDK 8.0+
    echo 下载地址: https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VERSION=%%i
echo ✓ 找到 .NET SDK: !DOTNET_VERSION!
echo.

REM ===== 清理旧输出 =====
echo [2/4] 清理旧的编译输出...

if exist "RunWhileEating\bin" rmdir /s /q "RunWhileEating\bin" 2>nul
if exist "RunWhileEating\obj" rmdir /s /q "RunWhileEating\obj" 2>nul
if exist "RunWhileEating\ReleaseExample\RunWhileEating\*.dll" del /q "RunWhileEating\ReleaseExample\RunWhileEating\*.dll" 2>nul
if exist "RunWhileEating\ReleaseExample\RunWhileEating\*.pdb" del /q "RunWhileEating\ReleaseExample\RunWhileEating\*.pdb" 2>nul

echo ✓ 清理完成
echo.

REM ===== 编译项目 =====
echo [3/4] 开始编译项目（Release 配置）...
echo.
echo ----------------------------------------

dotnet build RunWhileEating.sln -c Release -v minimal

echo ----------------------------------------
echo.

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 编译失败！
    echo.
    echo 可能的原因：
    echo 1. 游戏路径配置错误
    echo    - 检查 RunWhileEating\RunWhileEating.csproj 中的 DuckovPath
    echo    - 确保游戏已安装且路径正确
    echo.
    echo 2. 缺少游戏 DLL 文件
    echo    - 检查 {游戏目录}\Duckov_Data\Managed\ 是否存在
    echo.
    echo 3. NuGet 包问题
    echo    - 运行: dotnet restore
    echo.
    pause
    exit /b 1
)

REM ===== 验证输出 =====
echo [4/4] 验证编译输出...
echo.

set "OUTPUT_DIR=RunWhileEating\ReleaseExample\RunWhileEating"
set "MISSING="

if not exist "%OUTPUT_DIR%\RunWhileEating.dll" (
    echo [错误] 缺少 RunWhileEating.dll
    set MISSING=1
)

if not exist "%OUTPUT_DIR%\0Harmony.dll" (
    echo [错误] 缺少 0Harmony.dll
    set MISSING=1
)

if not exist "%OUTPUT_DIR%\info.ini" (
    echo [错误] 缺少 info.ini
    set MISSING=1
)

if defined MISSING (
    echo.
    echo 编译完成但缺少必要文件！
    echo 请检查编译输出
    pause
    exit /b 1
)

echo ✓ 所有必需文件已生成
echo.

echo ========================================
echo  编译成功！✓
echo ========================================
echo.
echo Mod 位置: %OUTPUT_DIR%
echo.
echo 文件列表：
echo ----------------------------------------
dir /b "%OUTPUT_DIR%\*.dll" 2>nul
dir /b "%OUTPUT_DIR%\*.ini" 2>nul
echo ----------------------------------------
echo.
echo 下一步：
echo 1. 运行 deploy.bat 部署到游戏（需先配置游戏路径）
echo 2. 或手动复制 %OUTPUT_DIR% 文件夹
echo    到游戏的 Duckov_Data\Mods\ 目录
echo.
echo 3. 启动游戏，在 Mods 菜单中启用
echo 4. 游戏中按 F11 查看状态
echo.
pause
