#!/bin/bash
# self sign certificate

function getValue() {
    key=${1}
    default_value=${2}
    result=""
    if [[ -f custom.cf ]]; then
      result=`grep "${key}=" custom.cf | awk -F'=' '{print $2}'`
    fi
    if [[ -z ${result} ]]; then
      result="${default_value}"
    fi
    echo ${result}
    return 0
}

echo "generate self sign certificate"

version=`openssl "version"`

echo "using $version"

ca_numbits=`getValue "ca_numbits" "4096"`

echo "generate ca key using numbits ${ca_numbits}"
openssl genrsa -out ca.key ${ca_numbits}

ca_c=`getValue ca_c "CN"`
ca_st=`getValue ca_st "Beijing"`
ca_l=`getValue ca_l "Beijing"`
ca_o=`getValue ca_o "Ca"`
ca_ou=`getValue ca_ou "Personal"`
ca_cn=`getValue ca_cn "self.ca.org"`
ca_days=`getValue ca_days "3650"`

echo "generate ca crt for ${ca_cn}"
openssl req -x509 -new -nodes -sha512 -days ${ca_days} \
-subj "/C=${ca_c}/ST=${ca_st}/L=${ca_l}/O=${ca_o}/OU=${ca_ou}/CN=${ca_cn}" \
-key ca.key \
-out ca.crt

svr_numbits=`getValue "svr_numbits" "4096"`

svr_domain=`getValue svr_domain "example.com"`
svr_c=`getValue svr_c "CN"`
svr_st=`getValue svr_st "Beijing"`
svr_l=`getValue svr_l "Beijing"`
svr_o=`getValue svr_o "Example"`
svr_ou=`getValue svr_ou "Personal"`
svr_days=`getValue svr_days "3650"`
svr_host=`getValue svr_host "localhost.domain"`

echo "generate server key using numbits ${svr_numbits}"
openssl genrsa -out "${svr_domain}.key" ${svr_numbits}

echo "generate certificate sign request "
openssl req -sha512 -new \
-subj "/C=${svr_c}/ST=${svr_st}/L=${svr_l}/O=${svr_o}/OU=${svr_ou}/CN=${svr_domain}" \
-key "${svr_domain}.key" \
-out "${svr_domain}.csr"

echo "generate x509 v3 ext file"
echo "authorityKeyIdentifier=keyid,issuer" > v3.ext
echo "basicConstraints=CA:FALSE" >> v3.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> v3.ext
echo "extendedKeyUsage = serverAuth" >> v3.ext
echo "subjectAltName = @alt_names" >> v3.ext
echo "" >> v3.ext
echo "[alt_names]" >> v3.ext
echo "DNS.1=${svr_domain}" >> v3.ext
echo "DNS.2=${svr_domain%.*}" >> v3.ext
echo "DNS.3=${svr_host}" >> v3.ext

echo "generate server crt for ${svr_domain}"
openssl x509 -req -sha512 -days ${svr_days} \
-extfile v3.ext \
-CA ca.crt -CAkey ca.key -CAcreateserial \
-in "${svr_domain}.csr" \
-out "${svr_domain}.crt"
