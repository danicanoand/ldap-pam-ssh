#! /bin/bash
# @edt ASIX M06 2018-2019
# startup.sh
#-------------------------------------------------

/opt/docker/install.sh && echo "Install OK"
/sbin/nslcd && echo "nslcd OK"
/sbin/nscd && echo "nscd OK"
/usr/sbin/sshd && echo "sshd OK"
/bin/bash
