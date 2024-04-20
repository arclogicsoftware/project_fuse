#!/usr/bin/env bash

# Used to limit how often emails are sent.

TMP="${HOME}/.tmp" && mkdir -p "${TMP}"

gate_key=
gate_seconds=

while (( $# > 0)); do
  case "${1}" in
     "-key"|"-k") shift; gate_key="${1}" ;;
     "-seconds"|"-s") shift; gate_seconds=${1} ;;
     *) break ;;
  esac
  shift
done

gate_file="${TMP}/gate_${gate_key}"

epoch=$(date +%s)
if [[ -f "${gate_file}" ]]; then 
   last_epoch=$(cat "${gate_file}")
   if (( ${epoch} - ${last_epoch} < ${gate_seconds} )); then 
      exit 1
   fi
fi

date +%s > "${gate_file}"

while IFS= read -r line; do
  echo "${line}"
done

exit 0