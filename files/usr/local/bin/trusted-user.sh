#!/bin/ash -e

sshd_pid=$(ps | grep '^\s*[0-9]*\s*'$LOGNAME | grep -v grep | grep "sshd: $LOGNAME@${SSH_TTY/\/dev\/}" | awk '{ print $1 }')
sshd_ppid=$(grep -o 'sshd\[[0-9]*]: User child is on pid '$sshd_pid /var/log/messages)
sshd_ppid=${sshd_ppid##*[}
sshd_ppid=${sshd_ppid%%]*}
user=$(grep -o 'sshd\['$sshd_ppid']: Accepted publickey for .*' /var/log/messages|sed 's/^.*ID \([^ ]*\) .*/\1/g'|tr '[A-Z]' '[a-z]')

grep -q ^$user: /etc/passwd || sudo adduser -D -G wheel $user

exec sudo su - $user

exit

