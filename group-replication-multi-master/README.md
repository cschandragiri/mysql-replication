### Credit
This dockerized demo of mysql group replication is inspired by [Wagner Franchin's](https://blog.devops.dev/setting-up-mysql-group-replication-with-mysql-docker-images-f5eedd44fa2b) blog on medium and MySQL Group Replication [video](https://www.youtube.com/watch?v=JR7J_STLE5Y)

### MySQL Group Replication

MySQL Group Replication uses a distributed, multi-master replication (can be configured to single primary) protocol that enables all members of the group to act as both a source and a target for replication, allowing changes to be made on any member and automatically propagated to all other members in the group. Group Replication uses a consensus algorithm to ensure that writes are properly propagated and committed to all members in the group. Consistency guarantees can be configured. (Default: Eventual Consistency).

MySQL Group Replication is a key component of InnoDB Cluster. InnoDB Cluster is a high availability solution for MySQL that provides automatic failover and integrated data replication. It uses Group Replication to ensure that data is replicated to all nodes in the cluster, and that if one node fails, another node can take over as the primary node.
![Alt text](Arch.png?raw=true "Arch")

Docker MySQL group replication
========================

In this setup we are using 3 instances of MySQL 8 cluster (all configured as PRIMARY) along with a percona monitoring and management (pmm) server.
We are sending equal amount of traffic to all 3 instances via a bash process and will be doing a read from another bash process.
All 3 instances can take both read and write traffic. 

### Pre-requisite
[docker installed on local machine](https://www.docker.com/)

## Run

#### Initialize the cluster
Create 3 instances of MySQL 8.0 group replication cluster and configure pmm server.
```bash
chmod +x build.sh
./build.sh
```
#### Wait for the MySQL group replication cluster to come ONLINE
```agsl
docker exec node1 sh -c "export MYSQL_PWD=root; mysql -u root playgroundDB -e 'SELECT * FROM performance_schema.replication_group_members; \G'"
```
![Alt text](online.png?raw=true "Online")

#### Send traffic to MySQL group replication cluster
```bash
chmod +x writer.sh
./writer.sh
```

#### Read from MySQL group replication cluster
```bash
chmod +x reader.sh
./reader.sh
```

#### Improvements
This setup is not configured for high availability yet, manually shutting down one of the dockers will send read/write
traffic to remaining instances. 
