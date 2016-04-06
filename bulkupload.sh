###################################
#
# bulkupload - file bulkupload
#
#
###################################

# Initialize

#!/bin/bash

read INPUT_Token < Token

if [ -z $1 ]; then

	echo "Source_file?:"
	read source_file

	for line in `cat $source_file |grep -v ^#`
	
	do
		folder=`echo $line |cut -d ',' -f 1`
		file=`echo $line |cut -d ',' -f 2`
		bput $file $folder
	done

else

	source_file=$1

#echo $source_file


   for line in `cat $source_file |grep -v ^#`
	do
		folder=`echo $line |cut -d ',' -f 1`
		file=`echo $line |cut -d ',' -f 2`
		bput $file $folder
	done
	
fi



	
		







