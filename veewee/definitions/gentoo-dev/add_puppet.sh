#!/bin/bash
source /etc/profile

# install eix as a dep to puppet
chroot "$chroot" /bin/bash <<DATAEOF
emerge eix -1k
DATAEOF

# install Puppet
chroot "$chroot" /bin/bash <<DATAEOF
gem install puppet --no-rdoc --no-ri
gem install librarian-puppet --no-rdoc --no-ri
DATAEOF
