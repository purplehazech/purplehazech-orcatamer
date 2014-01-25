#!/bin/bash
source /etc/profile

# install eix as a dep to puppet
chroot "$chroot" /bin/bash <<DATAEOF
emerge app-portage/eix app-admin/eselect -1k
DATAEOF

# install Puppet
chroot "$chroot" /bin/bash <<DATAEOF
echo '=app-admin/augeas-1.1.0 ~amd64' > /etc/portage/package.keywords/default
echo 'version: 2' > /etc/puppet/hiera.yaml
USE="augeas diff doc shadow vim-syntax" emerge app-admin/puppet -1k
DATAEOF

# install librarian-puppet (currently from git so install works)
# @todo bump back to simple gem install when >0.9.10 is released
chroot "$chroot" /bin/bash <<DATAEOF
cd /tmp
git clone git://github.com/rodjek/librarian-puppet.git 
cd librarian-puppet
sed --in-place -e 's/"0.9.10"/"0.9.10.veewee.0"/' lib/librarian/puppet/version.rb
gem build librarian-puppet.gemspec
gem install librarian-puppet-0.9.10.veewee.0.gem --no-rdoc --no-ri
DATAEOF

