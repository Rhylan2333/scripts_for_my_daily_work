#!/usr/bin/bash

# Define the usage function
function usage() {
  echo "Usage: $0 -q QUERY_ID -s SUBJECT_GXF_FILE"
  exit 1
}

# Parse the command-line arguments
while getopts ":q:s:" opt; do
  case ${opt} in
    q)
      query_id=${OPTARG}
      ;;
    s)
      SUBJECT_GXF_FILE=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      usage
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      usage
      ;;
  esac
done

# Check if the query and subject filenames were provided
if [ -z "${query_id}" ] || [ -z "${SUBJECT_GXF_FILE}" ]; then
  echo "Missing query id or subject filename." >&2
  usage
fi

# Get the line number of the start of the sequence to be extracted
line_number_start=$(rg -n "$query_id" "$SUBJECT_GXF_FILE" | sd ':.*' '')

# Print its start line number
# echo "The start line number is $line_number_start."

# Extract the sequence from the start line to the end of the file
if [ ! -f 'temporary.*' ]; then
  tail -n +"$line_number_start" "$SUBJECT_GXF_FILE" > temporary.gxf
  rg -n 'gene' temporary.gxf | sd ':.*' '' > temporary.gxf.id
fi

# Get the line number of the stop of the sequence
line_number_stop=$(( $( head -n 2 temporary.gxf.id | tail -n 1) - 1 ))

# Extract the sequence from the start line to the stop line
if [ $line_number_stop != 0 ]; then
  head -n $line_number_stop temporary.gxf
else
  bat -p temporary.gxf
fi

# Remove the temporary file
rm temporary.*
