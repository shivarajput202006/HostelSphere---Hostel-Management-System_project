@echo off
setlocal

echo ========================================================
echo   HostelSphere - Deploy to XAMPP Tomcat Webapps
echo ========================================================

set "PROJECT_DIR=%~dp0"
set "TOMCAT_WEBAPPS=C:\xampp\tomcat\webapps\HostelManagementSystem"

echo [1/3] Compiling Java classes first...
call "%PROJECT_DIR%compile.bat"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed. Aborting deployment.
    pause
    exit /b 1
)

echo.
echo [2/3] Deploying Web Application to %TOMCAT_WEBAPPS% ...
if not exist "C:\xampp\tomcat\webapps" (
    echo [ERROR] XAMPP Tomcat webapps directory not found at C:\xampp\tomcat\webapps!
    pause
    exit /b 1
)

if not exist "%TOMCAT_WEBAPPS%" mkdir "%TOMCAT_WEBAPPS%"

:: Copy web resources and compiled WEB-INF
if exist "%PROJECT_DIR%index.jsp" copy /Y "%PROJECT_DIR%index.jsp" "%TOMCAT_WEBAPPS%\" >nul
if exist "%PROJECT_DIR%student_dashboard.jsp" copy /Y "%PROJECT_DIR%student_dashboard.jsp" "%TOMCAT_WEBAPPS%\" >nul

if exist "%PROJECT_DIR%admin" xcopy "%PROJECT_DIR%admin" "%TOMCAT_WEBAPPS%\admin" /E /I /Y /Q >nul
if exist "%PROJECT_DIR%student" xcopy "%PROJECT_DIR%student" "%TOMCAT_WEBAPPS%\student" /E /I /Y /Q >nul
if exist "%PROJECT_DIR%css" xcopy "%PROJECT_DIR%css" "%TOMCAT_WEBAPPS%\css" /E /I /Y /Q >nul
if exist "%PROJECT_DIR%js" xcopy "%PROJECT_DIR%js" "%TOMCAT_WEBAPPS%\js" /E /I /Y /Q >nul
if exist "%PROJECT_DIR%assets" xcopy "%PROJECT_DIR%assets" "%TOMCAT_WEBAPPS%\assets" /E /I /Y /Q >nul
if exist "%PROJECT_DIR%WEB-INF" xcopy "%PROJECT_DIR%WEB-INF" "%TOMCAT_WEBAPPS%\WEB-INF" /E /I /Y /Q >nul

echo.
echo [3/3] Deployment Completed Successfully!
echo ========================================================
echo   Access the application in your web browser:
echo   http://localhost:8080/HostelManagementSystem/
echo ========================================================
echo.
pause
endlocal
