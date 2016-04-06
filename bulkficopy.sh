###################################
#
# bulficopy - bulk file copy
#
#
###################################

# Initialize

#!/bin/bash

read INPUT_Token < Token

if [ -z $1 ]; then

	echo "Source_file?:"
	read Source_file

	echo "Folder ID?:"
	read folder_ID_tmp
	
	while read line
	do
	
		bcp -i $line $folder_ID_tmp
	
	done < $Script_file

else

	Source_file=$1
	read folder_ID_tmp < folder_ID.tmp 

	while read line
	do

		bcp -i $line $folder_ID_tmp
	
	done < $Script_file
	
fi



	
		







