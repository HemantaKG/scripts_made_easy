#!/bin/bash
################################################################################################################################
#
### This script developed to do the following tasks:
#	1. dump MySQL database using "mysqldump"; file saved at ${mysqldump_loc} directory with name ${mysqldump_file} on source host
#	2. backup above generated Mysql dump file to backup storage; at location ${mysqldump_destination_loc}
#	3. backup specified source data directories ${source_data_dir} to location ${data_destination_loc on backup storage
#	4. recods "log" and "error" to ${logfile_loc} location on source host with name "_idackup***.log" and "_ibackup_***.err" respectivily
#	5. sends backup status notification email to list of users ${send_email_to}) 
#
### The things to do before running this script:
##	1. chage the following variables of this script as per your requirment;
#		a. set ${is_mysql_db}="yes" if your want to take mysql bump backup, otherwise set ${is_mysql_db}="no"
#		b. set mysql dump file name ${mysqldump_file}, mysql dump file location on source host ${mysqldump_loc} and mysql dump file destination location ${mysqldump_destination_loc} , if ${is_mysql_db}="yes"
#		c. set source data location ${source_data_dir}
#		d. set destination host ${destination_host}
#		e. set destination location ${data_destination_loc}
##	2. create "mysqlbackup" directory under ${mysqldump_loc} on source host
##	3. create the following directories at destination host under ${mysqldump_destination_loc}
#		a. make directory with name of source hostname 
#		b. make "mysqlbackup" directory under above created directory
#
## Run script:
#	bash ./mysql_backup_single_source_mail.sh
#
# Hemanta Kumar G.
# ICTS-TIFR
# DT20171207
################################################################################################################################

#source machine hostname constant don't change
HN=`hostname`

#mysql db running; NOTE: set to "yes"/"no" as per your requirement
is_mysql_db="no"
#mysql dump file with hostname and date
mysqldump_file="mysql_dump_${HN}_"`date +"%Y_%m_%d"`".sql"
#mysqldump location; NOTE: change as per your requirement
mysqldump_loc="/home/hemanta/"
#source directory; NOTE: change as per your requirement
source_data_dir="/home/hemanta/slurm_test"
#destination machine host FQHN; NOTE: change as per your requirement
destination_host="hemanta@xx.xx.xx"
#destination location; NOTE: change as per your requirement
mysqldump_destination_loc="/home/hemanta/Desktop/"
data_destination_loc="/home/hemanta/Desktop/"
#send email; NOTE: write all email IDs
${send_email_to}="root@localhost hemanta.kumar@icts.res.in"

#status variable default value "0"
problem=0

#Log and Error recording files location and name details
logfile_loc=$(pwd)
log_file=${logfile_loc}"/_ibackup_"`date +"%Y_%m_%d"`".log"
errfile_loc=$(pwd)
err_file=${errfile_loc}"/_ibackup_"`date +"%Y_%m_%d"`".err"

#recode date into log and error files
printf '%s\n' "`date`">>${log_file}
printf '%s\n' "`date`">>${err_file}

#checks whether to take mysql dump or not
if [ "${is_mysql_db}" == "yes" ]; then
	printf '%s\n' "mysql dump start:">>${log_file}
	#dump all MySQL databases on source host and records error
	mysqldump --all-databases >> ${mysqldump_loc}"mysqlbackup/"${mysqldump_file} 2> ${err_file}
	mysqldump_exit_state=$?
	printf '%s\n' "mysql dump end:">>${log_file}
	if [ ${mysqldump_exit_state} -ne 0 ]; then
		email_body="MySQL dump fail."
		problem=1
	else
		printf '%s\n' "mysql dump file backup start: ${mysqldump_file}">>${log_file}
		#backup mysqldump generated file
		rsync -avblph ${mysqldump_loc}"mysqlbackup/"${mysqldump_file} ${destination_host}:${mysqldump_destination_loc}"${HN}/mysqlbackup/" >> ${log_file} 2>> ${err_file}
		rsync_exit_state=$?
		printf '%s\n' "mysql dump file backup end: ${mysqldump_file}">>${log_file}
		#check for rsync error
		if [ ${rsync_exit_state} -ne 0 ]; then
			email_body=${mysqldump_file}" rsync fail."
			problem=1
		else
			printf '%s\n' "data backup start: ${source_data_dir}">>${log_file}
			#backup data directory
			rsync -avblph ${source_data_dir} ${destination_host}:${data_destination_loc}"${HN}/" >> ${log_file} 2>> ${err_file}
			rsync_exit_state=$?
			printf '%s\n' "data backup end: ${source_data_dir}">>${log_file}
			#check for rsync error
			if [ ${rsync_exit_state} -ne 0 ]; then
				email_body=${source_data_dir}" rsync fail."
				problem=1
			fi
		fi
	fi
else
	printf '%s\n' "data backup start: ${source_data_dir}">>${log_file}
	#backup data directory
	rsync -avblph ${source_data_dir} ${destination_host}:${data_destination_loc}"${HN}/" >> ${log_file} 2>> ${err_file}
	rsync_exit_state=$?
	printf '%s\n' "data backup end: ${source_data_dir}">>${log_file}
	#check for rsync error
	if [ ${rsync_exit_state} -ne 0 ]; then
		email_body=${source_data_dir}" rsync fail."
		problem=1
	fi
fi

#if any error send mail
if [ ${problem} -ne 0 ]; then
	#printf '%s\n' "${HN} Backup failed: " ${email_body}
	printf '%s\n' "`date` - ${email_body} - Please check error file - ${err_file}"| /usr/bin/mail -s "${HN} - Backup Failed!!" ${send_email_to}
else
	#printf '%s\n' "${HN} Backup success."
	printf '%s\n' "`date` - Backup Success"| /usr/bin/mail -s "${HN} - Backup Success" ${send_email_to}
fi

#END OF SCRIPT
