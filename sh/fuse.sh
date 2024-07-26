export PATH=".:${PATH}"

function get_tmp_file {
   GET_TMP_FILE="${HOME}/.tmp/$$_${RANDOM}.tmp"
   mkdir -p "${HOME}/.tmp/"
   echo "${GET_TMP_FILE}"
}

function to_key_str {
   # Generates a string, often used for keys. Replaces most special characters with an underscore.
   echo "${1}" | tr -s '\/' ' ' | tr -s '!@#$%^&*()[]{}\^?<>,.' ' ' | tr -s ' ' '_'
}

# Example usage:
# is_full_file_path "/path/to/file.txt"

function is_full_path {
    if [[ -f "${1}" ]]; then
        if [[ "${1}" == /* ]]; then
            echo 1
        else
            echo 0
        fi
    else
        echo 0
    fi
}

function get_file_size {
   typeset file bytes
   file="${1:-}"
   bytes=$(ls -l "${file}" | awk '{print $5 }' | tail -1)
   echo ${bytes}
}

function send_message {
   # Send an email. Make sure fuse.sh is sourced in REPLY_EMAIL is defined and possibly DBA_EMAIL.
   # echo "foo" | send_message "{SUBJECT}" "TO"
   SND_MSG_TMP="$(get_tmp_file)1"
   EMAIL_PREFIX=${EMAIL_PREFIX:-"$(hostname -s)"}
   SUBJECT="${EMAIL_PREFIX} - ${1}"
   TO="${2:-${DBA_EMAIL}}"
   (
   while IFS= read -r x; do
     echo "${x}"
   done
   ) > "${SND_MSG_TMP}"
   (
   cat <<EOF

----
$(date) $(hostname -s)
EMAIL: ${SUBJECT}
${TO}
$(cat ${SND_MSG_TMP})
----

EOF
   ) > "${SND_MSG_TMP}1"

   if [[ -s "${SND_MSG_TMP}" ]]; then
      if [[ -n ${MAIL_FORWARD:-} ]]; then
         cat "${SND_MSG_TMP}" >> "${SND_MSG_TMP}1"
         ssh ${MAIL_FORWARD} 'cat >> mail_forward.log' < "${SND_MSG_TMP}1"
      elif [[ -n "${SENDGRID_API_KEY}" ]]; then 
         cat "${SND_MSG_TMP}1"
         cat "${SND_MSG_TMP}" | sendgrid_api "${TO}" "${REPLY_EMAIL}" "${SUBJECT}"
      else
         cat "${SND_MSG_TMP}1"
         mailx -r "${REPLY_EMAIL}" ${SMTP_SERVER_OPTION} -s "${SUBJECT}" "${TO}" < "${SND_MSG_TMP}"
      fi
   fi
   rm "${SND_MSG_TMP}" "${SND_MSG_TMP}1"
}

function send_text {
   # Send an text. Make sure g.sh is sourced in REPLY_EMAIL is defined and possibly DBA_TEXT.
   # echo "foo" | send_text "{SUBJECT}" "TO"
   SND_MSG_TMP="$(get_tmp_file)2"
   EMAIL_PREFIX=${EMAIL_PREFIX:-"$(hostname -s)"}
   SUBJECT="${EMAIL_PREFIX} - ${1}"
   TO="${2:-${DBA_TEXT}}"
   touch "${SND_MSG_TMP}"
   (
   while IFS= read -r x; do
     echo "${x}"
   done
   ) > "${SND_MSG_TMP}"
   (
   cat <<EOF

----
$(date) $(hostname -s)
TEXT: ${SUBJECT}
${TO}
$(cat ${SND_MSG_TMP})
----

EOF
   ) > "${SND_MSG_TMP}1"

   if [[ -s "${SND_MSG_TMP}" ]]; then
      if [[ -n ${MAIL_FORWARD:-} ]]; then
         # Do nothing, send_text does not support mail forwarding.
         foo=0
      else
         cat "${SND_MSG_TMP}1"
         mailx -r "${REPLY_EMAIL}" ${SMTP_SERVER_OPTION} -s "${SUBJECT}" "${TO}" < "${SND_MSG_TMP}"
      fi
   fi
   rm "${SND_MSG_TMP}" "${SND_MSG_TMP}1" 2> /dev/null
}

function watchfile {
   typeset -i last_size
   typeset -i file_size
   if (( $(is_full_path "${1}") == 0 )); then
      echo "watchfile.sh: ${1} must be the full path to the file." >&2
      return
   fi
   TMP="${HOME}/.tmp" && mkdir -p "${TMP}"
   mkdir -p "${TMP}/watchfile"
   WATCHFILE="${TMP}/watchfile/$(to_key_str ${1})" && touch "${WATCHFILE}"
   last_size=$(cat "${WATCHFILE}")
   file_size=$(get_file_size "${1}")
   echo "${file_size}" > "${WATCHFILE}"
   [[ -z "${last_size}" ]] && return
   (( ${last_size} > ${file_size} )) && return
   ((delta=${file_size}-${last_size}))
   if (( delta > 0 )); then
      dd if=${1} bs=${last_size} skip=1 2> /dev/null
   fi
}

function sqlrun {
   CDB=
   PDB=
   IFS="/" read -r CDB PDB <<EOF
${1}
EOF
   shift
   SCRIPT="$@"

   if [[ -n "${SCRIPT}" ]]; then
      SCRIPT="@${SCRIPT}"
   else
      SCRIPT="select inst_id, instance_name, version_full, to_char(startup_time, 'YYYY-MM-DD HH24:MI') startup_time, status from gv\$instance;"
   fi

   . load_oraenv.sh "${CDB}"

   if [[ -n "${PDB}" ]]; then
      sqlplus -S /nolog <<EOF
connect / as sysdba
set feedback off
alter session set container=${PDB};
set feedback on
${SCRIPT}
EOF
   else
      sqlplus -S /nolog <<EOF
connect / as sysdba
${SCRIPT}
EOF
   fi
}

function sensor {
   sensor_key="${1}"
   [[ -z "${sensor_key}" ]] && return
   TMP="${HOME}/.tmp" && mkdir -p "${TMP}"
   sensor_file="${TMP}/sensor_${sensor_key}"
   (
   while IFS= read -r line; do
     echo "${line}"
   done
   ) >> "${sensor_file}.$$"
   if [[ ! -f "${sensor_file}" ]]; then
      mv "${sensor_file}.$$" "${sensor_file}"
      return
   fi
   diff "${sensor_file}" "${sensor_file}.$$" > "${sensor_file}.out"
   if [[ -s "${sensor_file}".out ]]; then
      cat "${sensor_file}".out
   fi
   mv "${sensor_file}.$$" "${sensor_file}"
}

function remove_blank_lines_filter {
   cat | egrep -v "^ *$|^$"
}

function file_line_count {
   wc -l "${1}" | awk '{print $1}'
}

function monitor_process_count {
   PROCESS="${1}"
   EXPECTED_PROCESS_COUNT="${2:-1}"
   MON_PRC_TMP="$(get_tmp_file)3"
   typeset -i MON_PRC_CNT
   ps -eo args | grep "${1}" | egrep -v "grep" | sort > ${MON_PRC_TMP}
   # cat ${MON_PRC_TMP}
   MON_PRC_CNT=$(cat ${MON_PRC_TMP} | wc -l)
   if (( ${MON_PRC_CNT} >= ${EXPECTED_PROCESS_COUNT} )); then
      MON_PRC_CNT=${EXPECTED_PROCESS_COUNT}
   fi
   echo "PROCESS_COUNT=${MON_PRC_CNT}" | sensor "monitor_process_${1}" | send_message "** Process Counts - ${1} **" | send_text "** Process Counts - ${1} **"
   rm ${MON_PRC_TMP}
}

# function get_disk_sql {
#    while IFS=";" read disk pct_free kb_used kb_free; do
#       echo "exec update_disk_info(p_disk_name=>'${disk}', p_pct_free=>${pct_free}, p_kb_used=>${kb_used}, p_kb_free=>${kb_free});"
#    done < <(df -k | egrep -v "Mounted|Available" | awk '{print $6";"$5";"$3";"$4}' | sed 's/%//')
# }

function find_empty_dirs {
   DIR_NAME="${1:-.}"
   find "${DIR_NAME}" -type d | egrep -v "^\.$" | while read d; do
      OBJ_COUNT=$(find "${d}" -type f | wc -l)
      if (( ${OBJ_COUNT} == 0 )); then
         echo ${d}
      fi
   done
}

function dtdate {
   date +"%Y%m%d"
}

function dttime {
   date +"%H%M%S"
}

# function utl_remove_blank_lines {
#    # Remove blank lines from a file or input stream.
#    # >>> utl_remove_blank_lines [-stdin | "file"]
#    # file: Optional file name, otherwise expects input stream from standard input.
#    #
#    # **Example**
#    # ```
#    # cat /tmp/example.txt | utl_remove_blank_lines
#    # ```
#    ${arcRequireBoundVariables}
#    if [[ "${1:-}" == "-stdin" ]]; then
#       egrep -v "^ *$|^$"
#    else
#       echo "${1}" | egrep -v "^ *$|^$"
#    fi
# }

function get_os_load {
   case $(uname) in
      "LINUX"|"SUNOS"|"AIX")
         uptime | awk '{ print substr($(NF-2),1,4)" "substr($(NF-1),1,4)" "substr($(NF-0),1,4) }' | while read LOADAVG_5_MIN LOADAVG_10_MIN LOADAVG_15_MIN; do
   cat <<EOF
$(dtdate),$(dttime),load_avg,$(printf "%.1f" ${LOADAVG_10_MIN})
EOF
         done
         ;;
   esac
}

function get_vmstat {
   if [[ $(uname) == "Linux" ]]; then
      columns="$(vmstat -a 1 1 |  egrep -v "System config|---|^ *$" | head -1)"
      values="$(vmstat -a 30 2 | tail -1)"
   else 
      columns="$(vmstat 1 1 |  egrep -v "System config|---|^ *$" | head -2 | tail -1)"
      values="$(vmstat 30 2 | tail -1)"
   fi
   d=$(dtdate)
   t=$(dttime)
   i=0
   for col in ${columns}; do
      ((i=i+1))
      v=$(echo ${values} | cut -d" " -f${i})
      # echo "$"
      echo ${d},${t},vmstat,$(printf "%s,%s" "${col}_${i}" "${v}")
   done
}

function str_split_line {
   # Split ```stdin``` into separate lines using a token.
   # >>> str_split_line [-stdin] "token"
   # token: Character to split on. Default is comma. A space is acceptable.
   ${arcRequireBoundVariables}
   typeset token
   # This function only supports stdin, so we just shift and ignore if the option is present.
   [[ "${1:-}" == "-stdin" ]] && shift
   token="${1:-","}"
   tr "${token}" '\n' 
}

function num_sum {
   # Sum a series of integer or decimal numbers.
   # >>> num_sum [-stdin] [-decimals,-d X] [X...]
   # decimals: Specify the # of decimals. Defaults to zero.
   # -stdin: Read from standard input.
   # X: One or more numbers separated by spaces.
   ${arcRequireBoundVariables}
   typeset d stdin 
   stdin=0
   d=0
   while (( $# > 0)); do
      case "${1}" in
         "-stdin") stdin=1 ;;
         "-decimals"|"-d") shift; d="${1}" ;;
         *) break ;;
      esac
      shift
   done
   (
   if (( ${stdin} )); then
      cat 
   else
      echo "$*" | str_split_line " "
   fi
   ) | awk '{sum+=$1}; END {printf "%.'${d}'f\n" ,sum}'
}

function sendgrid_api {
  local TO=$1
  local FROM=$2
  local SUBJECT=$3
  local MESSAGE_BODY=""

  # Read multiple lines from STDIN and append to MESSAGE_BODY
  while IFS= read -r line; do
    MESSAGE_BODY+="$line\n"
  done

  # Remove the trailing newline character
  MESSAGE_BODY=$(echo -e "$MESSAGE_BODY" | sed '$ s/\\n$//')

  # Create JSON payload
  local JSON_PAYLOAD=$(jq -n \
    --arg to "$TO" \
    --arg from "$FROM" \
    --arg subject "$SUBJECT" \
    --arg body "$MESSAGE_BODY" \
    '{
      personalizations: [{to: [{email: $to}]}],
      from: {email: $from},
      subject: $subject,
      content: [{type: "text/plain", value: $body}]
    }')

  curl --request POST \
    --url https://api.sendgrid.com/v3/mail/send \
    --header "Authorization: Bearer $SENDGRID_API_KEY" \
    --header 'Content-Type: application/json' \
    --data "$JSON_PAYLOAD"
}

function start_oracle {
   if [[ -n "${1}" ]]; then 
      . load_oraenv.sh "${1}"
   fi
   if [[ -z ${ORACLE_HOME} ]]; then
      echo "ORACLE_HOME is not set. Exiting start_oracle function."
      return 
   fi
   lsnrctl start
   sqlplus / as sysdba <<EOF
startup;
exit;
EOF
}

function stop_oracle {
   if [[ -n "${1}" ]]; then 
      . load_oraenv.sh "${1}"
   fi
   if [[ -z ${ORACLE_HOME} ]]; then
      echo "ORACLE_HOME is not set. Exiting start_oracle function."
      return 
   fi
   lsnrctl stop
   sqlplus / as sysdba <<EOF
shutdown immediate;
exit;
EOF
}



