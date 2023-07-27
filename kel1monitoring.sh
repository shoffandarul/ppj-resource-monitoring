#!/bin/bash
# Inisialisasi token, chat id, dan URL untuk notifikasi Telegram
TOKEN="6120074346:AAFR5WhCg9lrxc0Q3dokSU3Pg1iNOc-ZUNM"
CHAT_ID="-831292086"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

# Inisialisasi file log
log_CPU="/media/sf_ppj/UAS/PantauCPU/cpu.log"
log_RAM="/media/sf_ppj/UAS/PantauRAM/ram.log"
log_storage="/media/sf_ppj/UAS/PantauStorage/storage.log"
log_email="/media/sf_ppj/UAS/PantauEmail/email.log"
log_telegram="/media/sf_ppj/UAS/PantauTelegram/telegram.log"

. /media/sf_ppj/UAS/insert_sql.sh

# Fungsi untuk mengambil penggunaan CPU saat ini
get_cpu_usage() {
    top_val=$(top -bn1 | grep "Cpu(s)")
    cpu_usage=$(echo $top_val | awk '{print int($2 + $4)}')
    echo $cpu_usage
}

# Fungsi untuk mengambil penggunaan RAM saat ini
get_ram_usage() {
    ram_usage=$(free -m | grep Mem | awk '{print int($3/$2 * 100)}')
    echo $ram_usage
}

# Fungsi untuk mengambil penggunaan penyimpanan saat ini
get_storage_usage() {
    storage_usage=$(df -h / | awk 'NR==2 {print int($3/$2 * 100)}')
    echo $storage_usage
}

# Fungsi untuk mengirim notifikasi ke Telegram
send_telegram_message() {
    message="$1"
    echo "" >> $log_telegram
    curl -s -X POST $URL \
        -d "chat_id=$CHAT_ID" \
        -d "text=$message" >> $log_telegram
}

# Fungsi untuk mengirim email menggunakan sSMTP
send_email() {
    email_address='shoffandm@gmail.com'
    email_subject="Penggunaan Sumber Daya"
    email_body="$1"
    # echo -e "To: $email_address\n\nSubject: $email_subject\n$email_body" | /sbin/ssmtp "$email_address"
    echo -e "Subject:${email_subject}\n\n${email_body}" | /sbin/ssmtp ${email_address}
}

# Fungsi untuk mencatat log penggunaan CPU
log_cpu_usage() {
    value=$1
    echo "[$(date +"%d/%b/%Y %H:%M:%S")] CPU Usage: $value%" >> $log_CPU
}

# Fungsi untuk mencatat log penggunaan RAM
log_ram_usage() {
    value=$1
    echo "[$(date +"%d/%b/%Y %H:%M:%S")] RAM Usage: $value%" >> $log_RAM
}

# Fungsi untuk mencatat log penggunaan penyimpanan
log_storage_usage() {
    value=$1
    echo "[$(date +"%d/%b/%Y %H:%M:%S")] Storage Usage: $value%" >> $log_storage
}

# Memantau penggunaan CPU, RAM, dan penyimpanan
pantau_resource() {
    cpu_limit=1
    ram_limit=1
    storage_limit=1

    cpu_usage=$(get_cpu_usage)
    ram_usage=$(get_ram_usage)
    storage_usage=$(get_storage_usage)

    # Mengecek batasan penggunaan CPU
    if [ $cpu_usage -ge $cpu_limit ]; then
        log_cpu_usage "$cpu_usage"
        message="Penggunaan CPU telah melampaui batas yang ditentukan. ⚠️ CPU Usage: $cpu_usage%"
        echo "$message"
        echo "$message" > temp_email.txt
        echo "" >> temp_email.txt
        send_telegram_message "$message"
    fi

    # Mengecek batasan penggunaan RAM
    if [ $ram_usage -ge $ram_limit ]; then
        log_ram_usage "$ram_usage"
        message="Penggunaan RAM telah melampaui batas yang ditentukan. ⚠️ RAM Usage: $ram_usage%"
        echo "$message"
        echo "$message" >> temp_email.txt
        echo "" >> temp_email.txt
        send_telegram_message "$message"
    fi

    # Mengecek batasan penggunaan penyimpanan
    if [ $storage_usage -ge $storage_limit ]; then
        log_storage_usage "$storage_usage"
        message="Penggunaan STORAGE telah melampaui batas yang ditentukan. ⚠️ Storage Usage: $storage_usage%"
        echo "$message"
        echo "$message" >> temp_email.txt
        echo "" >> temp_email.txt
        send_telegram_message "$message"
    fi

    if [ -s "temp_email.txt" ]; then
        send_email "$(cat temp_email.txt)"
        echo "[$(date +"%d/%b/%Y %H:%M:%S")] Email Sent" >> $log_email
        rm temp_email.txt
    fi

    insert $cpu_usage $ram_usage $storage_usage
}

# Menjalankan pemantauan penggunaan CPU, RAM, dan penyimpanan
pantau_resource