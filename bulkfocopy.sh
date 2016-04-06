###################################
#
# bulkfocopy.sh - bulk folder copy
#
#
###################################

# Initialize

#!/bin/bash

read INPUT_Token < Token

Folderlist_tmp=$1
folderid_tmp=$2
read folder_ID_tmp < $folderid_tmp

while read line
do
	bcp -o $line $folder_ID_tmp
done < $Folderlist_tmp

