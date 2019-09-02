FROM openjdk:8-jdk-alpine

RUN mkdir /webui
WORKDIR /webui

RUN apk --no-cache add curl
ARG buildDir=build/unpack

COPY ${buildDir}/BOOT-INF/classes BOOT-INF/classes
COPY ${buildDir}/BOOT-INF/lib BOOT-INF/lib
COPY ${buildDir}/META-INF META-INF
COPY ${buildDir}/org org

CMD java org.springframework.boot.loader.JarLauncher
