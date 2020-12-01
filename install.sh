#!/bin/bash

# path for Apache cerificates
APACHE_PATH=/etc/apache2/ssl

ARGC=$#
ARGV=("$@")

# need at least 2 args, first a directory and second a file
if [ ${ARGC} -lt 2 -o ! -d $1 -o ! -f $2 ]; then
  echo "Usage: ${0} domain_year zip_file [server1 [server2 ...]]"
  exit 1
fi

# need domain, zip file
DIR=$1
ZIP=$2

# remove possible trailing /
DIR=`echo ${DIR} | sed -e 's:/*$::'`

# get names of certificate, intermediate and root files
{ read -r OLDCRT && read -r INTERMEDIATE && read -r ROOT; } < <(unzip -l ${ZIP} | grep -o "[^ ]*.crt")

# unzip ZIP file
unzip ${ZIP} -d ${DIR}

# rename certificate for domain
CRT=${DIR}/${DIR}.crt
mv ${DIR}/${OLDCRT} ${CRT}

# create ca-bundle
CABUNDLE=${DIR}/${DIR}.ca-bundle
cat ${DIR}/${INTERMEDIATE} ${DIR}/${ROOT} > ${CABUNDLE}

# name of .key file
KEY=${DIR}/${DIR}.key

# finished if no servers given
if [ "${ARGC}" -eq 2 ]; then
  echo "done"
  exit
fi

# expand command for installing on remote server
CMD="sudo mv /tmp/${DIR}.{key,crt,ca-bundle} ${APACHE_PATH} && sudo chmod 640 ${APACHE_PATH}/${DIR}.{key,crt,ca-bundle} && sudo chown www-data:root ${APACHE_PATH}/${DIR}.{key,crt,ca-bundle}"

# copy files to servers
for (( i = 2; i < ARGC; i ++)); do
  HOST=${ARGV[i]}
  echo "Copying to ${HOST}"
  scp ${KEY} ${CRT} ${CABUNDLE} ${HOST}:/tmp/
  ssh -t ${HOST} 'sudo -v'
  ssh ${HOST} "${CMD}"
done

# output lines for Apache config
echo "Copy these lines to Apache's config"
echo -e "\tSSLCertificateFile\t${APACHE_PATH}/${DIR}.crt"
echo -e "\tSSLCertificateKeyFile\t${APACHE_PATH}/${DIR}.key"
echo -e "\tSSLCertificateChainFile\t${APACHE_PATH}/${DIR}.ca-bundle"
