#!/bin/sh
# file managed by puppet

PATH="/bin:/sbin:/usr/bin:/usr/sbin"
MYDIR="/var/lib/mysql"
BKPDIR="/var/backups/mysql"
BKPFILE="all-databases"
DUMPARGS="--all-databases --add-drop-database --single-transaction --flush-logs --master-data=2"

case "$1" in
  day)
    ;;
  week)
    BKPFILE="$BKPFILE-$(date +%A |tr 'A-Z' 'a-z')"
    ;;
  month)
    BKPFILE="$BKPFILE-$(date +%d)"
    ;;
  year)
    BKPFILE="$BKPFILE-$(date +%j)"
    ;;
  *)
    echo "Usage: $0 (day|week|month|year)"
    exit 1
    ;;
esac

# Installed ?
if [ -e /usr/bin/mysqladmin ] && [ -e /usr/bin/mysqldump ]; then
  # used ?
  if [ -d $MYDIR ] && [ -n "$(find $MYDIR -maxdepth 1 -type d ! -iname mysql ! -iname test )" ]; then
    # Running ?
    if /usr/bin/mysqladmin -s ping > /dev/null; then
      /usr/bin/mysqldump $DUMPARGS > $BKPDIR/tmp.sql && nice -n 19 gzip -9 $BKPDIR/tmp.sql && mv -f $BKPDIR/tmp.sql.gz $BKPDIR/$BKPFILE.sql.gz
      exit $?
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
