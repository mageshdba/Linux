BKPDIR="$(df -h | awk '{print $6}' | grep -i backup)"
echo ${BKPDIR}

(crontab -l 2>/dev/null; echo "## DB Scripts ##") | crontab -
(crontab -l 2>/dev/null; echo "00 01 * * * sh ${BKPDIR}/scripts/s3_sync_rotation.sh") | crontab -

vi ${BKPDIR}/scripts/s3_sync_rotation.sh
========================================================================

 echo "test"  |mailx -s "`hostname` Audit S3 Sync error" -r "sys-alert@m2pfintech.com" database.engineering@m2pfintech.com
 /bin/aws ses send-email --from dbbackup@m2pfintech.com --to database.engineering@m2pfintech.com --text "Audit log to s3 failed on `hostname`"  --subject "Audit log to s3 failed on `hostname`" --profile ses --region ap-south-1

 cat /tmp/s3sync-err.txt  |mailx -s "`hostname` Audit S3 Sync error" -r "backup@m2pfintech.com" database.engineering@m2pfintech.com
 
 TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s) && curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep -oP '"accountId" : "\K[0-9]+'


aws s3 ls --profile backup s3://347972539362-db-log-backup 


*** Prechecks
    - Update the correct audit log path in the script
    - Verify the S3 bucket s3_name
    - Check if the mailx is working fine.
    - Run the script once manually by providing wrong S3 name to verify the mail alert
    - Update the script name and path correctly in the cron
    - Run the script from cron by scheduling it to latest time
========================================================================

-- audit_S3_Sync.sh

#!/bin/bash
#SERVER=$(hostname)
DBFLAVOR="mysql"
TIMESTAMP=$(date +"%F")
AWS=/bin/aws
s3_name="s3://347972539362-db-log-backup"
s3_dir="${s3_name}/AUDIT_LOG_BACKUP/${DBFLAVOR}/`hostname`/${TIMESTAMP}/"
archive_dir="$(df -h | awk '{print $6}' | grep -i err)/${DBFLAVOR}/audit/old_logs_audit"
report_dir="$(df -h | awk '{print $6}' | grep -i backup)/Reports"
>/tmp/s3sync-succ.txt
>/tmp/s3sync-err.txt
sdat=`date +%F" "%T`
/bin/echo "S3 sync has been started at ${sdat}" >>/tmp/s3sync-succ.txt
/bin/aws s3 sync $archive_dir  $s3_dir --profile backup >>/tmp/s3sync-succ.txt 2>/tmp/s3sync-err.txt
     if [ $? -eq 0 ]; then
        edat=`date +%F" "%T`
        /bin/echo "S3 sync has been completed at ${edat}" >>/tmp/s3sync-succ.txt
        find $archive_dir -maxdepth 1 -mtime +7 -type f -exec rm -rf {} \;
        /bin/echo "Audit log cleanup completed at  ${edat}" >>/tmp/s3sync-succ.txt
        echo "------------------------------------------------------" >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
        echo $sdat >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
        echo "S3 Sync Success" >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
        cat /tmp/s3sync-succ.txt >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
        echo "S3 Sync Error " >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
        cat /tmp/s3sync-err.txt >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
        chmod 644 ${report_dir}/s3sync_status_$TIMESTAMP.txt
    else
          cat /tmp/s3sync-err.txt >> ${BACKUP_DIR}/Backup-Report.txt
          #cat /tmp/s3sync-err.txt  |mailx -s "`hostname` Audit S3 Sync error" -r "sys-alert@m2pfintech.com" database.engineering@m2pfintech.com
          /bin/aws ses send-email --from dbbackup@m2pfintech.com --to database.engineering@m2pfintech.com --text "Audit log to s3 failed on `hostname`"  --subject "Audit log to s3 failed on `hostname`" --profile ses --region ap-south-1
    echo "Audit log to s3 failed on" | mail -s "Audit log to s3 failed on `hostname`" -r "backup@m2pfintech.com" database.engineering@m2pfintech.com

    fi




==============================================
sh -x  ${BKPDIR}/scripts/s3_sync_rotation.sh
