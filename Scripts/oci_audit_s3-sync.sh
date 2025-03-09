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
vi /backup/scripts/s3_sync_audit.sh

 echo "test"  |mailx -s "`hostname` Audit S3 Sync error" -r "sys-alert@m2pfintech.com" database.engineering@m2pfintech.com
 /bin/aws ses send-email --from dbbackup@m2pfintech.com --to database.engineering@m2pfintech.com --text "Audit log to s3 failed on `hostname`"  --subject "Audit log to s3 failed on `hostname`" --profile ses --region ap-south-1
 cat /tmp/s3sync-err.txt  |mailx -s "`hostname` Audit S3 Sync error" -r "backup@m2pfintech.com" database.engineering@m2pfintech.com
 
oci-ksa-prd-db-backup
axtybvoerdqj

#Audit_S3_Sync.sh
#!/bin/bash
#SERVER=$(hostname)
TIMESTAMP=$(date +"%F")
HOST=`hostname`
archive_dir="/dberrlog/mysql/audit/old_logs_audit"
s3_dir="oci-ksa-prd-db-backup"
NS="axtybvoerdqj"
report_dir="$(df -h | awk '{print $6}' | grep -i backup)/Reports"
>/tmp/s3sync-succ.txt
>/tmp/s3sync-err.txt
/bin/echo "S3 sync has been started at : `date`" >>/tmp/s3sync-succ.txt
oci os object bulk-upload --namespace ${NS} --bucket-name ${s3_dir} --src-dir ${archive_dir} --object-prefix  `hostname`/audit/ --overwrite >>/tmp/s3sync-succ.txt 2>/tmp/s3sync-err.txt
    if [ $? -eq 0 ]; then
       /bin/echo "S3 sync has been completed at : `date`" >>/tmp/s3sync-succ.txt
       find $archive_dir -maxdepth 1 -mtime +2 -type f -exec rm -rvf {} \; >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
       /bin/echo "Audit log cleanup completed at : `date` " >>/tmp/s3sync-succ.txt
       echo "------------------------------------------------------" >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
       echo "S3 Sync Success" >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
       cat /tmp/s3sync-succ.txt >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
       echo "S3 Sync Error " >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
       cat /tmp/s3sync-err.txt >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
       chmod 644 ${report_dir}/s3sync_status_$TIMESTAMP.txt
    else
       cat /tmp/s3sync-err.txt >> ${report_dir}/s3sync_status_$TIMESTAMP.txt
       echo "${HNAME} Backup Error" | mail -s "${HNAME} Backup Error" -r "backup@m2pfintech.com" database.engineering@m2pfintech.com
    fi
