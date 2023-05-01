#!/bin/bash

docker-compose down -v
rm -rf data/*
docker-compose up --build -d

until docker exec node1 sh -c 'export MYSQL_PWD=root; mysql -u root -e ";"'
do
    echo "Waiting for node1 database connection..."
    sleep 4
done

STATEMENT='SET @@GLOBAL.group_replication_bootstrap_group=1; CREATE USER "replication_user"@"%"; GRANT REPLICATION SLAVE ON *.* TO "replication_user"@"%"; FLUSH PRIVILEGES; CHANGE MASTER TO MASTER_USER='replication_user' for channel 'group_replication_recovery'; START GROUP_REPLICATION; SET @@GLOBAL.group_replication_bootstrap_group=0; SELECT * FROM performance_schema.replication_group_members;'
docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"

STATEMENT='CHANGE MASTER TO MASTER_USER='replication_user' for channel 'group_replication_recovery'; START GROUP_REPLICATION;'
for N in 2 3
do docker exec node$N sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"
done

STATEMENT='SELECT * FROM performance_schema.replication_group_members;'
docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root -e '$STATEMENT'"
