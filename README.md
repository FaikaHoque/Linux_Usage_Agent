## Introduction

Cluster Monitor Agent is an internal implement that monitors the cluster resources of a Linux based system or a group of systems/nodes. It helps the infrastructure team to keep track the current system status (CPU and memory) by collecting performance data. We need a program (agent) to gather data and store into database. The program will be installed on every host/server/node in the cluster system. 

## Architecture and Design

### Cluster Diagram

Following diagram shows the architecture of three Linux hosts, a database and agents.

![Linux-1](https://user-images.githubusercontent.com/51927068/61390437-ca073780-a888-11e9-9f71-bac0ce4a226f.jpg)

### Work Flow

* We need a database instance to store data.
* We need a host_agent consists of two bash scripts which will be installed on every node/host.
  * `host_info.sh`collects the host hardware information and insert into the database.
  * `host_usage.sh` collects the current host usage (CPU and Memory) and then insert into the database. It will be triggered by the `crontab` every minute.
  * `inti.sql` creates a database and two tables. 

### Description

For this project we create two database tables: `host_info` table and `host_usage` table. Moreover, we create two bash scripts: `host_info.sh` and `host_usage.sh`. A brief description of these tables are given below. 

##### Database Tables

* **host_info**  - This table contains hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, "timestamp", total_mem information of each host connected to the cluster. The primary key of this table is id which will be auto incremented into the database.
* **host_usage** - This table contains "time stamp", host_id , memory_free, cpu_idel, cpu_kernel, disk_io, disk_available. This will run on each server/node every minute to collect the CPU usage information and insert into the database.

##### Bash Scripts

* **host_info.sh** - This script collects the host hardware information  and insert into the database. It will run only once.
* **host_usage.sh** - This script collects current host usage of CPU and memory and insert into the database. It will run by `crontab` in every minute. 

## Usage

* **Initiate database and tables**: To create a database in PostgreSQL, we use the command `CREATE DATABASE db_name;` Once the database is created, we can create two tables by running the command `psql -h psql_host -U psql_user db_name -f init.sql `. `Init_sql` file contains two tables: host_info and host_usage.
* **host_info.sh usage:** To run this script, we use the command `bash host_info.sh psql_host psql_port db_name psql_password`. This script takes five arguments that need to be passed into the script. 
* **host_usage.sh usage:** To run this script, we use the same command as we done for host_info except the file name. `bash host_usage.sh psql_host psql_port db_name psql_password`. This script also takes five arguments that need to be passed into the script and we can run the script whenever we need to know the CPU and memory information from the server/host.
* **crontab:** crontab can be used to automate the executing of the script host_usage in regular intervals. Adding the following job to crontab will run the script once every minute and create a log-file: `* * * * * bash path/host_usage.sh psql_host psql_port db_name psql_user psql_password > /tmp/host_usage.log`





