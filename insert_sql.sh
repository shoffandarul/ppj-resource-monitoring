# Inisialisasi variabel koneksi MySQL
MYSQL_DATABASE="resource_log"
MYSQL_USER="root"
MYSQL_PASSWORD="root"

insert(){
    mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE << EOF
insert into resource_logs (cpu_usage, ram_usage, storage_usage) values ($1, $2, $3);
EOF
}