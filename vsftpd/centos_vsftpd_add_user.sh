#!/bin/bash

# Prompt for username
read -p "Enter username: " username

# Create user directory
mkdir -p "/data/ftp/$username"
chown -R vsftpd:vsftpd "/data/ftp"

# Create user configuration file
echo 'dirlist_enable=YES
download_enable=YES
local_root=/data/ftp/'"$username"'
write_enable=YES' > "/etc/vsftpd/vconf/$username"

echo "$username" | tee -a /etc/vsftpd/password{,-nocrypt} > /dev/null

# Create user password
myval=$(openssl rand -base64 6)
echo $myval >> "/etc/vsftpd/password-nocrypt"
echo $(openssl passwd -crypt $myval) >> "/etc/vsftpd/password"

# Load password into password database
db_load -T -t hash -f "/etc/vsftpd/password" "/etc/vsftpd/password.db"

# Restart vsftpd service
systemctl restart vsftpd.service

printf "Username: $username \n"
printf "Password: $myval \n"
printf "Done.\n"
