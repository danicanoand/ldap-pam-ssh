
# SSHSERVER

## @edt ASIX M06 2018-2019

Podeu trobar les imatges docker al Dockehub de [danicano](https://hub.docker.com/u/danicano)

Podeu trobar la documentació del mòdul a [ASIX-M06](https://sites.google.com/site/asixm06edt/)


ASIX M06-ASO Escola del treball de barcelona

### Imatges:

* * **sshserver:18base** servidor base ssh, basat en una imatge de hostpam que permet autenticar usuaris locals i remots usant un servidor ldapserver via SSH. Es configura també l'accés dels usuaris mitjançant restriccions tipus AllowUsers en SSH, mitjançant PAM amb pam_access.so i amb pam_listfile.so. Si l'usuari no te HOME se li crea un al inicia sessió. [Imatge ldapserver](https://hub.docker.com/r/danicano/sshserver)

* * **danicano/ldapserver:18dataDB** Servidor ldap amb edt.org, amb usuaris i grups. [Imatge ldapserver](https://hub.docker.com/r/danicano/ldapserver)


### Configuració ssh

/etc/ssh/sshd_config
```
Port 1022
AllowUsers anna local01 pere local02
```

/etc/openldap/ldap.conf
```
BASE	dc=edt,dc=org
URI		ldap://server
```

/etc/nsswitch.conf
```
passwd:    files ldap
shadow:    files 
group:     files ldap
```

/etc/nslcd.conf
```
uri ldap://server
base dc=edt,dc=org
```

/etc/pam.d/ssh
```
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth    required        pam_env.so
auth    optional        pam_mount.so
auth    required       pam_listfile.so onerr=succeed item=user sense=deny file=/opt/docker/usersdeny
auth    required        pam_access.so
auth    sufficient      pam_unix.so try_first_pass nullok
auth    sufficient      pam_ldap.so
auth    required        pam_deny.so

account		sufficient	pam_unix.so
account		sufficient	pam_ldap.so

password	requisite	pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password	sufficient	pam_unix.so try_first_pass use_authtok nullok sha512 shadow
password	required	pam_deny.so

session		optional	pam_keyinit.so revoke
session		required	pam_limits.so
-session	optional	pam_systemd.so
session		[success=1 default=ignore]	pam_succeed_if.so service in crond quiet use_uid
session		optional	pam_mkhomedir.so 	
session		optional	pam_mount.so
session		sufficient	pam_unix.so
session		sufficient	pam_ldap.so
```


#### Execució

```
docker run --rm --name server -h server --network sshserver -d danicano/ldapserver:18dataDB

docker run --rm --name sshserver -h samba --network sshserver --privileged -it danicano/sshserver:18base
```

#### Observació

```
Permetem a quatre usuaris accedir per ssh, dos locals (local01, local02) i dos de ldap (anna, pere).
A local01 se li denega l´accés amb 'pam_listfile.so' i a l´anna li denega 'pam_access.so',
pere i local02 podem accedir.
```


#### Exemple
```
[danicanoand@pc ldap-pam-ssh]$ ssh -p 1022 pere@172.90.0.3
The authenticity of host '[172.90.0.3]:1022 ([172.90.0.3]:1022)' can't be established.
ECDSA key fingerprint is SHA256:nYP+8viRhTYke8Ao6OiVAHU7sXJ/Ky/kW5R+ThLof6I.
ECDSA key fingerprint is MD5:86:13:49:98:de:de:c7:a4:70:18:80:f9:c6:da:5e:bc.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[172.90.0.3]:1022' (ECDSA) to the list of known hosts.
pere@172.90.0.3's password: 
Creating directory '/tmp/home/pere'.
[pere@samba ~]$ logout
```


