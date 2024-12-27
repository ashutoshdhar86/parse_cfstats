# parse_cfstats.sh
These scripts will parse Cassandra's cfstats output to give you a sorted single line output for each table.
 - NOTE: Place this script where the cfstats output resides.

1. The local reads and writes count and their total in a sorted descending order
2. The local read latency * count in a sorted descending order
