#!/bin/bash
#

userHomeDir=~
recycleBinDir="$userHomeDir/smartdel_recycle"
recycleBinDirdata="$userHomeDir/smartdel_recycle_Data"
deletionDate=$(date +"%x-%X" | tr ":" "." | tr "/" "." |tr " " "-")
workingDir=$(pwd)


if ! echo $workingDir | grep -q $userHomeDir 
then
	printf "\nYou can't use `basename $0` Outside your home directory $userHomeDir !\n\n"
	exit
fi

# Check if the Recycle file exist if doesn't exist create it.

if [ ! -d $recycleBinDir ]
then 
	mkdir $recycleBinDir
fi


case "$1" in
	"")
		printf "\nNo file specified!\n\n"
		printf "Usage :  `basename $0` <file name>  #To delete a file.\n"
		printf "Usage :  `basename $0` -d <file name>  #To delete a file.\n"	
		printf "Usage :  `basename $0` -r  <file name>  #To restore a file.\n"
	;;
		
	-r )
		
		if [ "$(cat $recycleBinDirdata | grep  "//$2//" | wc -l )"  -eq "1" ]
		then
			recyleFileName=$(cat $recycleBinDirdata | grep "//$2//" | awk -F"//" '{print $1}' )
			originalName=$(cat $recycleBinDirdata | grep "//$2//" | awk -F"//" '{print $3}' )

			
			if [ ! -f $workingDir/$originalName ]
			then
				mv $recycleBinDir/$recyleFileName $workingDir/$originalName
				sed -i "/$recyleFileName/d" $recycleBinDirdata
			else
				printf "\nThere is already a file $originalName in the current directory!\n"
				printf "\nDo you want to you want to overwrite it? : \n"
				read orverwriteAnswer
				
				case $orverwriteAnswer in

					[yY] | [yY][Ee][Ss] )
						echo "Overwriting the file:$originalName"
						mv $recycleBinDir/$recyleFileName $workingDir/$originalName
						sed -i "/$recyleFileName/d" $recycleBinDirdata
					;;

					[nN] | [n|N][O|o] )
						echo "Canceling the restore process."
						exit 1
					;;
					*) 
						echo "Invalid input"
					;;
				esac
			fi
			
		elif [ "$(cat $recycleBinDirdata | grep  "//$2//" | wc -l )"  -gt "1" ]
		then
			printf "\nThere is more than one file with the name: $2  in the recycle bin!\n\n"
			cat  -n $recycleBinDirdata | grep  "//$2//"  | sed 's|//|  |g'
			printf "\nPlease Enter the number of the file you want to restore: "
			read number
			
			if [ $number -gt "$(cat $recycleBinDirdata | grep  "//$2//" | wc -l )" -o $number -lt 0 ]
			then
				echo "Invalid input"
				exit 1
			fi
			
			recyleFileName=$(cat $recycleBinDirdata | grep "//$2//" | sed -n "$number p" | awk -F"//" '{print $1}'  )
			originalName=$(cat $recycleBinDirdata | grep "//$2//" | sed -n "$number p" | awk -F"//" '{print $3}'  )
			
			if [ ! -f $workingDir/$originalName ]
			then
				mv $recycleBinDir/$recyleFileName $workingDir/$originalName
				sed -i "/$recyleFileName/d" $recycleBinDirdata
			else
				printf "\nThere is already a file $originalName in the current directory!\n"
				printf "\nDo you want to you want to overwrite it? : \n"
				read orverwriteAnswer
				
				case $orverwriteAnswer in

					[yY] | [yY][Ee][Ss] )
						echo "Overwriting the file:$originalName"
						mv $recycleBinDir/$recyleFileName $workingDir/$originalName
						sed -i "/$recyleFileName/d" $recycleBinDirdata
					;;

					[nN] | [n|N][O|o] )
						echo "Canceling the restore process."
						exit 1
					;;
					*) 
						echo "Invalid input"
					;;
				esac
			fi

		else
			printf "\nFile doesn't exist in the recycle bin!\n\n"
			printf "Usage :  `basename $0` <file name>  #To delete a file.\n"
			printf "Usage :  `basename $0` -d <file name>  #To delete a file.\n"	
			printf "Usage :  `basename $0` -r  <file name>  #To restore a file.\n"		
		fi	
	;;

	-d  )
	        
		if [  -n "$(ls $workingDir/$2)" ]
		then
			# create a base64 hash based on the name and date 
			# so we can use it as the recylebin name of the file
			
			recyleFileName=$(echo  $deletionDate$2 | base64)
			
			mv $workingDir/$2 $recycleBinDir/$recyleFileName
			
			echo "$recyleFileName//$workingDir//$2//$deletionDate" >> $recycleBinDirdata
		else
			printf "\nFile doesn't exist!\n\n"
			printf "Usage :  `basename $0` <file name>  #To delete a file.\n"
			printf "Usage :  `basename $0` -d <file name>  #To delete a file.\n"	
			printf "Usage :  `basename $0` -r  <file name>  #To restore a file.\n"
		fi
	;;
	
	-o )

		
		if [ "$(cat $recycleBinDirdata | grep  "//$2//" | wc -l )"  -eq "1" ]
		then
			recyleFileName=$(cat $recycleBinDirdata | grep "//$2//" | awk -F"//" '{print $1}' )
			originalName=$(cat $recycleBinDirdata | grep "//$2//" | awk -F"//" '{print $3}' )
			originalDirectory=$(cat $recycleBinDirdata | grep "//$2//" | awk -F"//" '{print $2}' )

			
			if [ ! -f $originalDirectory/$originalName ]
			then
				mv $recycleBinDir/$recyleFileName $originalDirectory/$originalName
				sed -i "/$recyleFileName/d" $recycleBinDirdata
			else
				printf "\nThere is already a file $originalName in the current directory!\n"
				printf "\nDo you want to you want to overwrite it? : \n"
				read orverwriteAnswer
				
				case $orverwriteAnswer in

					[yY] | [yY][Ee][Ss] )
						echo "Overwriting the file:$originalName"
						mv $recycleBinDir/$recyleFileName $originalDirectory/$originalName
						sed -i "/$recyleFileName/d" $recycleBinDirdata
					;;

					[nN] | [n|N][O|o] )
						echo "Canceling the restore process."
						exit 1
					;;
					*) 
						echo "Invalid input"
					;;
				esac
			fi
			
		elif [ "$(cat $recycleBinDirdata | grep  "//$2//" | wc -l )"  -gt "1" ]
		then
			printf "\nThere is more than one file with the name: $2  in the recycle bin!\n\n"
			cat  -n $recycleBinDirdata | grep  "//$2//"  | sed 's|//|  |g'
			printf "\nPlease Enter the number of the file you want to restore: "
			read number
			
			if [ $number -gt "$(cat $recycleBinDirdata | grep  "//$2//" | wc -l )" -o $number -lt 0 ]
			then
				echo "Invalid input"
				exit 1
			fi
			
			recyleFileName=$(cat $recycleBinDirdata | grep "//$2//" | sed -n "$number p" | awk -F"//" '{print $1}'  )
			originalName=$(cat $recycleBinDirdata | grep "//$2//" | sed -n "$number p" | awk -F"//" '{print $3}'  )
			originalDirectory=$(cat $recycleBinDirdata | grep "//$2//" | sed -n "$number p" | awk -F"//" '{print $2}'  )
			
			if [ ! -f $originalDirectory/$originalName ]
			then
				mv $recycleBinDir/$recyleFileName $originalDirectory/$originalName
				sed -i "/$recyleFileName/d" $recycleBinDirdata
			else
				printf "\nThere is already a file $originalName in the current directory!\n"
				printf "\nDo you want to you want to overwrite it? : \n"
				read orverwriteAnswer
				
				case $orverwriteAnswer in

					[yY] | [yY][Ee][Ss] )
						echo "Overwriting the file:$originalName"
						mv $recycleBinDir/$recyleFileName $originalDirectory/$originalName
						sed -i "/$recyleFileName/d" $recycleBinDirdata
					;;

					[nN] | [n|N][O|o] )
						echo "Canceling the restore process."
						exit 1
					;;
					*) 
						echo "Invalid input"
					;;
				esac
			fi

		else
			printf "\nFile doesn't exist in the recycle bin!\n\n"
			printf "Usage :  `basename $0` <file name>  #To delete a file.\n"
			printf "Usage :  `basename $0` -d <file name>  #To delete a file.\n"	
			printf "Usage :  `basename $0` -r  <file name>  #To restore a file.\n"		
		fi	
	;;
	
		
	* )
		if [  -n "$(ls $workingDir/$1)" ]
		then
			# create a base64 hash based on the name and date 
			# so we can use it as the recylebin name of the file
			
			recyleFileName=$(echo  $deletionDate$1 | base64)
			
			mv $workingDir/$1 $recycleBinDir/$recyleFileName
			
			echo "$recyleFileName//$workingDir//$1//$deletionDate" >> $recycleBinDirdata
		else
			printf "\nFile doesn't exist!\n\n"
			printf "Usage :  `basename $0` <file name>  #To delete a file.\n"
			printf "Usage :  `basename $0` -d <file name>  #To delete a file.\n"	
			printf "Usage :  `basename $0` -r  <file name>  #To restore a file.\n"
		fi
	;;

esac
	
	
