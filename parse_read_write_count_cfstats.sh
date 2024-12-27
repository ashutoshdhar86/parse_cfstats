#!/bin/bash

# Copy this script in the directory where the cfstats file resides
# Requires gawk to be installed in MacOS

gawk '
BEGIN {
    FS=":[ \t]*"; # Define field separator
    keyspace="";
    table="";
    readCount="";
    writeCount="";
    print "Starting parsing...";
    IGNORECASE=1; # Ignore case sensitivity
}

/^Keyspace/ {
    if (keyspace != "" && table != "" && readCount != "" && writeCount != "") {
        print keyspace, table, readCount, writeCount, (readCount + writeCount);
    }
    # Reset table, readCount, and writeCount for new keyspace
    table="";
    readCount="";
    writeCount="";
    sub(/^[ \t]*/, "", $2); # Trim leading whitespace
    keyspace=$2;
}

/^[ \t]*Table/ {
    if (table != "" && readCount != "" && writeCount != "") {
        print keyspace, table, readCount, writeCount, (readCount + writeCount);
    }
    # Reset readCount and writeCount for new table
    readCount="";
    writeCount="";
    sub(/^[ \t]*/, "", $2); # Trim leading whitespace
    table=$2;
}

/^[ \t]*Local read count/ {
    readCount=$2;
}

/^[ \t]*Local write count/ {
    writeCount=$2;
}

END {
    if (keyspace != "" && table != "" && readCount != "" && writeCount != "") {
        print keyspace, table, readCount, writeCount, (readCount + writeCount);
    }
}
' cfstats | sort -k5,5nr | awk '{ printf "Keyspace: %s, Table: %s, Local read count: %s, Local write count: %s, Total count: %s\n", $1, $2, $3, $4, $5 }'
