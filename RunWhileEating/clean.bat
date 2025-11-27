@echo off
chcp 65001 >nul
echo ====================================
echo  清理编译输出
echo ====================================
echo.

echo 清理以下目录：
echo - RunWhileEating\bin\
echo - RunWhileEating\obj\
echo - RunWhileEating\ReleaseExample\RunWhileEating\*.dll
echo - RunWhileEating\ReleaseExample\RunWhileEating\*.pdb
echo.

set /p confirm="确认清理? (y/n): "
if /i not "%confirm%"=="y" (
    echo 已取消
    pause
    exit /b 0
)

echo.
echo 清理中...

REM 清理 bin 和 obj
if exist "RunWhileEating\bin" (
    rmdir /s /q "RunWhileEating\bin"
    echo ✓ 已删除 bin\
)

if exist "RunWhileEating\obj" (
    rmdir /s /q "RunWhileEating\obj"
    echo ✓ 已删除 obj\
)

REM 清理输出 DLL
if exist "RunWhileEating\ReleaseExample\RunWhileEating\*.dll" (
    del /q "RunWhileEating\ReleaseExample\RunWhileEating\*.dll"
    echo ✓ 已删除输出 DLL
)

if exist "RunWhileEating\ReleaseExample\RunWhileEating\*.pdb" (
    del /q "RunWhileEating\ReleaseExample\RunWhileEating\*.pdb"
    echo ✓ 已删除 PDB 文件
)

REM 清理打包目录
if exist "RunWhileEating_Release" (
    rmdir /s /q "RunWhileEating_Release"
    echo ✓ 已删除打包目录
)

echo.
echo ====================================
echo  清理完成！
echo ====================================
echo.
pause
