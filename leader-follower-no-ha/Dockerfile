##### Generate mysql.conf.cnf for each mysql instance ####
FROM alpine:3.14 as builder

WORKDIR /app
COPY conf/mysql.conf.cnf.tmp /app/mysql.conf.cnf.tmp
RUN apk add --no-cache gettext
# Build Arguments must be explicitly called out in ARG
ARG SERVER_ID
# Generate the configuration file using envsubst
RUN envsubst < /app/mysql.conf.cnf.tmp > /app/mysql.conf.cnf

FROM mysql:8.0
COPY --from=builder /app/mysql.conf.cnf /etc/mysql/conf.d/
COPY conf/init.sql /docker-entrypoint-initdb.d/init.sql

#Expose the mysql port
EXPOSE $MYSQL_PORT
CMD ["mysqld", "--bind-address=0.0.0.0"]