#!/bin/bash

while true
do
  echo "****************"
  SQL_QUERY="use playgroundDB; SELECT count(1) from code;"
  docker exec router sh -c "export MYSQL_PWD=password; mysql -u user playgroundDB -e '$SQL_QUERY'"
  sleep 1
done