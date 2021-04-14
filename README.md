#### A small bash script for automating the daily mysql backups  

 * Create a directory for store backups. For example, ```/path/to/mysql_backup/``` 
 * Make sure that your script has the appropriate executable permission ```/path/to/mysql_backup.sh```
 * You can change the ```KEEP_BACKUPS_FOR``` as you wish .
 * Add a cron job For example, daily db backup @ 4:15 AM ```15 4 * * * /path/to/mysql_backup.sh > /dev/null 2>&1```
 * Also you can use [mysql_backup_sync.sh](https://github.com/yigitgokcu/mysql-backup/blob/main/mysql_backup_sync.sh) script with a cronjob for send backups to remote destination via FTP.
```
#!/bin/bash
#==============================================================================
#TITLE:            mysql_backup.sh
#DESCRIPTION:      script for automating the daily mysql backups
#USAGE:            ./mysql_backup.sh
#CRON:
  # example cron for daily db backup @ 4:15 am
  # min  hr mday month wday command
  # 15   4  *    *     *    /path/to/mysql_backup.sh


BACKUP_DIR=/path/to/mysql_backup/

MYSQL_UNAME=root
MYSQL_PWORD=

IGNORE_DB="(^mysql|_schema$)"


KEEP_BACKUPS_FOR=1 #day

# YYYY-MM-DD
TIMESTAMP=$(date +%F)

function delete_old_backups()
{
  echo "Deleting $BACKUP_DIR/*.sql.gz older than $KEEP_BACKUPS_FOR days"
  find $BACKUP_DIR -type f -name "*.sql.gz" -mtime 1 -exec rm {} \;
}

function mysql_login() {
  local mysql_login="-u $MYSQL_UNAME"
  if [ -n "$MYSQL_PWORD" ]; then
    local mysql_login+=" -p$MYSQL_PWORD"
  fi
  echo $mysql_login
}

function database_list() {
  local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
  echo $(mysql $(mysql_login) -e "$show_databases_sql"|awk -F " " '{if (NR!=1) print $1}')
}

function echo_status(){
  printf '\r';
  printf ' %0.s' {0..100}
  printf '\r';
  printf "$1"'\r'
}

function backup_database(){
    backup_file="$BACKUP_DIR/$database.$TIMESTAMP.sql.gz"
    output+="$database => $backup_file\n"
    echo_status "...backing up $count of $total databases: $database"
    $(mysqldump $(mysql_login) $database | gzip -9 > $backup_file)
}

function backup_databases(){
  local databases=$(database_list)
  local total=$(echo $databases | wc -w | xargs)
  local output=""
  local count=1
  for database in $databases; do
    backup_database
    local count=$((count+1))
  done
  echo -ne $output | column -t
}

function backup_databases(){
  local databases=$(database_list)
  local total=$(echo $databases | wc -w | xargs)
  local output=""
  local count=1
  for database in $databases; do
    backup_database
    local count=$((count+1))
  done
  echo -ne $output | column -t
}

function hr(){
  printf '=%.0s' {1..100}
  printf "\n"
}

#==============================================================================
# RUN SCRIPT
#==============================================================================
delete_old_backups
hr
backup_databases
hr
printf "All backed up!\n\n"
```
