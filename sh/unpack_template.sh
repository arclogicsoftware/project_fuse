
source_file="${1}"

if [[ -z "${source_file}" ]]; then 
   source_file=$$.pack
fi

while IFS= read -r file_line; do
   t=$(echo "${file_line}" | grep "^::: " | wc -l)
   if (( ${t} == 1 )); then 
      target_file=$(echo "${file_line}" | awk '{print $2}')
      echo "Unpacking ${target_file}"
      if [[ -f "${target_file}" ]]; then 
         mv "${target_file}" "${target_file}.back"
      fi
   else
      echo "${file_line}" >> "${target_file}"
   fi
done < "${source_file}"

chmod 700 *.sh

diff local.env template.env

mv unpack_template.sh unpack.sh
