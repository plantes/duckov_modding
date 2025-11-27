@echo off
chcp 65001 >nul
echo ====================================
echo  清理编译输出和临时文件
echo ====================================
echo.

echo 正在清理...

REM 清理编译输出
if exist "HeadshotTip\bin" (
    rmdir /s /q "HeadshotTip\bin"
    echo ✓ 删除 bin 目录
)

if exist "HeadshotTip\obj" (
    rmdir /s /q "HeadshotTip\obj"
    echo ✓ 删除 obj 目录
)

REM 清理 ReleaseExample 中的 DLL
if exist "HeadshotTip\ReleaseExample\HeadshotTip\*.dll" (
    del /q "HeadshotTip\ReleaseExample\HeadshotTip\*.dll"
    echo ✓ 删除输出 DLL
)

if exist "HeadshotTip\ReleaseExample\HeadshotTip\*.pdb" (
    del /q "HeadshotTip\ReleaseExample\HeadshotTip\*.pdb"
    echo ✓ 删除 PDB 文件
)

REM 清理 Visual Studio 缓存
if exist ".vs" (
    rmdir /s /q ".vs"
    echo ✓ 删除 .vs 目录
)

REM 清理用户配置文件
if exist "HeadshotTip\*.user" (
    del /q "HeadshotTip\*.user"
    echo ✓ 删除用户配置文件
)

echo.
echo ====================================
echo  清理完成！
echo ====================================
pause
