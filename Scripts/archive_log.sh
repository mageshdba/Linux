BKPDIR="$(df -h | awk '{print $6}' | grep -i backup)"
echo ${BKPDIR}

(crontab -l 2>/dev/null; echo "## DB Scripts ##") | crontab -
(crontab -l 2>/dev/null; echo "00 00 * * * sh ${BKPDIR}/scripts/error_log_rotation.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 */2 * * * sh ${BKPDIR}/scripts/audit_log_rotation.sh") | crontab -
(crontab -l 2>/dev/null; echo "00 01 * * * sh ${BKPDIR}/scripts/s3_sync_rotation.sh") | crontab -
(crontab -l 2>/dev/null; echo "15 01 * * * sh ${BKPDIR}/scripts/backup.sh") | crontab -
(crontab -l 2>/dev/null; echo "30 0 * * *  sh ${BKPDIR}/scripts/archivelog_rotation.sh") | crontab -



 
chmod 777 /backup/scripts/archivelog_rotation.sh
sh -x  /backup/scripts/archivelog_rotation.sh



#!/bin/bash
# This is audit  log cleanup script.

TODAY=`date +"%Y%m%d"`
DATE=`date +"%d%b%Y_%I:%M:%S%p"`
path="$(df -h | awk '{print $6}' | grep -i dblog)/pgsql/archive"

echo "$path"

find $path -mtime +2 -type f -exec rm -rf {} \;

