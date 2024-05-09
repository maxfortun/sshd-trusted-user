#!/bin/ash -e

user=$(cat $SSH_USER_AUTH | cut -d' ' -f2- | ssh-keygen -L -f - | grep '^ *Key ID:' | cut -d'"' -f2 | tr '[A-Z]' '[a-z]')

grep -q ^$user: /etc/passwd || sudo adduser -D -G wheel $user

if [ -z "$SSH_ORIGINAL_COMMAND" ]; then
	exec sudo login -f $user
else
	exec sudo -u $user $SSH_ORIGINAL_COMMAND 
fi  

exit

