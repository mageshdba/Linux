
BKPDIR="$(df -h | awk '{print $6}' | grep -i backup)"
echo ${BKPDIR}

(crontab -l 2>/dev/null; echo "0 */2 * * * sh ${BKPDIR}/scripts/audit_log_rotation.sh") | crontab -





vi ${BKPDIR}/scripts/audit_log_rotation.sh
========================================================================


#!/bin/bash
DBTYPE="mysql"
AUDITDIR="$(df -h | awk '{print $6}' | grep -i err)/mysql/audit"
ARCIVEDIR="$(df -h | awk '{print $6}' | grep -i err)/mysql/audit/old_logs_audit"
TODAY=`date +"%d%b%Y_%I:%M:%S%p"`
date >> ${ARCIVEDIR}/audit_rotation.out
cp -p ${AUDITDIR}/audit.log  ${ARCIVEDIR}/audit.log
rsync -avhz ${AUDITDIR}/audit.log  ${ARCIVEDIR}/audit.log
cat /dev/null > ${AUDITDIR}/audit.log
mv ${ARCIVEDIR}/audit.log "${ARCIVEDIR}/audit-$(date +"%Y%m%d%H%M")"
gzip  "${ARCIVEDIR}/audit-$(date +"%Y%m%d%H%M")"
echo "Audit rotation completed "$TODAY >> ${ARCIVEDIR}/audit_rotation.out


===========================================================
sh /backup/scripts/audit_log_rotation.sh
