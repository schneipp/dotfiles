#!/bin/bash

# Your SQL string from piped input
sql_query=$(cat)

# Create a temporary file
tmp_file="/tmp/sqltemp.sql"
echo "$sql_query" > "$tmp_file" 

# Use the SQL formatter tool with the temporary file
sql-formatter "$tmp_file" >/dev/null 2>&1
cat "$tmp_file"
# Remove the temporary file
# rm "$tmp_file"
