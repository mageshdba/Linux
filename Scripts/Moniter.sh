#!/bin/bash
set -e

TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
OUTPUT_DIR="/backup/Reports/monitoring"

# System monitoring
RAM_OUTPUT=$(free -h)
TOP_OUTPUT=$(top -bcn 1 | head -20)

# Additional metrics
CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print $2}')
MEM_USAGE=$(free -m | awk '/Mem:/ {print $3/$2 * 100}')
DISK_USAGE=$(df -h | grep -i db | awk '/\// {print $6 " is " $5}')

LOAD_AVERAGE=$(cat /proc/loadavg | awk '{print $1}')

# vmstat output
VMSTAT_OUTPUT=$(vmstat -s)

# iostat output
IOSTAT_OUTPUT=$(iostat -x)

# mpstat output
MPSTAT_OUTPUT=$(mpstat -P ALL)

# sar output (if sysstat is installed and configured)
# SAR_OUTPUT=$(sar -u -f /var/log/sysstat/sa$(date +%d))

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Write output to file directly for better formatting
echo "System Monitoring Report - $TIMESTAMP" > "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "Load Average: $LOAD_AVERAGE" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "CPU Usage: $CPU_USAGE%" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "Memory Usage: $MEM_USAGE%" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "Disk Usage:" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "$DISK_USAGE" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "RAM Status:" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "$RAM_OUTPUT" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "VMStat Output:" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "$VMSTAT_OUTPUT" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "IOStat Output:" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "$IOSTAT_OUTPUT" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "MPStat Output:" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "$MPSTAT_OUTPUT" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "Top Output:" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
echo "$TOP_OUTPUT" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

# Uncomment SAR_OUTPUT if you have sysstat configured
# echo "SAR Output:" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"
# echo "$SAR_OUTPUT" >> "${OUTPUT_DIR}/OS_Stats_$TIMESTAMP.log"

echo "Report generated successfully."
