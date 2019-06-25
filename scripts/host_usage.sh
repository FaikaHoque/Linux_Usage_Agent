#! /bin/bash
psql_host=$1
port=$2
db_name=$3
user_name=$4
password=$5

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
host_id=$(cat ~/host_id)
memory_free=$(vmstat --unit M | tail -1 | awk  '{print $4}')


cpu_idel=$(vmstat -t | tail -1 | awk '{print $15}')
cpu_kernel=$(vmstat -t | tail -1 | awk '{print $14}')
disk_io=$(vmstat -d | tail -1 | awk '{print $10}')
disk_available=$(df -BM / |tail -1 | awk '{print $4}')

insert_stmt=$(cat <<-END
INSERT INTO host_usage("timestamp", host_id, memory_free, cpu_idel, cpu_kernel, disk_io, disk_available) VALUES ('$timestamp', $host_id, $memory_free, $cpu_idel, $cpu_kernel, $disk_io, 5624)
END
)

echo $insert_stmt
export PGPASSWORD=$password
psql -h $psql_host -p $port -U $user_name -d $db_name -c  "$insert_stmt"
sleep 1



