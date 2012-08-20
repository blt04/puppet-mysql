#!/bin/sh
# file managed by puppet

PATH="/bin:/sbin:/usr/bin:/usr/sbin"
FULL_HOUR="${1:-*}"
MYDIR="/var/lib/mysql"
FULL_FILE="all-databases"
BINLOG_FILE="mysqld-bin.*"
DUMPARGS="--all-databases --add-drop-database --single-transaction --flush-logs --master-data=2"
BKPDIR="/var/backups/mysql"

# Installed ?
if [ -e /usr/bin/mysqladmin ] && [ -e /usr/bin/mysqldump ]; then
  # used ?
  if [ -d $MYDIR ] && [ -n "$(find $MYDIR -maxdepth 1 -type d ! -iname mysql ! -iname test )" ]; then
    # Running ?
    if /usr/bin/mysqladmin -s ping > /dev/null; then

      # Remove the existing full backup if the hour is right
      if [ "$FULL_HOUR" = "*" ] || [ "$(date +%H)" -eq "$FULL_HOUR" ]; then
        if [ -e "$BKPDIR/$FULL_FILE.sql.gz" ]; then
          rm "$BKPDIR/$FULL_FILE.sql.gz"
        fi
      fi

      if [ -e "$BKPDIR/$FULL_FILE.sql.gz" ]; then
        # Flush logs
        /usr/bin/mysqladmin flush-logs
      else
        # Create full backup
        /usr/bin/mysqldump $DUMPARGS > "$BKPDIR/$FULL_FILE.sql" && nice -n 19 gzip -9 "$BKPDIR/$FULL_FILE.sql"
      fi

      # Copy incremental binary logs
      find "$BKPDIR" -name "$BINLOG_FILE" -exec rm {} \;
      find "$MYDIR" -name "$BINLOG_FILE" -newer "$BKPDIR/$FULL_FILE.sql.gz" -size +128c -exec cp --preserve=mode,timestamps {} "$BKPDIR/" \;

    else
      echo 'mysqld not running'
      exit 1
    fi
  else
    # no databases to backup ? no problem
    exit 0
  fi
else
  echo "mysqladmin/mysqldump missing. Are you sure this cron must run ?"
  exit 1
fi
