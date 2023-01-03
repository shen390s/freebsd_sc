# Increase log verbosity
#log_level = "DEBUG"

enable_syslog = true
syslog_facility="LOCAL1"

datacenter = "%%DATACENTER%%"

# Setup data dir
data_dir = "/var/nomad/data"


plugin_dir="/usr/local/libexec/nomad/plugins"

# Enable the client
client {
  enabled = true

  # For demo assume we are talking to server1. For production,
  # this should be like "nomad.service.consul:4647" and a system
  # like Consul used for service discovery.
  servers = [ %%JOIN_LIST%% ]
}

consul {
  address = "%%MY_IP%%:8500"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
