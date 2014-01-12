#!/bin/bash
source /etc/profile

# install eix as a dep to puppet
emerge eix -1k

# install Puppet
chroot "$chroot" /bin/bash <<DATAEOF
gem install puppet --no-rdoc --no-ri
gem install librarian-puppet --no-rdoc --no-ri
DATAEOF
