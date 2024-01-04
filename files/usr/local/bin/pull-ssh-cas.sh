#!/bin/ash -e

[ -n $TRUSTED_CAS ] || exit 

TRUSTED_CAS_DIR=${TRUSTED_CAS_DIR:-/etc/ssh}
TRUSTED_CAS_NAME=${TRUSTED_CAS_NAME:-trusted-user-ca-keys}

CURL_OPTS="-s -f --retry 100000 --retry-connrefused --retry-all-errors --retry-delay 15 -b $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME.cookies -c $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME.cookies"

[ -d $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME ] || mkdir $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME

function pull_ca() {
	local i=$1
	local url=$2
	local http_code=$( curl $CURL_OPTS -o $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME/$i.out --write-out '%{http_code}' $url )
	[ "${http_code:0:1}" = '2' ] || return
	mv $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME/$i.out $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME/$i.pem
	cat $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME/*.pem > $TRUSTED_CAS_DIR/$TRUSTED_CAS_NAME.pem
}

i=0
for url in $TRUSTED_CAS; do
	pull_ca $i "$url" &
	i=$(( i + 1 ))
done

