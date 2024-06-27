#!/usr/bin/env bash

# Directories to monitor and move files to
WATCH_DIR="/c/Temp/watch"
PROCESSED_DIR="/c/Temp/processed"
GROQ_API_KEY="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"

[[ ! -d "$WATCH_DIR" ]] && echo "Watch directory does not exist" && exit 1
[[ ! -d "$PROCESSED_DIR" ]] && echo "Processed directory does not exist" && exit 1

read -r -d '' content << EOM
Evaluate this tablespace info report. The rate of growth is in the GB_PER_DAY column and if the growth rate is 0 we can allow up to 95% PCT_FULL.
Return "#OK#" if there are not issues and a "#WARNING#" if there are issues.

<<<
[TABLESPACE INFO]

TABLESPACE_NAME      OBJECTS_GB  FREE_GB PCT_FULL GB_PER_DAY ESTIMATED_DAYS_REMAINING AUTOEXTEND_PCT_FULL MAX_DAYS_REMAINING
-------------------- ---------- -------- -------- ---------- ------------------------ ------------------- ------------------
DATA                          1        1       57        .00                       90                   0            3276680
DBFS_DATA                     0        0        0        .00                       10                   0            3276800
SYSAUX                        3        0       94        .00                       20                   0            3276480
SAMPLESCHEMA                162       38       81        .00                     3760                   0            3260560
>>>

EOM


# Escape the content to be JSON-safe
escaped_content=$(printf '%s' "$content" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

# Build JSON payload using printf
json_payload=$(printf '{"messages": [{"role": "system", "content": "You are an expert Oracle Ace."}, {"role": "user", "content": "%s"}], "model": "llama3-70b-8192", "temperature": 0}' "$escaped_content")

# Function to make the curl request
make_request() {
   local payload=$1
   json_response=$(curl -X POST "https://api.groq.com/openai/v1/chat/completions" \
      -H "Authorization: Bearer $GROQ_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$payload")
   echo "$json_response"
   content=$(echo "$json_response" | awk -v RS='}' -F'"content":"' '{if (NF>1) print $2}' | awk -F'","' '{print $1}')

   # To handle escaped quotes and newlines properly
   content=$(echo "$content" | sed 's/\\"/"/g' | sed 's/\\n/\n/g')

   # Display the extracted content
   echo "$content"
}



# Call the function with the JSON payload
make_request "$json_payload"

exit 0

for file in "$WATCH_DIR"/*; do
   if [ -f "$file" ]; then
     process_file "$file"
     mv "$file" "$PROCESSED_DIR"
   fi
done

