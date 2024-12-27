#!/bin/bash

# Copy this script in the directory where the cfstats file resides
# Requires gawk to be installed in MacOS

gawk '
BEGIN {
    FS=":[ \t]*"; # Define field separator
    keyspace="";
    table="";
    readCount="";
    readLatency="";
    multiplication=0;
    print "Starting parsing...";
    IGNORECASE=1; # Ignore case sensitivity
}

/^Keyspace/ {
    if (keyspace != "" && table != "" && readCount != "" && readLatency != "") {
        multiplication = readCount * readLatency;
        printf "%s %s %.3f %d %.2f\n", keyspace, table, readLatency, readCount, multiplication;
    }
    # Reset table, readCount, and readLatency for new keyspace
    table="";
    readCount="";
    readLatency="";
    sub(/^[ \t]*/, "", $2); # Trim leading whitespace
    keyspace=$2;
}

/^[ \t]*Table/ {
    if (table != "" && readCount != "" && readLatency != "") {
        multiplication = readCount * readLatency;
        printf "%s %s %.3f %d %.2f\n", keyspace, table, readLatency, readCount, multiplication;
    }
    # Reset readCount and readLatency for new table
    readCount="";
    readLatency="";
    sub(/^[ \t]*/, "", $2); # Trim leading whitespace
    table=$2;
}

/^[ \t]*Local read count/ {
    readCount=$2;
}

/^[ \t]*Local read latency/ {
    # Remove "ms" from latency value and convert to number
    sub(/ ms$/, "", $2);
    readLatency=$2;
}

END {
    if (keyspace != "" && table != "" && readCount != "" && readLatency != "") {
        multiplication = readCount * readLatency;
        printf "%s %s %.3f %d %.2f\n", keyspace, table, readLatency, readCount, multiplication;
    }
}
' cfstats | sort -k5,5nr | awk '{ printf "Keyspace: %s, Table: %s, Local read latency: %.3f ms, Local read count: %d, Multiplication: %.2f\n", $1, $2, $3, $4, $5 }'

