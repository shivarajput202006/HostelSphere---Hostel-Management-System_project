@echo off
setlocal
set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
set "CATALINA_HOME=C:\xampp\tomcat"
"%CATALINA_HOME%\bin\catalina.bat" stop
endlocal
