#!/bin/bash

for N in {1..3}
do
  until docker exec node$N sh -c 'export MYSQL_PWD=root; mysql -u root -e ";"'
  do
      echo "Waiting for node$N database connection..."
      sleep 4
  done
done

counter=1000
while [ $counter -le 20000 ]
do
  for N in {1..3}
  do
    # build the SQL query
    node="node$N"
    SQL_QUERY="INSERT INTO code (node, number) VALUES ('$node', $counter)"
    CMD='export MYSQL_PWD=password; mysql -u user playgroundDB -e "'
    CMD+="$SQL_QUERY"
    CMD+='"'
    # execute the SQL query
    docker exec node$N sh -c "$CMD"
    counter=$((counter+1))
  done
done
