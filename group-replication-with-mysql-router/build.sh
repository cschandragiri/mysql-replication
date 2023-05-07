#!/bin/bash
# https://www.youtube.com/watch?v=JR7J_STLE5Y
#docker-compose down -v
#rm -rf data/*
#docker-compose up --build -d

for N in {1..3}
do
  until docker exec node$N sh -c 'export MYSQL_PWD=root; mysql -u root -e ";"'
  do
      echo "Waiting for node$N database connection..."
      sleep 4
  done
done

STATEMENT='SET SQL_LOG_BIN = 0; CREATE USER "replication_user"@"%"; GRANT REPLICATION SLAVE ON *.* TO "replication_user"@"%"; FLUSH PRIVILEGES;'
docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"
STATEMENT="CHANGE MASTER TO MASTER_USER='replication_user' for channel 'group_replication_recovery'; SET GLOBAL group_replication_bootstrap_group= ON; START GROUP_REPLICATION; SET GLOBAL group_replication_bootstrap_group= OFF; SELECT * FROM performance_schema.replication_group_members;"
CMD='export MYSQL_PWD=root; mysql -u root -e "'
CMD+="$STATEMENT"
CMD+='"'
docker exec node1 sh -c "$CMD"

for N in 2 3
do
  echo "Starting group replication on node$N"
  STATEMENT="CHANGE MASTER TO MASTER_USER='replication_user' for channel 'group_replication_recovery'; START GROUP_REPLICATION;"
  CMD='export MYSQL_PWD=root; mysql -u root -e "'
  CMD+="$STATEMENT"
  CMD+='"'
  docker exec node$N sh -c "$CMD"
  STATEMENT='SELECT * FROM performance_schema.replication_group_members;'
  docker exec node$N sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"
done

STATEMENT='SELECT * FROM performance_schema.replication_group_members;'
docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"

STATEMENT='CREATE USER "router_user"@"%" IDENTIFIED BY "router_password"; GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO "router_user"@"%"; FLUSH PRIVILEGES;'
docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"
