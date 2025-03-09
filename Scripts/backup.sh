
#DCMS
#!/bin/bash
AWS="/bin/aws"
HOST=`hostname`
TIMESTAMP=$(date +"%F")
TODAY=`date +"%d%b%Y_%I:%M:%S%p"`
S3_NAME="s3://972776022853-db-backup"
S3_DIR="${S3_NAME}/DB-BACKUP/PROD/MONGO/`hostname`/"
ALL_BACKUPS="/dbbackup/dailybkp/"
BACKUP_DIR="/dbbackup/dailybkp/$TIMESTAMP"
OUTPUT_DIR="/dbbackup/Reports/"
MONGODUMP=/bin/mongodump
MONGO_USER="bkpadmin"
MONGO_PASSWORD=`cat /dbbackup/scripts/secret1.txt | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:Secret@123#`

IP1="172.184.129.43"
IP2="173.11.85.81"
IP3="172.184.129.102"
PORT="22000"
REPLSET="mongo-cluster"
URI="mongodb://${IP1}:${PORT},${IP2}:${PORT},${IP3}:${PORT}/?authSource=admin&replicaSet=${REPLSET}&ssl=false&readPreference=secondary"


>/tmp/bkp_sync-succ.txt
>/tmp/bkp_sync-err.txt

if [ -d "${OUTPUT_DIR}" ]; then
  echo "Output directory already exists."
else
  # Create the directory
  mkdir -p "${OUTPUT_DIR}"
  echo "Output directory created."
fi


if [ -d $BACKUP_DIR ]
  then
    mv $BACKUP_DIR ${BACKUP_DIR}_$TODAY
    mkdir -p $BACKUP_DIR
    cd $BACKUP_DIR
  else
    mkdir -p $BACKUP_DIR
    cd $BACKUP_DIR
fi

touch ${BACKUP_DIR}/Backup-Report.txt


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
echo "Backed-up started at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt

mongodump -u $MONGO_USER --password=$MONGO_PASSWORD --host=127.0.0.1 --port=22000 --out $BACKUP_DIR  2>&1 | tee ${BACKUP_DIR}/temp_rep.txt

#mongodump -u $MONGO_USER --password=$MONGO_PASSWORD --uri=$URI --out $BACKUP_DIR 2>&1 | tee ${BACKUP_DIR}/temp_rep.txt
cat ${BACKUP_DIR}/temp_rep.txt >> ${BACKUP_DIR}/Backup-Report.txt
rm -rf ${BACKUP_DIR}/temp_rep.txt


    if [ $? -ne 0 ]; then
       /bin/aws ses send-email --from dbbackup@m2pfintech.com --to database.engineering@m2pfintech.com --text "Backup Failure `hostname`"  --subject "Backup Failure `hostname`" --profile ses --region ap-south-1
           exit 1
        else
            echo "Backup successful.."
        fi
echo "Backed-up ended at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
echo "Backup file synch started at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt
${AWS} s3 sync $ALL_BACKUPS  ${S3_DIR} --profile backup >>/tmp/bkp_sync-succ.txt 2>/tmp/bkp_sync-err.txt
     if [ $? -eq 0 ]; then
        cat /tmp/bkp_sync-succ.txt >> ${BACKUP_DIR}/Backup-Report.txt
        echo "Backup file synch ended   at : `date`" >> ${BACKUP_DIR}/Backup-Report.txt
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
        find $ALL_BACKUPS -mtime +0 -exec rm -rvf {} \; >> ${BACKUP_DIR}/Backup-Report.txt
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${BACKUP_DIR}/Backup-Report.txt
     else
          cat /tmp/bkp_sync-err.txt >> ${BACKUP_DIR}/Backup-Report.txt
          /bin/aws ses send-email --from dbbackup@m2pfintech.com --to database.engineering@m2pfintech.com --text "Backup image S3 sync error"  --subject "S3 Sync Backup Failure `hostname`" --profile ses --region ap-south-1
      fi


cat ${BACKUP_DIR}/Backup-Report.txt > /dbbackup/Reports/Backup-Report_$TIMESTAMP.txt
