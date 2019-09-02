# spring-boot-sample-web-ui-gradle
----

### 프로젝트
Docker를 이용한 웹 어플리케이션 서비스 구현

### ENV (Ubuntu)
- gradle : 5.5 <br>
- java version: 1.8 <br>
- docker Docker : 19.03.1 <br>
- docker-compose : 1.24.1 <br>

### 프로젝트 실행 방법
#### 1. Git Clone
> $ git clone https://github.com/17billion/spring-boot-sample-web-ui-gradle.git <br>
> $ cd spring-boot-sample-web-ui-gradle/
```
spring-boot-sample-web-ui-gradle# ls
Dockerfile  README.md  bin  build.gradle  deploy.sh  devops.sh  docker-compose.yml  logs  nginx.conf  src
```

#### 2. 프로젝트 빌드 (Gradle Build)
> $ gradle build
```
spring-boot-sample-web-ui-gradle# ls
Dockerfile  README.md  bin  build  build.gradle  deploy.sh  devops.sh  docker-compose.yml  logs  nginx.conf  src  target
```

#### 3. 이미지 생성 (Docker Build)
> $ docker build --tag webui:0.1 .
```
spring-boot-sample-web-ui-gradle# docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
webui                   0.1                 e4e62b350e8d        5 seconds ago       136MB
```

#### 4. 컨테이너 환경 전체 실행 (Docker-Compose Up)
> $ chmod 755 devops.sh deploy.sh  <br>
> $ ./devops.sh start <br>
> (spring boot log 확인) $ tail -F logs/data.log
```
spring-boot-sample-web-ui-gradle# ls -al de*
-rwxr-xr-x 1 root root 747  9월  1 11:44 deploy.sh
-rwxr-xr-x 1 root root 410  9월  1 11:59 devops.sh

/spring-boot-sample-web-ui-gradle# ./devops.sh start
“Starting docker-compose”
Creating network "spring-boot-sample-web-ui-gradle_default" with the default driver
Creating spring-boot-sample-web-ui-gradle_reverse-proxy_1 ... done
Creating spring-boot-sample-web-ui-gradle_webui_b_1       ... done
Creating spring-boot-sample-web-ui-gradle_webui_a_1       ... done

spring-boot-sample-web-ui-gradle# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
6f8655d357da        webui:0.1           "/bin/sh -c 'java or…"   54 seconds ago      Up 45 seconds                            spring-boot-sample-web-ui-gradle_webui_a_1
92e75f816fd8        webui:0.1           "/bin/sh -c 'java or…"   54 seconds ago      Up 46 seconds                            spring-boot-sample-web-ui-gradle_webui_b_1
59b53fdbd685        nginx:1.15-alpine   "nginx -g 'daemon of…"   54 seconds ago      Up 47 seconds       0.0.0.0:80->80/tcp   spring-boot-sample-web-ui-gradle_reverse-proxy_1

spring-boot-sample-web-ui-gradle# tail -F logs/data.log
2019-09-01 03:51:01.704 29b7ddd5bd79 [main] INFO  o.s.j.e.a.AnnotationMBeanExporter - Registering beans for JMX exposure on startup
2019-09-01 03:51:02.026 29b7ddd5bd79 [main] INFO  o.s.b.w.e.tomcat.TomcatWebServer - Tomcat started on port(s): 8080 (http) with context path ''
2019-09-01 03:51:02.796 fd1df3e9bb04 [main] INFO  o.s.b.w.e.tomcat.TomcatWebServer - Tomcat started on port(s): 8080 (http) with context path ''
2019-09-01 03:51:02.852 fd1df3e9bb04 [main] INFO  sample.web.ui.SampleWebUiApplication - Started SampleWebUiApplication in 29.713 seconds (JVM running for 34.637)
```

#### 5. spring boot 정상구동 확인 후 health check (정상구동시 까지 시간이 걸림) <br>
(웹서버는 Reverse proxy 80 port, Round robin 방식으로 설정)
> $ for ((i=1;i<=10;i++)); do curl localhost:80/health; done <br>
> (로그 확인) $ grep "Health Check" logs/data.log
```
spring-boot-sample-web-ui-gradle# for ((i=1;i<=10;i++)); do curl localhost:80/health; done
{"status":"200"}{"status":"200"}{"status":"200"}{"status":"200"}{"status":"200"}{"status":"200"}{"status":"200"}{"status":"200"}{"status":"200"}{"status":"200"}

spring-boot-sample-web-ui-gradle# grep "Health Check" logs/data.log
(Container Host : 92e75f816fd8, 92e75f816fd8)
22019-09-01 03:09:05.239 92e75f816fd8 [http-nio-8080-exec-10] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.282 6f8655d357da [http-nio-8080-exec-1] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.330 92e75f816fd8 [http-nio-8080-exec-1] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.371 6f8655d357da [http-nio-8080-exec-2] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.422 92e75f816fd8 [http-nio-8080-exec-2] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.466 6f8655d357da [http-nio-8080-exec-3] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.508 92e75f816fd8 [http-nio-8080-exec-3] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.539 6f8655d357da [http-nio-8080-exec-4] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.590 92e75f816fd8 [http-nio-8080-exec-4] INFO  sample.web.ui.mvc.MessageController - Health Check
2019-09-01 03:09:05.634 6f8655d357da [http-nio-8080-exec-5] INFO  sample.web.ui.mvc.MessageController - Health Check
```

#### 5. 웹어플리케이션 무중단 배포 방법 예시
1) 신규 이미지 생성 
> $ docker build --tag webui:0.2 .
2) docker-compose.yml 파일 내 webui_a, webui_b service 이미지를 webui:0.2로 변경
3) 무중단 배포
> $ ./devops.sh deploy
```
spring-boot-sample-web-ui-gradle# docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
webui                   0.1                 e4e62b350e8d        28 minutes ago      136MB
webui                   0.2                 e4e62b350e8d        28 minutes ago      136MB

/spring-boot-sample-web-ui-gradle# cat docker-compose.yml
version: '3.7'
services:
  reverse-proxy:
    image: nginx:1.15-alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    ports:
      - 80:80
  webui_a:
    image: webui:0.2
    volumes:
      - ./logs:/webui/logs

  webui_b:
    image: webui:0.2
    volumes:
      - ./logs:/webui/logs


spring-boot-sample-web-ui-gradle# ./devops.sh deploy
“Deploying docker-compose”
Stopping spring-boot-sample-web-ui-gradle_webui_a_1 ... done
Recreating spring-boot-sample-web-ui-gradle_webui_a_1 ... done
WARNING: The scale command is deprecated. Use the up command with the --scale flag instead.
Desired container number already achieved
Not connected. Waiting..
Not connected. Waiting..
Health Check Status = 200
Success!
Stopping spring-boot-sample-web-ui-gradle_webui_b_1 ... done
Recreating spring-boot-sample-web-ui-gradle_webui_b_1 ... done
WARNING: The scale command is deprecated. Use the up command with the --scale flag instead.
Desired container number already achieved

spring-boot-sample-web-ui-gradle# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                NAMES
ba09c012fd51        webui:0.2           "/bin/sh -c 'java or…"   25 seconds ago       Up 22 seconds                            spring-boot-sample-web-ui-gradle_webui_b_1
d8aa74414e0e        webui:0.2           "/bin/sh -c 'java or…"   About a minute ago   Up 58 seconds                            spring-boot-sample-web-ui-gradle_webui_a_1
59b53fdbd685        nginx:1.15-alpine   "nginx -g 'daemon of…"   25 minutes ago       Up 5 minutes        0.0.0.0:80->80/tcp   spring-boot-sample-web-ui-gradle_reverse-proxy_1

```

#### 6. Scale 변경 방법 예시
> $ docker-compose scale webui_a=2 <br>
> $ docker-compose scale webui_b=2
```
spring-boot-sample-web-ui-gradle# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                NAMES
5c90d553d616        webui:0.2           "/bin/sh -c 'java or…"   51 seconds ago       Up 44 seconds                            spring-boot-sample-web-ui-gradle_webui_b_2
2c16ac19a371        webui:0.2           "/bin/sh -c 'java or…"   About a minute ago   Up 57 seconds                            spring-boot-sample-web-ui-gradle_webui_a_2
b209e2b8cbd2        webui:0.2           "/bin/sh -c 'java or…"   8 minutes ago        Up 7 minutes                             spring-boot-sample-web-ui-gradle_webui_b_1
c7acc0b21b76        webui:0.2           "/bin/sh -c 'java or…"   8 minutes ago        Up 8 minutes                             spring-boot-sample-web-ui-gradle_webui_a_1
59b53fdbd685        nginx:1.15-alpine   "nginx -g 'daemon of…"   29 minutes ago       Up 29 minutes       0.0.0.0:80->80/tcp   spring-boot-sample-web-ui-gradle_reverse-proxy_1
```

#### 7. 컨테이너 환경 전체 재시작 (Restart Docker-Compose) <br>
> $ ./devops.sh restart

#### 8. 컨테이너 환경 전체 중지 (Stop  Docker-Compose) <br>
> $ ./devops.sh stop

### 문의사항
Email. 17earlgrey@gmail.com <br>
Blog. https://17billion.github.io/
