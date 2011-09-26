#!/bin/bash
# $HOMEDIR/scripts/sql_dump
#
#Dump MySQL & PostgreSQL databases for backup
#
dumpdir="/data/backups"
timestamp=`date +"%Y-%m-%d_%H:%M"`
for db in `mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
do
	mysqldump -eq -h localhost ${db} | gzip -c - > "${dumpdir}/mysql/${db}_${timestamp}.sql.gz"
done
find ${dumpdir}/mysql/ -type f -mtime +14 -exec rm {} \;

for db in `psql -l | grep en_US | cut -d "|" -f 1`
do
        pg_dump ${db} | gzip -c - > "${dumpdir}/postgres/${db}_${timestamp}.sql.gz"
done
find ${dumpdir}/postgres/ -type f -mtime +14 -exec rm {} \;

dumpdir=
timestamp=
