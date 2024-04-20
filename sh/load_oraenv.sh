
export ORACLE_SID="${1:-ORACLE_SID}"

function get_oratab_path {
   oratab_path=$(find /etc -type f -name "oratab" 2> /dev/null)
   if [[ -z ${oratab_path} ]]; then
      oratab_path=$(find /var/opt -type f -name "oratab" 2> /dev/null)
   fi
   echo ${oratab_path}
}

ORATAB="$(get_oratab_path)"
export ORACLE_HOME=$(grep "^${ORACLE_SID}:" "${ORATAB}" | cut -d ":" -f 2)
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
export LD_LIBRARY_PATH="${ORACLE_HOME}/lib"
export PATH="${PATH}:${ORACLE_HOME}/bin:/usr/local/bin:/usr/sbin"


