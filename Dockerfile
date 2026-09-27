FROM tomcat:9.0-jdk17-temurin

RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY promax/ /usr/local/tomcat/webapps/HostelSphere/

EXPOSE 8080
