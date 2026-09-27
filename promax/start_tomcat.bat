@echo off
setlocal

echo ========================================================
echo   Starting Apache Tomcat for HostelSphere
echo ========================================================

set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
set "CATALINA_HOME=C:\xampp\tomcat"
set "CATALINA_BASE=C:\xampp\tomcat"

if not exist "%JAVA_HOME%" (
    echo [WARNING] Default JDK path not found. Detecting from system...
    for /f "tokens=*" %%i in ('where java') do (
        set "JAVA_BIN=%%~dpi"
    )
)

echo [1/2] Launching Tomcat Server in new window...
start "Tomcat Server (HostelSphere)" "%CATALINA_HOME%\bin\catalina.bat" run

echo [2/2] Opening Application URL:
echo       http://localhost:8080/HostelManagementSystem/
echo ========================================================

ping 127.0.0.1 -n 4 >nul
start http://localhost:8080/HostelManagementSystem/

endlocal
