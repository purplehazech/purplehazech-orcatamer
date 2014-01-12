#!/bin/bash
source /etc/profile

# install system logger
chroot "$chroot" /bin/bash <<DATAEOF
emerge app-admin/syslog-ng
rc-update add syslog-ng default
DATAEOF
