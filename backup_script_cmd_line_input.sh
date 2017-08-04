#!/bin/bash
################################################################################################################################
# This script helps you to Backup your Data using rsync command.
# It takes source, distination FQHN and distination location information as command line arguments to run rsync command.
# It records LOG and ERROR into "_backup_script.log" and "_bachup_script.err" respectively at location "/tmp" of your system. 
#
# Usage: ./backup_scrip.sh -sloc convert_csv_cfg -dfqhn hemanta@mario.icts.res.in -dloc /home/hemanta/
# Where: 
# -sloc SOURCE
# -dfqhn DESTINATION_HOST_FQHN
# -dloc DISTINATION LOCATION
#
# Hemanta Kumar G.
# ICTS-TIFR
# DT20170731
################################################################################################################################

# Parse the command line string input
if [ $# -eq 6 ]; then
	while [[ $# -gt 1 ]]
	do
	key="$1"
	#echo "$1"
	case $key in
		-sloc|--source_loc)
		SOURCE_LOC="$2"
		shift # past argument
		;;
		-dfqhn|--destination_fqhn)
		DESTINATION_HOST_FQHN="$2"
		shift # past argument
		;;
		-dloc|--destination_loc)
		DESTINATION_LOC="$2"
		shift # past argument
		;;
		*)
		# unknown option
		;;
	esac
	shift # past argument or value
	done
else
	echo "usage:" 
	echo "${0} -sloc convert_csv_cfg -dfqhn hemanta@mario.icts.res.in -dloc /home/hemanta/"
	exit 1
fi

#echo SOURCE_LOC  = "${SOURCE_LOC}"
#echo DESTINATION_HOST_FQHN	 = "${DESTINATION_HOST_FQHN}"
#echo DESTINATION_LOC	= "${DESTINATION_LOC}"

#Log file details
LOGFILE_LOC="/tmp/"
#echo "LOGFILE_LOCATION= ${LOGFILE_LOC}"
LOG=${LOGFILE_LOC}"_backup_script.log"
#echo "LOGFILE NAME= ${LOG}"
date>>${LOG}

ERRORFILE_LOC="/tmp/"
#echo "ERRORFILE_LOCATION= ${ERRORFILE_LOC}"
ERR=${ERRORFILE_LOC}"_backup_script.err"
#echo "ERRORFILE NAME= ${ERR}"
date>>${ERR}

#backup using rsync
#echo "rsync -av ${SOURCE_LOC} ${DESTINATION_HOST_FQHN}:${DESTINATION_LOC} > ${LOG} 2> ${ERR}"
rsync -av ${SOURCE_LOC} ${DESTINATION_HOST_FQHN}:${DESTINATION_LOC} >> ${LOG} 2>> ${ERR}

echo >>${LOG}
echo >>${ERR}

#END OF SCRIPT
