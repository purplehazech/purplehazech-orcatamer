# # Site: orcatamer
#
# This site includes all the available nodes in a orca tamer
# setup. It is used during all kinds of puppet runs along
# with the modules loaded using ``librarian-puppet`` during
# provisioning.
#
import 'profile/manifests/*.pp'
import 'profile/manifests/**/*.pp'
import 'role/manifests/*.pp'
import 'role/manifests/**/*.pp'
import 'nodes/*.pp'
