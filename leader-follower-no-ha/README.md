Docker MySQL master-slave replication 
========================

MySQL 8.0 master-slave replication playground with using Docker. We are using docker compose to build start a cluster
of 1 primary and 2 replica mysql 8 servers along with a percona monitoring and management (pmm) server.

![Alt text](arch.png?raw=true "Arch")

## Run

#### Initialize the cluster
Create a mysql cluster with gtid based replication enabled and configure pmm server.
```bash
chmod +x build.sh
./build.sh
```

#### Log into master
```bash
docker exec primary sh -c "export MYSQL_PWD=root; mysql -u root playgroundDB -e 'select count(1) from code \G'"
```

#### Log into replica instances
```bash
docker exec replica1 sh -c "export MYSQL_PWD=root; mysql -u root playgroundDB -e 'select count(1) from code \G'"
docker exec replica2 sh -c "export MYSQL_PWD=root; mysql -u root playgroundDB -e 'select count(1) from code \G'"
```

#### Debugging
```bash
docker logs -f {container}
```

#### Send traffic to mysql cluster
```bash
chmod +x writer.sh
./writer.sh
```
#### PMM monitoring
PMM server runs on localhost:80 and login using username: admin, password: admin

#### PMM Configuration
Go to configuration and click `Add Service`. Inside add service page, select MySQL 
Instance. Iteratively add all the mysql instances with hostname names: { primary, replica1, replica2 }, port 3306 for 
all three instances, with username and password being `root` for all three.

To monitor the replication lag, navigate to MySQL => High Availability => Replication Summary => Select any of the replica instances.


![Alt text](pmm1.png?raw=true "PMM1")



