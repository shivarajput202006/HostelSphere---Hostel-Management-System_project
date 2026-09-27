@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   HostelSphere - Compiling Java Backend (MongoDB + Razorpay)
echo ========================================================

set "PROJECT_DIR=%~dp0"
set "BIN_DIR=%PROJECT_DIR%WEB-INF\classes"
set "LIB_DIR=%PROJECT_DIR%WEB-INF\lib"
set "TOMCAT_LIB=C:\xampp\tomcat\lib"

if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

echo [1/3] Detecting Classpath Libraries...
set "CP=%TOMCAT_LIB%\servlet-api.jar;%TOMCAT_LIB%\jsp-api.jar;%LIB_DIR%\mongodb-driver-sync-4.11.1.jar;%LIB_DIR%\mongodb-driver-core-4.11.1.jar;%LIB_DIR%\bson-4.11.1.jar;%LIB_DIR%\json-20240303.jar;%LIB_DIR%\jstl-1.2.jar;%BIN_DIR%"

echo [2/3] Collecting Java Source Files...
(
    if exist "%PROJECT_DIR%config\*.java" dir /b /s "%PROJECT_DIR%config\*.java"
    if exist "%PROJECT_DIR%controller\*.java" dir /b /s "%PROJECT_DIR%controller\*.java"
    if exist "%PROJECT_DIR%dao\*.java" dir /b /s "%PROJECT_DIR%dao\*.java"
    if exist "%PROJECT_DIR%model\*.java" dir /b /s "%PROJECT_DIR%model\*.java"
    if exist "%PROJECT_DIR%service\*.java" dir /b /s "%PROJECT_DIR%service\*.java"
    if exist "%PROJECT_DIR%util\*.java" dir /b /s "%PROJECT_DIR%util\*.java"
    if exist "%PROJECT_DIR%test\*.java" dir /b /s "%PROJECT_DIR%test\*.java"
) > "%PROJECT_DIR%sources.txt"

echo [3/3] Compiling Java classes with javac...
javac -encoding UTF-8 -cp "%CP%" -d "%BIN_DIR%" @"%PROJECT_DIR%sources.txt"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo   BUILD SUCCESSFUL! All classes compiled to:
    echo   WEB-INF\classes
    echo ========================================================
    if exist "%PROJECT_DIR%sources.txt" del "%PROJECT_DIR%sources.txt"
) else (
    echo.
    echo [ERROR] Compilation failed! Please inspect error messages above.
    exit /b 1
)

endlocal
