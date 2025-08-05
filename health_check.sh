#!/bin/bash

# Thresholds
DISK_THRESHOLD=80
MEM_THRESHOLD=80
CPU_THRESHOLD=1.5

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Disk Check
check_disk() {
    USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    echo "Disk Usage: $USAGE%"
    if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo -e "${RED}Warning: Disk usage above $DISK_THRESHOLD%!${NC}"
    else
        echo -e "${GREEN}Disk usage is normal.${NC}"
    fi
}

# Memory Check
check_memory() {
    MEM_USED=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    echo "Memory Usage: $(printf "%.2f" $MEM_USED)%"
    if (( $(echo "$MEM_USED > $MEM_THRESHOLD" | bc -l) )); then
        echo -e "${RED}Warning: High memory usage!${NC}"
    else
        echo -e "${GREEN}Memory usage is normal.${NC}"
    fi
}

# CPU Check
check_cpu() {
    LOAD=$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)
    echo "CPU Load (1 min): $LOAD"
    if (( $(echo "$LOAD > $CPU_THRESHOLD" | bc -l) )); then
        echo -e "${RED}Warning: High CPU load!${NC}"
    else
        echo -e "${GREEN}CPU load is normal.${NC}"
    fi
}

# Service Check
check_services() {
    SERVICES=("ssh" "cron")
    for SERVICE in "${SERVICES[@]}"; do
        systemctl is-active --quiet $SERVICE
        if [ $? -ne 0 ]; then
            echo -e "${RED}Service $SERVICE is not running!${NC}"
        else
            echo -e "${GREEN}Service $SERVICE is running.${NC}"
        fi
    done
}

# Run all checks
echo "----- System Health Check -----"
check_disk
check_memory
check_cpu
check_services
echo "-------------------------------"

