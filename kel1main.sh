#!/bin/bash

# Menerima input dari pengguna
read -p "Masukkan limit CPU (dalam persentase): " cpu
read -p "Masukkan limit RAM (dalam persentase): " ram
read -p "Masukkan limit storage (dalam persentase): " storage
read -p "Masukkan email penerima: " email
read -p "Masukkan jadwal cronjob (format: * * * * *): " cron_schedule

sed -i "s/\(cpu_limit=\)[0-9]\+/\1$cpu/g" kel1monitoring.sh
sed -i "s/\(ram_limit=\)[0-9]\+/\1$ram/g" kel1monitoring.sh
sed -i "s/\(storage_limit=\)[0-9]\+/\1$storage/g" kel1monitoring.sh
sed -i "s/\(email_address=\).*/\1'$email'/" kel1monitoring.sh

# Mengecek apakah skrip kel1monitoring.sh sudah ada di crontab
existing_cronjob=$(crontab -l 2>/dev/null | grep -F "kel1monitoring.sh")
if [ -n "$existing_cronjob" ]; then
    # Menghapus skrip lama dari crontab
    (crontab -l | grep -v "kel1monitoring.sh") | crontab -
fi

# Menjadwalkan skrip dengan crontab
(crontab -l 2>/dev/null; echo "$cron_schedule /media/sf_ppj/UAS/kel1monitoring.sh") | crontab -

echo "Konfigurasi monitoring telah berhasil diatur."