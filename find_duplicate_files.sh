#!/bin/bash

# Find Duplicate Files (based on size first, then MD5 hash)
# This dup finder saves time by comparing size first, then md5sum, it doesn't delete anything, just lists them.

find -not -empty -type f -printf "%s\n" | sort -rn | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate
