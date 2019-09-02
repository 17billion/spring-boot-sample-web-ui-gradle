#!/bin/bash

dc_cmd="docker-compose"
deploy_sh="deploy.sh"
case $1 in
   start)
          echo “Starting docker-compose”
          $dc_cmd up -d
	  ;;
   stop) 
          echo “Stopping docker-compose”
          $dc_cmd stop 
	  ;;
   restart)
          echo “Restarting docker-compose”
	  $dc_cmd restart
	  ;;
   deploy)
          echo “Deploying docker-compose”
	  ./$deploy_sh
esac

exit 0
