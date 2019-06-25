#! /bin/bash

#Setup arguments

psql_host=$1
port=$2
db_name=$3
user_name=$4
password=$5
lscpu_out=`lscpu`

get_hostname(){
hostname=$(hostname -f)
}
get_cpu_number(){
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
}
get_lscpu_value(){
pattern=$1
value=$(echo "$lscpu_out" | egrep "$pattern" | awk -F':' '{print $2}' | xargs)
echo "value=$value"
}
get_cpu_architecture(){
get_lscpu_value "Architecture"
cpu_architecture=$value
}
get_cpu_model(){
cpu_model=$(lscpu|egrep ^Model\ name|awk '{print $3,6$4,$5,$6,$7}')
}
get_cpu_mhz(){
cpu_mhz=$(lscpu|egrep ^CPU\ MHz|awk '{print $3}')
}
get_L2_cache(){
get_lscpu_value "L2 cache"
l2_cache=$value
}

get_hostname
get_cpu_number
get_cpu_architecture
get_cpu_mhz
get_cpu_model
get_L2_cache
total_mem=$(cat /proc/meminfo | grep ^MemFree | awk '{print $2}')
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

insert_stmt=$(cat <<-END
INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, "timestamp") VALUES('${hostname}', ${cpu_number}, '${cpu_architecture}', '${cpu_model}', $cpu_mhz,256, ${total_mem}, '${timestamp}');
END
)
echo $insert_stmt

export PGPASSWORD=$password

psql -h $psql_host -p $port -U $user_name -d $db_name -c "$insert_stmt"
sleep 1

host_id=`psql -h localhost -U postgres host_agent -c "select id from host_info where hostname='${hostname}'" | tail -3 |head -1 | xargs`
echo $host_id > ~/host_id
cat ~/host_id


