#!/bin/bash

counter=1000
while [ $counter -le 20000 ]
do
  SQL_QUERY="INSERT INTO code (node, number) VALUES ('router', $counter)"
  CMD='export MYSQL_PWD=password; mysql -u user playgroundDB -e "'
  CMD+="$SQL_QUERY"
  CMD+='"'
  # execute the SQL query
  docker exec router sh -c "$CMD"
  counter=$((counter+1))
done
