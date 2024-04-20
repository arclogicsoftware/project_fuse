
find . -type f | egrep -v "unpack\.sh|tmp|\.pack|\.back" > .tmp
(
cat .tmp | while read source_file; do
   base_file="$(basename ${source_file})"
   echo "::: ${base_file}"
   cat "${source_file}"
   echo ""
   # For some reason we need an exta here to ensure a blank line before the ::: between files.
   # Cause issue on one particular AIX server unpacking and mangling files if we don't have this.
   echo ""
done
) > "$$.pack"
rm ./.tmp
