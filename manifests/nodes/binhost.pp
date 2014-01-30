# ## Node: binhost
#
# Simple node with almost nothing.
#
# This proof of concept machine is here so we always have a
# baseline indicator to tell if build are failing due to the
# base setup or some interaction with any of the deployed
# services.
#
node binhost {
  include ::role::infra::binhost
}
