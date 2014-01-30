# ## Node: logstash
#
# The logstash node has an elsticsearch/logstash setup running and is
# configured so to enable centralized log viewing.
#
node logstash {
  include ::role::logstash
}
