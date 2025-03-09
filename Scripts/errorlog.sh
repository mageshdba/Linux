BKPDIR="$(df -h | awk '{print $6}' | grep -i backup)"
echo ${BKPDIR}

(crontab -l 2>/dev/null; echo "## DB Scripts ##") | crontab -
(crontab -l 2>/dev/null; echo "00 00 * * * sh ${BKPDIR}/scripts/error_log_rotation.sh") | crontab -


vi ${BKPDIR}/scripts/error_log_rotation.sh

========================================================================


#!/bin/bash
DBFLAVOR="mysql" #Mention the DB Flavor 
ERRORDIR="$(df -h | awk '{print $6}' | grep -i err)/${DBFLAVOR}/${DBFLAVOR}d.log"
ARCIVEDIR="$(df -h | awk '{print $6}' | grep -i err)/${DBFLAVOR}/old_error_log"

# Check if the backup directory exists, create it if necessary
if [ ! -d "$ARCIVEDIR" ]; then
  mkdir -p "$ARCIVEDIR"
  echo "Backup directory created: $ARCIVEDIR"
fi

# Create a timestamp for the modified log file name
timestamp=$(date +"%d%b%Y_%I:%M:%S%p")

# Construct the new log file name with the timestamp
archivedfile="$ARCIVEDIR/${DBFLAVOR}_${timestamp}.log"

# Copy the log to the backup directory with the new name
cp "$ERRORDIR" "$archivedfile"

# Nullify the original mysqlDB log file
> "$ERRORDIR"

# Compress the copied log file
gzip "$archivedfile"

# Find and remove log files older than 15 days in the backup directory
find "$ARCIVEDIR" -name "*.log.gz" -mtime +7 -exec rm -rf {} \;

=============================================================
sh -x  ${BKPDIR}/scripts/error_log_rotation.sh

