# sshd-trusted-user
Dynamically create users on the fly when using [TrustedUserCAKeys](https://man.openbsd.org/sshd_config#TrustedUserCAKeys) 

## Premise
Whether deploying a fleet of servers, vms, or containers, sometimes it is necessary to troubleshoot these from the inside. No matter how all-encompassing your observability is, no matter how comprehensive your remote logging is, the fact remains – troubleshooting is a hands-on process and requires direct access to the problem area.  

## Scope
Provide an ssh sign-in solution which allows a per user audit trail without relying on an external party for the account provisioning.
> Note: Setting up an SSH CA Signer is not in scope of this project. I intend to write about it [here](https://github.com/maxfortun/ssh-ca-signer-oidc).

## Challenges
There are not many options for enterprise environments for providing [SSO](https://en.wikipedia.org/wiki/Single_sign-on) to a fleet of systems. It is either the LDAP, individual accounts, or a shared account.  

LDAP works great as a source of truth, but may, in itself, be the point of failure at runtime.  

Individual accounts require either a build-time knowledge of who is authorized, or a mechanism for provisioning and de-provisioning accounts across the fleet.  

Group accounts are easy to set up ahead of time, but have a less granular audit trail from individual accounts, and do, also, require a similar synchronization mechanism for `authorized_keys`.  

## Solution
Luckily, OpenSSH supports TrustedUserCAs. Which means that we can combine the 3 above mentioned techniques and create the individual accounts on the fly without depending on the LDAP.   

1. Have your SSH CA Signer specify `trusted` as a principal.
```
/usr/bin/ssh-keygen -s /etc/ssh/ca \
   -I "$user" \
   -n "trusted" \
   -V +1h \
   $HOME/.ssh/id_rsa
```
2. Create the `trusted` account on the system.
1. Configure the `trusted` account to create users if missing, then `su` into those accounts. 
1. ssh into the system.
```
ssh -i $HOME/.ssh/id_rsa -i $HOME/.ssh/id_rsa-cert.pub trusted@system
```

## POC with an alpine linux container
### Build
```
docker build -t sshd-trusted-user .
```

### Run
```
docker run -it -p 50922:22/tcp -e TRUSTED_CAS='https://trusted-ca-hostname/ssh-ca-signer/ca.pub' sshd-trusted-user
```

### Test
```
ssh -i $HOME/.ssh/id_rsa -i $HOME/.ssh/id_rsa-cert.pub -p 50922 trusted@localhost
```

