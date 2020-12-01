#!/bin/bash

# need domain as first argument
DOMAIN=$1

# make sure that domain is given
if [ "${DOMAIN}x" == "x" ]; then
  echo "Usage: ${0} domain"
  exit 1
fi

# need year
YEAR=`date "+%Y"`
# need username
ME=`whoami`

# directory to hold files
DIR=${DOMAIN}_${YEAR}
# name for CSR file
CSR=${DIR}/${DOMAIN}_${YEAR}.csr
# name for key
KEY=${DIR}/${DOMAIN}_${YEAR}.key
# name for ssl.conf
SSL=${DIR}/ssl.conf
# domain without www.
NOWWW=`echo ${DOMAIN} | sed -e "s/^www\.//"`

# create directory to hold files
mkdir -p ${DIR}

# generate key
openssl genrsa -out ${KEY}

# generate SSL conf
cat << EOF > ${SSL}
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
countryName = Country Name (2 letter code)
countryName_default = GB
stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = Fife
localityName = Locality Name (eg, city)
localityName_default = St Andrews
0.organizationName = Organization Name (company)
0.organizationName_default = University of St Andrews
organizationalUnitName  = Organizational Unit Name (eg, section)
organizationalUnitName_default  = IT Services
emailAddress = Email address
emailAddress_default = ${ME}@st-andrews.ac.uk
commonName = Put domain name here
commonName_default = ${DOMAIN}
commonName_max  = 64

[ v3_req ]
# Extensions to add to a certificate request
#basicConstraints = CA:FALSE
#keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}
EOF

# domain has leading www., so add domain without it
if [ ${DOMAIN} != ${NOWWW} ]; then
  echo "DNS.2 = ${NOWWW}" >> ${SSL}
fi

# generate CSR
openssl req -batch -new -sha256 -key ${KEY} -out ${CSR} -config ${SSL}

echo "Your CSR is here:" `pwd`/${CSR}
