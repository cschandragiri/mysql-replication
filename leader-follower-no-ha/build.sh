#!/bin/bash

docker-compose down -v
rm -rf data/*
docker-compose up --build -d

until docker exec primary sh -c 'export MYSQL_PWD=root; mysql -u root -e ";"'
do
    echo "Waiting for primary database connection..."
    sleep 4
done

STATEMENT='CREATE USER "replication_user"@"%" IDENTIFIED BY "replication_password"; GRANT REPLICATION SLAVE ON *.* TO "replication_user"@"%"; FLUSH PRIVILEGES;'
docker exec primary sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"

MASTER_STATUS=`docker exec primary sh -c 'export MYSQL_PWD=root; mysql -u root -e "SHOW MASTER STATUS"'`
echo "Primary Status: $MASTER_STATUS"
CURRENT_LOG=`echo $MASTER_STATUS | awk '{print $6}'`
echo "Primary CURRENT_LOG: $CURRENT_LOG"
CURRENT_POS=`echo $MASTER_STATUS | awk '{print $7}'`
echo "Primary CURRENT_POS: $CURRENT_POS"

declare -a arr=("replica1" "replica2")

for replica in "${arr[@]}"
do
   until docker exec $replica sh -c 'export MYSQL_PWD=root; mysql -u root -e ";"'
   do
       echo "Waiting for $replica database connection..."
       sleep 4
   done

   STATEMENT="CHANGE MASTER TO MASTER_HOST='primary',MASTER_USER='replication_user',MASTER_PASSWORD='replication_password',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
   CMD='export MYSQL_PWD=root; mysql -u root -e "'
   CMD+="$STATEMENT"
   CMD+='"'
   docker exec $replica sh -c "$CMD"
   SLAVE_STATUS=`docker exec $replica sh -c "export MYSQL_PWD=root; mysql -u root -e 'SHOW SLAVE STATUS \G'"`
   echo "Slave $replica Status: $SLAVE_STATUS"
done

#start_slave_stmt=""
#start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
#start_slave_cmd+="$start_slave_stmt"
#start_slave_cmd+='"'
#docker exec mysql_slave sh -c "$start_slave_cmd"
#
#docker exec mysql_slave sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"