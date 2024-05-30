#!/usr/bin/env bash

# RMAN_DIR="/opt/oracle/dcs/log/dbjde63prd/rman/bkup/jde63prd_iad1kh"
RMAN_DIR="${1}"

. g.sh
. local.env

remove_duplicates() {
    awk '!seen[$0]++'
}

(
date

# Ignore DBAAS rman_configure* files.
find "${RMAN_DIR}" -type f -mtime -7 -size +0c | egrep -v "rman_configure" | while read f; do
   # if (( $(grep "RMAN> " "$f" | wc -l) > 0 )); then
   # if (( $(egrep -i "starting incremental|starting backup" "${f}" | wc -l) > 0 )); then
   # If datafiles are being backed up this is some sort of a regular backup.
   if (( $(grep "input datafile" "$f" | wc -l) > 0 )); then
      ls -alrt ${f}
      egrep -i "Finish.* backup at|Start.* backup at|RMAN-|ORA-|error|fail|not found|success|backup as|recovery window|retention policy|complete|backup device" ${f} | egrep -iv "checking for|are successfully stored|backup set complete" | remove_duplicates
      echo "----------------------------------------------------------------------"
   fi
done

# Ignore DBAAS rman_configure* files.
find "${RMAN_DIR}" -type f -mtime -1 -size +0c | egrep -v "rman_configure" | while read f; do
   # if (( $(grep "RMAN> " "$f" | wc -l) > 0 )); then
   # If no datafiles are being backed up this is some other type of backup or rman job.
   if (( $(grep -i "input datafile" "${f}" | wc -l) == 0 )) && (( $(grep -i "RMAN> " "${f}" | wc -l) > 0 )); then
      ls -alrt ${f}
      egrep -i "Finish.* backup at|Start.* backup at|RMAN-|ORA-|error|fail|not found|success|backup as|recovery window|retention policy|complete|backup device" ${f} | egrep -iv "checking for|are successfully stored|backup set complete" | remove_duplicates
      echo "----------------------------------------------------------------------"
   fi
done
) | send_message "Backup Report"
