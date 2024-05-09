#!/bin/ash -e

SD=$(dirname $(readlink -f $0))

cat >> /etc/ssh/sshd_config << EOT
LogLevel DEBUG
PermitRootLogin prohibit-password
TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
ExposeAuthInfo yes
CASignatureAlgorithms ^ssh-rsa
PubkeyAcceptedKeyTypes ^ssh-rsa,ssh-rsa-cert-v01@openssh.com

Match user trusted
	ForceCommand /usr/local/bin/trusted-user.sh

EOT

adduser -H -h / -D -G wheel trusted

sed -i 's/^trusted:!/^trusted:*/' /etc/shadow

$SD/pull-ssh-cas.sh

/sbin/syslogd
/usr/bin/ssh-keygen -A

if [ -n "$1" ]; then
	/usr/sbin/sshd
	exec "$@" 
else
	/usr/sbin/sshd -D
fi

