#!/bin/bash
################################################################################################################################
# This script helps you to Backup your Data using rsync command.
# It records LOG and ERROR into "_backup_script.log" and "_bachup_script.err" respectively at PWD of your system.
# Deletes the old backup tar file, as per "KEEP_BACKUP_UPTO_DAYS" and keeps recent "KEEP_BACKUP_UPTO_DAYS-1" backups
# send mail on both "Backup Success" and "Backup Fail" cases
# 
# Please make a directory with name "archive" at PWD location to keep backup tar files
#
# Hemanta Kumar G.
# ICTS-TIFR
# DT20170801
################################################################################################################################

#source directory list
SOURCE_LIST=(/home/hemanta/hm_etc/convert_csv_cfg /home/hemanta/hm_etc/hpc_inter)
#destination host fully qualified host name
DESTINATION_HOST="hemanta@mario.icts.res.in"
#destination location
DESTINATION_LOC="/home/hemanta/"
KEEP_BACKUP_UPTO_DAYS=8
PROBLEM=0

#Log file details
LOGFILE_LOC=$(pwd)
LOG_FILE=${LOGFILE_LOC}"/_backup_script.log"

ERRORFILE_LOC=$(pwd)
ERR_FILE=${ERRORFILE_LOC}"/_backup_script.err"

TAR_SOURCE_LIST=""

#concatenate all source file into a single string
for SOURCE in ${SOURCE_LIST[@]}; do
	TAR_SOURCE_LIST=${TAR_SOURCE_LIST}${SOURCE}" "
done

#recode date into log and error files
printf '%s\n' "`date`">>${LOG_FILE}
printf '%s\n' "`date`">>${ERR_FILE}

#tar file name
TAR_FILENAME=`date +%Y-%m-%d-%H-%M-%S`"_"`hostname`".tar.gz"
#start tar process
printf '%s\n' "TAR START">> ${LOG_FILE}
tar -zcvf "/home/hemanta/hm_etc/archive/"${TAR_FILENAME} ${TAR_SOURCE_LIST}>> ${LOG_FILE} 2>> ${ERR_FILE}
TAR_EXIT_STATUS=$?
printf '%s\n' "TAR END">> ${LOG_FILE}

#backup source location
BACKUP_SOURCE=$(pwd)"/archive/"${TAR_FILENAME}
printf '%s\n' >>${LOG_FILE}
printf '%s\n' >>${ERR_FILE}

#check for tar error
if [ ${TAR_EXIT_STATUS} -ne 0 ]; then
	#delecte created tar file, on any tar error
	rm ${BACKUP_SOURCE}
	EMAIL_SUBJECT="Hostname: `hostname` - tar process failed - Please check error file - "${ERR_FILE}
	PROBLEM=1
else
	printf '%s\n' "BACKUP START">>${LOG_FILE}
	#printf '%s\n' "rsync -av ${BACKUP_SOURCE} ${DESTINATION_HOST}:${DESTINATION_LOC} >> ${LOG_FILE} 2>> ${ERR_FILE}"
	rsync -av ${BACKUP_SOURCE} ${DESTINATION_HOST}:${DESTINATION_LOC} >> ${LOG_FILE} 2>> ${ERR_FILE}
	RSYNC_EXIT_STATUS=$?
	printf '%s\n' "BACKUP END">>${LOG_FILE}
	printf '%s\n' "list source file: [ ${TAR_SOURCE_LIST} ]">> ${LOG_FILE}
	printf '%s\n' "backup tar filename: "${BACKUP_SOURCE##*/}>> ${LOG_FILE}
	#check for rsync error
	if [ ${RSYNC_EXIT_STATUS} -ne 0 ]; then
		EMAIL_SUBJECT="`hostname` - rsync process failed - local backup tar ${BACKUP_SOURCE} - Please check error file - "${ERR_FILE}
		PROBLEM=1
	fi
fi

#if any error send mail
if [ ${PROBLEM} -ne 0 ]; then
	printf '%s\n' "$EMAIL_SUBJECT"
	#printf '%s\n' "$EMAIL_SUBJECT"| /usr/bin/mail -s "`hostname`: Backup Failed!!" root@localhost italert@icts.res.in
else
	OLD_TAR_LIST=("$( ls -t /home/hemanta/hm_etc/archive/ )")
	COUNT=0
	for i in ${OLD_TAR_LIST[@]}; do
		COUNT=$((COUNT+1))
		if [ ${COUNT} -eq ${KEEP_BACKUP_UPTO_DAYS} ]; then
			printf '%s\n' "local backup removed: $i">> ${LOG_FILE}
			REMOVE="$(rm /home/hemanta/hm_etc/archive/$i)"
			REMOVE_OLD_TAR_STATUS=$?
			if [ ${REMOVE_OLD_TAR_STATUS} -eq 0 ]; then
				EMAIL_SUBJECT="`hostname` - old local backup ${i} removed. - Backup Success."
			fi
		fi
	done
	echo 
	printf '%s\n' "** Backup Success ** ${EMAIL_SUBJECT}" 
	#printf '%s\n' "Backup Success"| /usr/bin/mail -s "`hostname`: Backup Success!!" root@localhost hemanta.kumar@icts.res.in
fi

#END OF SCRIPT
