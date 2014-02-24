#!/bin/bash
source /etc/profile

# install puppet deps
chroot "$chroot" /bin/bash <<DATAEOF
echo '=dev-ruby/rgen-0.6.6 ~amd64' >> /etc/portage/package.accept_keywords/default
emerge app-portage/eix app-admin/eselect dev-ruby/rgen -1k
DATAEOF

# install Puppet
chroot "$chroot" /bin/bash <<DATAEOF
echo '=app-admin/augeas-1.1.0 ~amd64' >> /etc/portage/package.accept_keywords/default
USE="augeas diff doc shadow vim-syntax" emerge app-admin/puppet -1k
echo 'version: 2' > /etc/puppet/hiera.yaml
DATAEOF

# install librarian-puppet (currently from git so install works)
# @todo bump back to simple gem install when >0.9.10 is released
chroot "$chroot" /bin/bash <<DATAEOF
gem install librarian-puppet
DATAEOF

