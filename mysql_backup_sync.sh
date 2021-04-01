#!/bin/bash

HOST='IP'
USER='mysqlftp'
PASSWD='password'
ldir='/path/to/mysql_backup/'

cd $ldir
day=$(date +"%d")
month=$(date +"%m")
year=$(date +"%Y")
rcd=$(hostname)
echo $rcd

declare -a arrName
declare -a arrUser
for file in *.sql.gz
do
    arrName=("${arrName[@]}" "$file")
    user=$(echo $file| sed -e 's/.*.//;s/.sql.*//')
    echo $file uploaded ftp
    arrUser=("${arrUser[@]}" "$user")
    ftp -n $HOST << EOF
        quote USER $USER
        quote PASS $PASSWD
        cd $rcd
        cd daily
        put $file
        quit
EOF
done

echo $rcd
echo "All backups uploaded"
exit 0
