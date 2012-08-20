#!/bin/sh
# file managed by puppet

PATH="/bin:/sbin:/usr/bin:/usr/sbin"
MYDIR="/var/lib/mysql"
BKPDIR="/var/backups/mysql"
BINLOG="mysqld-bin.*"

# Installed ?
if [ -e /usr/bin/mysqladmin ]; then
  # used ?
  if [ -d $MYDIR ] && [ -n "$(find $MYDIR -maxdepth 1 -type d ! -iname mysql ! -iname test )" ]; then
    # Running ?
    if /usr/bin/mysqladmin -s ping > /dev/null; then
      # Flush logs
      /usr/bin/mysqladmin flush-logs
      # Delete old binary logs
      find "$BKPDIR" -name "$BINLOG" -mtime +1 -exec rm {} \;
      # Copy new logs
      find "$MYDIR" -name "$BINLOG" -mtime -1 -size +1 -exec cp --preserve=mode,timestamps {} "$BKPDIR/" \;
    else
      echo 'mysqld not running'
      exit 1
    fi
  else
    # no databases to backup ? no problem
    exit 0
  fi
else
  echo "mysqladmin missing. Are you sure this cron must run ?"
  exit 1
fi
