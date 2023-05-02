#!/bin/bash
# https://www.youtube.com/watch?v=JR7J_STLE5Y
#docker-compose down -v
#rm -rf data/*
#docker-compose up --build -d

until docker exec node1 sh -c 'export MYSQL_PWD=root; mysql -u root -e ";"'
do
    echo "Waiting for node1 database connection..."
    sleep 4
done

STATEMENT='SET SQL_LOG_BIN = 0; CREATE USER "replication_user"@"%" IDENTIFIED BY "replication_password"; GRANT REPLICATION SLAVE ON *.* TO "replication_user"@"%"; FLUSH PRIVILEGES;'
docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"
STATEMENT="CHANGE MASTER TO MASTER_USER='replication_user', MASTER_PASSWORD='replication_password' for channel 'group_replication_recovery'; INSTALL plugin group_replication SONAME 'group_replication.so'; SET GLOBAL group_replication_bootstrap_group= ON; START GROUP_REPLICATION; SET GLOBAL group_replication_bootstrap_group= OFF; SELECT * FROM performance_schema.replication_group_members;"
CMD='export MYSQL_PWD=root; mysql -u root -e "'
CMD+="$STATEMENT"
CMD+='"'
docker exec node1 sh -c "$CMD"


#STATEMENT='CHANGE MASTER TO MASTER_USER='replication_user' for channel 'group_replication_recovery'; START GROUP_REPLICATION;'
#for N in 2 3
#do docker exec node$N sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"
#done

#STATEMENT='SELECT * FROM performance_schema.replication_group_members;'
#docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"