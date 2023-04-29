#!/bin/bash

# Write records to primary every 0.1 sec
DB_USER="primary_user"
DB_PASSWORD="primary_password"
DB_NAME="playgroundDB"
TABLE_NAME="code"

# start the loop
counter=1000
while [ $counter -le 1000000 ]
do
  # build the SQL query
  SQL_QUERY="INSERT INTO $TABLE_NAME (code) VALUES ('$counter')"
  # execute the SQL query
  docker exec primary sh -c "export MYSQL_PWD=$DB_PASSWORD; mysql -u $DB_USER $DB_NAME -e '$SQL_QUERY'"
  counter=$((counter+1))
  # wait for 20ms before inserting the next record
  sleep 0.02
done

