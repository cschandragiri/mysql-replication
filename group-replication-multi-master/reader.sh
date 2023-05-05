#!/bin/bash

for N in {1..3}
do
  until docker exec node$N sh -c 'export MYSQL_PWD=root; mysql -u root -e ";"'
  do
      echo "Waiting for node$N database connection..."
      sleep 4
  done
done

while true
do
  echo "****************"
  SQL_QUERY="use playgroundDB; SELECT node, count(1) from code group by node;"
  docker exec node1 sh -c "export MYSQL_PWD=password; mysql -u user playgroundDB -e '$SQL_QUERY'"
  sleep 1
done