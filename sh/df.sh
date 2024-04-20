#!/usr/bin/env bash

TMP=${HOME}/.tmp && mkdir -p "${TMP}"
TMP_FILE=${TMP}/$$.tmp
cp /dev/null "${TMP_FILE}"
DAY_FILE=${TMP}/df_$( date "+%Y%m%d" ).txt
WK_FILE=${TMP}/df_$( date "+%Y-%W" ).txt
MTH_FILE=${TMP}/df_$( date "+%Y%m" ).txt
YTD_FILE=${TMP}/df_$( date "+%Y" ).txt
DEF_SHOW_FILE=${TMP}/df.txt
FILES="${DAY_FILE} ${WK_FILE} ${MTH_FILE} ${YTD_FILE} ${DEF_SHOW_FILE}"
HOST="$(hostname)"
typeset -l OS
OS=$( uname -s )
LIMIT=0
SHOW_FILES=
EXCLUDE=
while (( $# > 0)); do
   case "${1}" in
      "-d") SHOW_FILES="${SHOW_FILES} ${DAY_FILE}" ;;
      "-w") SHOW_FILES="${SHOW_FILES} ${WK_FILE}"  ;;
      "-m") SHOW_FILES="${SHOW_FILES} ${MTH_FILE}" ;;
      "-y") SHOW_FILES="${SHOW_FILES} ${YTD_FILE}" ;;
      "-l") shift; LIMIT=${1} ;;
      "-e") shift; EXCLUDE="${1}" ;;
      *) break ;;
   esac
   shift
done

if [[ -z "${SHOW_FILES}" ]]; then
   SHOW_FILES=${DEF_SHOW_FILE}
fi

case ${OS} in
   aix)
       df -k | grep -v "\/proc" | awk '{ print $7" "$2" "$3" "$4'} | grep -v "^Mounted" | egrep -v "^ *$|^$"  >  ${TMP_FILE} ;;
   sunos)
       # Added 2> /dev/null to ignore errors when running on an OS with a Zone.
       df -kl 2> /dev/null | awk '{ print $6" "$2" "$4" "$5'} | grep -v "^Mounted" > ${TMP_FILE} ;;
   hp-ux)
       bdf -l| awk '{ print $6" "$2" "$4" "$5'} | grep -v "^Mounted" > ${TMP_FILE} ;;
   linux)
       df -k |egrep -v ":|Available" | sed 's/^/-/g' | awk '{print $6" "$2" "$4" "$5}' | egrep -v "^ *$|^$"  > ${TMP_FILE} ;;
   *)
       print "Not configured to run on this OS" ; exit 1 ;;
esac

for f in ${FILES}
do
   if [[ ! -f "${f}" ]]; then
      cp ${TMP_FILE} ${f}
   fi

   touch ${f}

   if (( $( echo ${SHOW_FILES} | grep "${f}" | wc -l ) )); then
      echo ${SINGLE_LINE} > ${TMP_FILE}.1

      TTL_SIZE=0
      TTL_SIZE_DIFF=0
      TTL_FREE=0
      TTL_DIFF=0
      TTL_USED=0
      CAT_FILE=N

      printf "%-30s%+14s%+6s%+14s%+6s%+14s%+6s\n" "Mounted on" "Size" "+/-" "Free" "+/-" "%Used" "+/-" >> ${TMP_FILE}.1
      while read DISK SIZE FREE PCT_FULL
      do
         SKIP=
         if [[ -n "${EXCLUDE}" ]]; then
            for i in ${EXCLUDE}; do
               if [[ "${i}" == "${DISK}" ]]; then
                  SKIP=Y
               fi
            done
         fi

         if [[ -z ${SKIP} ]]; then

         TTL_SIZE=$( expr ${TTL_SIZE} + ${SIZE} )

         RECORD=$( grep "^${DISK} " ${f} )

         # If this is a new mount append it to file.
         if [[ -z "${RECORD}" ]]; then
            RECORD=$( grep "^${DISK} " ${TMP_FILE} )
            echo ${RECORD} >> ${f}
         fi

         LAST_SIZE=$( echo ${RECORD} | awk '{ print $2 }' )
         SIZE_DIFF=$( expr ${SIZE} - ${LAST_SIZE} )
         TTL_SIZE_DIFF=$( expr ${TTL_SIZE_DIFF} + ${SIZE_DIFF} )

         LAST_FREE=$( echo ${RECORD} | awk '{ print $3 }' )
         TTL_FREE=$( expr ${TTL_FREE} + ${FREE} )

         LAST_PCT_FULL=$( echo ${RECORD} | awk '{ print $4 }' | sed 's/%//g' )
         CUR_PCT_FULL=$( echo ${PCT_FULL} | sed 's/%//g' )
         PCT_FULL_DIFF=$( expr ${CUR_PCT_FULL} - ${LAST_PCT_FULL} )

         LAST_USED=$( expr ${LAST_SIZE} - ${LAST_FREE} )
         CUR_USED=$( expr ${SIZE} - ${FREE} )
         TTL_USED=$( expr ${TTL_USED} + ${CUR_USED} )
         DIFF=$( expr ${LAST_USED} - ${CUR_USED} )
         TTL_DIFF=$( expr ${TTL_DIFF} + ${DIFF} )

            if (( ${CUR_PCT_FULL} > ${LIMIT} )); then
               CAT_FILE="Y"
               printf "%-30s%14s%6s%14s%6s%14s%6s\n" ${DISK} \
               $( expr ${SIZE} / 1024 ) $( expr ${SIZE_DIFF} / 1024 ) \
               $( expr ${FREE} / 1024 ) $( expr ${DIFF} / 1024 ) \
               ${PCT_FULL} ${PCT_FULL_DIFF} >> ${TMP_FILE}.1
            fi
         fi
      done < "${TMP_FILE}"

      if [[ "${CAT_FILE}" == "Y" ]]; then
         (
         echo $SINGLE_LINE
         printf "%-30s%14s%6s%14s%6s%14s%6s\n" "Total (${HOST})" \
         $( expr ${TTL_SIZE} / 1024 ) $( expr ${TTL_SIZE_DIFF} / 1024 ) \
         $( expr ${TTL_FREE} / 1024 ) $( expr ${TTL_DIFF} / 1024 ) "" ""
      echo ""
         ) >> ${TMP_FILE}.1
      TTL_PCT=$( echo "${TTL_USED} / ${TTL_SIZE} * 100" | bc -l | cut -d"." -f1)
         (
         echo "$( expr ${TTL_USED} / 1024 ) MB's used ${TTL_PCT}% full"
         echo ""
         echo ""
         ) >> ${TMP_FILE}.1
        cat ${TMP_FILE}.1
      fi
   fi

done

rm ${TMP_FILE} ${TMP_FILE}.1 2> /dev/null

exit 0
