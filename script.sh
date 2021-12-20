#!/bin/bash

endCol="\e[0m"
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"


read -p $'Which action?\n1) Create/Change users\n2) Delete users from system which has same username as in file\n' action
read -p "Which file contains users? " fileToRead


for line in $(cat $fileToRead)
do
	username=`echo $line | cut -d , -f1`
	password=`echo $line | cut -d , -f3`
	ssl_password=`openssl passwd -crypt $password`
	group=`echo $line | cut -d , -f2`
	shell=`echo $line | cut -d , -f4`

	case $action in 
	1) if [[ `grep $username /etc/passwd` ]]
	then 
		read -p "Do you want to make changes to user $username? [y/N] " change_action
		if [[ "$change_action" =~ ^([yY])$ ]]
		then
			read -p "Change user $username password? [y/N] " pass_change
			if [[ "$pass_change" =~ ^([yY])$ ]]
			then
				usermod -p $ssl_password $username
				echo -e "$yellow $username password is changed $endCol"	
			fi		
			
			read -p "Change user $username shell? [y/N] " shell_change
			if [[ "$shell_change" =~ ^([yY])$ ]]
			then
				current_shell=`grep $username /etc/passwd | cut -d : -f7`
				if [[ $current_shell != $shell ]]
				then
					usermod -s $shell $username
					echo -e "$yellow $username shell changed to $shell $endCol"
				else
					echo -e "$red $username already has $shell as shell $endCol"
				fi
			fi
			
			
			read -p "Change user $username group? [y/N] " group_change
			if [[ "$group_change" =~ ^([yY])$ ]]
			then
				current_group=`groups $username | cut -d " " -f3`
				if [[ $current_group != $group ]]
				then
					usermod -g $group $username
					echo -e "$yellow $username group changed to $group $endCol"
				else
					echo -e "$red $username already in the group $group $endCol"
				fi
			
			fi
		fi
	else
		groupadd -f $group;
		useradd $username -p $ssl_password -g $group -s $shell;
		echo -e "$green created user $username and assigned to group $group $endCol"
	fi;;
	2) if [[ `grep $username /etc/passwd` ]] 
	then
		userdel -r $username
		echo -e "$yellow user $username deleted $endCol"
	fi;;
	esac
done
