###################################
#
# slfpwd.sh - 共有リンクの強制パスワード設定
#
# script file = script_001
#
###################################

# Initialize

#!/bin/bash
cd /Users/mishikawa/boxsh

declare -i i
declare -i j

i=1
j=1


#read Folder_ID < Folder_ID
#read WM_Folder_ID < WM_Folder_ID
#read User_ID < User_ID

Folder_ID=6610257969
WM_Folder_ID=6610260021
User_ID="manabu+demo@box.com"

i=1
while read line
do
	created_by_id[$i]=${line}
#	echo ${created_by_id[$i]}
	i=i+1
done < Parameter_script_001_2
#done < Parameter_script_001b_2

i=1
while read line
do
	created_by_name[$i]=${line}
#	echo ${created_by_name[$i]}
	i=i+1
done < Parameter_script_001_3
#done < Parameter_script_001b_3

while read line
do

####################
# Extract Task
####################

	File_ID_1=${line}
	shtask -i $File_ID_1|jq . > file_002 # shtask result

	cat file_002|jq -r .Assigned_to.assigned_to.login > Assignto_ID #shtask assigned_to
	cat file_002|jq .Message > Message #Message
	cat file_002|jq -r .Assigned_to.id > Task_ID #Task ID

	i=1
	while read line
	do
		Assignto_ID[$i]=${line}
#		echo ${Assignto_ID[$i]}
		i=i+1
	done < Assignto_ID

	i=1
	while read line
	do
		Message[$i]=${line}
#		echo ${Message[$i]}
		i=i+1
	done < Message
	
	i=1
	while read line
	do
		Task_ID[$i]=${line}
#		echo ${Task_ID[$i]}
		i=i+1
	done < Task_ID

	

####################
# Check assign to
####################

	i=1
	while read line1
	do

		# Assignto_ID_1
		Assignto_ID_1=${line1}

		if [ $Assignto_ID_1 = $User_ID ]; then

			Task_ID_1=${Task_ID[i]}

			shtaskasgn -a $Task_ID_1 > Task_assign #shtaskasgn result
			cat Task_assign|jq -r .'"Resolution state"' > Resolution_state #Resolution state
			read Resolution_state < Resolution_state
		
			if [ $Resolution_state = "未完了" ] ; then
# 			if [ $Resolution_state = "incomplete" ] ; then

				Msg=${Message[$i]}
				
				Msg1=${Msg#\"*}
				Password=${Msg1%%\,*}
				Msg2=${Msg1#*\,}
				Download=${Msg2%%\,*}
				Msg3=${Msg2#*\,}
				Watermark=${Msg3%%\,*}
				
				if [ -z $Password ]; then

					setcomment -i $File_ID_1 Task_cancelled_due_to_invalid_parameter
					settaskasgn -c $Task_ID_1
								
				else
				
					shmd -i $File_ID_1 > mdcheck
					read mdcheck < mdcheck 
								
					if [ -z $mdcheck ]; then
				
						if [ $Password = "remove" ]; then
					
							setcomment -i $File_ID_1 Task_cancelled_due_to_invalid_parameter
							settaskasgn -c $Task_ID_1

						fi
				
						if [ $Watermark = "false" ]; then
				
							bcp -i $File_ID_1 $Folder_ID|jq -r .ID > copied_file_ID #file_ID after copy 
							read copied_file_ID < copied_file_ID
#							echo $copied_file_ID
					
						else
							bcp -i $File_ID_1 $WM_Folder_ID|jq -r .ID > copied_file_ID #file_ID after copy 
							read copied_file_ID < copied_file_ID
#							echo $copied_file_ID
				
						fi				

						setfislpassword -i $copied_file_ID Open $Password $Download|jq -r .url >url_ID # Shared_link URL

						read url_ID < url_ID
					
						created_by_id=${created_by_id[$j]}
						created_by_name=${created_by_name[$j]}
				
#						echo $created_by_id
#						echo $created_by_name

						echo "\"is_shared\":\"true\",\"file_ID\":\"$copied_file_ID\",\"URL\":\"$url_ID\",\"Password\":\"$Password\",\"Download\":\"$Download\",\"Watermark\":\"$Watermark\"" > tmp_cmd
						setcmd -nif $File_ID_1 tmp_cmd

#						setcomment-m -i $File_ID_1 "@[$created_by_id:$created_by_name]　$url_ID"
						setcomment -i $File_ID_1 Completed

						settaskasgn -c $Task_ID_1
				
					else

						shmd -i $File_ID_1|jq . > tmp_cmd
						cat tmp_cmd|jq -r .Watermark > tmp_cmd_wm
						cat tmp_cmd|jq -r .file_ID > tmp_cmd_file
					
						read tmp_cmd_wm < tmp_cmd_wm
						read tmp_cmd_file < tmp_cmd_file
											
						if [ $Password = "remove" ]; then
					
							setcomment -i $File_ID_1 Sharedlink_is_removed
							brm -fi $tmp_cmd_file
							setcmd -di $File_ID_1 
							settaskasgn -c $Task_ID_1
							
						else
						
							if [ $Watermark = "false" ]; then

								if [ $tmp_cmd_wm = "true" ]; then
									bmv -i $tmp_cmd_file $Folder_ID
						
								else
						
									echo 
							
								fi
					
							elif [ $Watermark = "true" ]; then

								if [ $tmp_cmd_wm = "false" ]; then
									bmv -i $tmp_cmd_file $WM_Folder_ID
						
								else
						
									echo 
							
								fi
							fi
									
							echo "{\"op\":\"replace\",\"path\":\"/Password\",\"value\":\"$Password\"},{\"op\":\"replace\",\"path\":\"/Download\",\"value\":\"$Download\"},{\"op\":\"replace\",\"path\":\"/Watermark\",\"value\":\"$Watermark\"}" >tmp_cmd
							setcmd -aif $File_ID_1 tmp_cmd
							
#							echo $tmp_cmd_file
#							echo $Password
#							echo $Download
														
							setfislpassword -i $tmp_cmd_file Open $Password $Download

#							setcomment-m -i $File_ID_1 "@[$created_by_id:$created_by_name]　$url_ID"
							setcomment -i $File_ID_1 Completed

							settaskasgn -c $Task_ID_1
						fi 				
					fi
				fi
			fi
			
		fi
		i=i+1
	done < Assignto_ID
j=j+1
done < Parameter_script_001_1
#done < Parameter_script_001b_1
