#!/usr/bin/env bash

cd $(dirname $0)

. ./g.sh
. ./local.env

function run_sql_file {
   # Can be foo or foo/bar format.
   CDBPDB="${1}"
   # Path to script.
   SCRIPT="${2}"
   # Email will be sent if subject is provided and the script produces output.
   SUBJECT="${3}"
   # Can't use <<< method due to bash pointing to ksh for one customer!
   if [[ -z "${SUBJECT}" ]]; then
      sqlrun ${CDBPDB} "${SCRIPT}"
   else
      sqlrun ${CDBPDB} "${SCRIPT}" | send_message "${SUBJECT}"
   fi
}

function run_sql_file_remove_blank_lines {
   # Can be foo or foo/bar format.
   CDBPDB="${1}"
   # Path to script.
   SCRIPT="${2}"
   # Email will be sent if subject is provided and the script produces output.
   SUBJECT="${3}"
   # Can't use <<< method due to bash pointing to ksh for one customer!
   if [[ -z "${SUBJECT}" ]]; then
      sqlrun ${CDBPDB} "${SCRIPT}" | remove_blank_lines_filter
   else
      sqlrun ${CDBPDB} "${SCRIPT}" | remove_blank_lines_filter | send_message "${SUBJECT}"
   fi
}

touch ${HOME}/clean_disk.sh && chmod 700 ${HOME}/clean_disk.sh

if [[ "${1}" == "WEEKLY" ]]; then 
   get_audit_review_db_list | while read d; do
      run_sql_file_remove_blank_lines "${d}" "./audit_review_report.sql" "Weekly Audit Review Report"
   done
   exit 0
fi

if [[ "${1}" == "HOURLY" ]]; then
   get_datapump_dirs | while read d; do 
      echo "$(du -sk ${d} | awk '{print $1}') / 1024 / 1024"  | bc | sensor "datapump_$(to_key_str ${d})" | send_message "Datapump ${d} Dir Size GB"
   done
   exit 0
fi

if [[ "${1}" == "DAILY_AM" ]]; then
   ${HOME}/clean_disk.sh
   (
   cat <<EOF
$(date)
$(hostname)
$(uptime)

Disk (Month To Date)
---------------------
$(./df.sh -m)

free -h (If Available)
----------------------
$(free -h 2> /dev/null)

vmstat (5 @ 5s)
----------------
$(vmstat 5 5)

iostat (1s @ 2)
----------------
$(iostat 1 2)

df -i (inodes)
----------------
$(df -i)

EOF

get_check_lag_db_list | while read d; do 
   run_sql_file "${d}" "./check_lag.sql 0"
done

get_daily_checkout_db_list | while read d; do
   run_sql_file "${d}" "./daily_checkout.sql"
done

# Run daily_am function
daily_am

# Review oratab for commented entries. Look for Oracle homes and see if they are active.
if [[ -f /etc/oratab ]]; then
   echo ""
   cat /etc/oratab
   echo ""

   cat /etc/oratab | egrep -v "^#" | grep -i "^[A-Z]" | awk -F: '{print $2}' | cut -d'/' -f1-2 | sort -u | while read root_disk; do
      find ${root_disk} -type f -name "root.sh" | egrep -v "\/inventory\/" | while read f; do
         d=$(dirname ${f})
         c=$(find ${d} -type f -mtime -1 | wc -l)
         echo "${c} files modified in past 1 days found in ${d}"
      done
   done
fi

echo ""
echo ""
echo "local.env"
echo "-----------"
cat ./local.env

   ) | send_message "Daily AM"

   if [[ $(uname) == "AIX" ]]; then
      df -i | awk '{print $1" "$6}' | egrep "7.%|8.%|9.%|100%" | send_message "inodes Alarm/FYI"
   else
      df -i | egrep "7.%|8.%|9.%|100%" | send_message "inodes Alarm/FYI"
   fi

(
cat <<EOF
uptime
----------------
$(uptime)


uname -a
----------------
$(uname -a)


df -k
----------------
$(df -k)


df -i
----------------
$(df -i)

crontab -l
----------------
$(crontab -l | remove_blank_lines_filter)
   
EOF
) >> $(hostname -s).log 

   exit 0
fi

df.sh -l ${DISK_PCT_USED_LIMIT:-95} | egrep -v "Total|full" | sensor "disk_space_alert" | send_message "Disk Space" | send_text "Disk Space"

get_alert_db_list | while read d; do
   run_sql_file "${d}" "./get_alerts.sql" "${d} Database Alerts"
done

get_force_log_switch_db_list | while read d; do 
   run_sql_file "${d}" "./force_log_switch.sql ${FORCE_LOG_SWITCH_MIN}"
done

get_check_lag_db_list | while read d; do 
   run_sql_file_remove_blank_lines "${d}" "./check_lag.sql ${CHECK_LAG_MIN}" "${d} Lag"
   run_sql_file "${d}" "./log_lag.sql"
done

get_listener_log_list | while read f; do
   watchfile "${f}" | listener_filter | send_message "Listener Log: ${f}"
done

get_alert_log_list | while read f; do 
   watchfile "${f}" | alert_log_filter | send_message "Alert Log: $(basename ${f})"
done

monitor_processes

# Monitor for changes in crontab file.
crontab -l | sensor "crontab" | send_message "FYI Crontab Change"

# Monitor /etc files
cat /etc/passwd | sensor "passwd" | send_message "FYI /etc/passwd Change"

if [[ -r /etc/fstab ]]; then
   cat /etc/fstab | sensor "fstab" | send_message "FYI /etc/fstab Change"
fi

if [[ -d /dev/disk/by-uuid ]]; then
   ls /dev/disk/by-uuid | sort | sensor "dev_disk_by_uuid" | send_message "FYI /dev/disk/by-uuid Change"
fi

if [[ -r /etc/oratab ]]; then
   cat /etc/oratab | sensor "oratab" | send_message "FYI /etc/oratab Change"
fi

# Monitor ${HOME}/clean_disk.sh
cat ${HOME}/clean_disk.sh | sensor "clean_disk" | send_message "FYI clean_disk.sh Change"

# Monitor for host reboot.
who -b | sort -u | awk '{$1=$1; print}' | remove_blank_lines_filter | sensor "reboot" | send_message "** Reboot **" | send_text "** Reboot **"

if [[ -s "${HOME}/mail_forward.log" ]]; then 
   cat "${HOME}/mail_forward.log" | send_message "mail_forward.log"
   cp /dev/null "${HOME}/mail_forward.log"
fi

(
echo "$(dtdate),$(dttime),oracle_processes,$(ps -ef | grep oracle | wc -l | sed 's/ //g')"
echo "$(dtdate),$(dttime),other_processes,$(ps -ef | grep -v oracle | wc -l | sed 's/ //g')"
get_os_load
get_vmstat
) >> stats.log

(
get_ping_list | while read h; do
   ping -c 5 ${h} | tail -2 | while read l; do
      echo "$(dtdate),$(dttime),${l}"
   done
done
) >> ping.log

runs_frequent

echo "$(date) $0"
