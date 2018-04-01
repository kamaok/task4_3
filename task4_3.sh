#!/bin/bash

DATE="$(date +"%Y-%m-%d-%H-%M-%S")"
SOURCE_DIR="$1"
COPY_NUMBER="$2"
DEST_DIR="/tmp/backups"
NUMBER='^[0-9]+$'
TAR=$(which tar)

if [ $# -ne "2" ]; then
	echo "ERROR: You should pass two position arguments" >&2; exit 1
fi

if ! [ -d ${SOURCE_DIR} ]; then
	echo "ERROR: The directory "${SOURCE_DIR}" does not exist" >&2; exit 1
fi

if ! [[ "${COPY_NUMBER}" =~ $NUMBER ]]; then
    echo "ERROR: "${COPY_NUMBER}" is not a number" >&2; exit 1
fi

[ -d "${DEST_DIR}" ] || mkdir -p "${DEST_DIR}"

FILE_NAME=$(echo "${SOURCE_DIR}" | sed 's|^/||' | sed 's|/$||g' | sed 's|/|-|g')
$TAR -czf  ${DEST_DIR}/${FILE_NAME}-$DATE.tar.gz "${SOURCE_DIR}" > /dev/null 2>&1

CURRENT_COUNTER=$(ls -l /tmp/backups/ | awk '{print $9}' | sed '1d' | grep ${FILE_NAME} | wc -l)

if [ "${CURRENT_COUNTER}" -gt "${COPY_NUMBER}" ] ; then

while [ "${CURRENT_COUNTER}" -ne "${COPY_NUMBER}" ] ; do
        FILE_DEL=$(ls -l /tmp/backups/ | awk '{print $9}' | sed '1d' | grep ${FILE_NAME} | head -1)
        rm  /tmp/backups/${FILE_DEL}
        let CURRENT_COUNTER=CURRENT_COUNTER-1
done

fi

