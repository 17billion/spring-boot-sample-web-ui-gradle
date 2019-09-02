#!/bin/bash

status=init
aContainerCnt=$(docker ps | grep webui_a | wc -l)
bContainerCnt=$(docker ps | grep webui_b | wc -l)

docker-compose stop webui_a
docker-compose up -d webui_a
docker-compose scale webui_a=$aContainerCnt

while [ "$status" != "200" ];
do
        cid=$( docker ps -f name=webui_a | grep -v CONTAINER | awk '{print $1}' | head -1 )
        sleep 10
        status=$( docker exec $cid curl -m 10 -s -I localhost:8080/health | grep HTTP\/1.1 |  awk {'print $2'})
        if [ "$status" != "200" ]; then
          echo Not connected. Waiting..
        else
          echo Health Check Status = $status
          echo Success!
        fi
done

docker-compose stop webui_b
docker-compose up -d webui_b
docker-compose scale webui_b=$bContainerCnt

