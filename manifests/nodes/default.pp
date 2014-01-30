# ## Node: default
#
# Default node, basically just makes sure the machine ist tamed
# by orca tamer. This should not get used anywhere since we don't
# need any default nodes in the system. Nodes should always be
# provisioned for a specific role and never directly include
# a profile. This definition is here so we never lose control
# of our agents.
#
node default {
  include ::profile::system
}
