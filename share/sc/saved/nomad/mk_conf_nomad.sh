#!/bin/sh

set -x
get_ip() {
   _ifs="$1"

   if [ -z "$_ifs" ]; then
      _ifs="em0 re0"
   fi

   for _if in $_ifs; do
       _ip=$(ifconfig "$_if" | grep inet | head -n 1 | awk '{print $2}')
       if [ -z "$_ip" ]; then
          :
       else
           echo $_ip
           return
       fi   
   done

   echo
}

vote_count() {
  _cnt=0

  for _s in $servers; do
     _cnt=$(expr $_cnt + 1)
  done

  echo $_cnt
}

get_join_list() {
  _list=""
  _sep=""

  for _s in $servers; do
     _list="$_list $_sep \"$_s\""
     _sep=","
  done

  echo $_list
}

mk_nomad_client_conf() {
   cat <<EOF
# Increase log verbosity
#log_level = "DEBUG"

enable_syslog = true
syslog_facility="LOCAL1"

datacenter = "$datacenter"

# Setup data dir
data_dir = "/var/nomad/data"


plugin_dir="/usr/local/libexec/nomad/plugins"

# Enable the client
client {
  enabled = true

  # For demo assume we are talking to server1. For production,
  # this should be like "nomad.service.consul:4647" and a system
  # like Consul used for service discovery.
  servers = [ $(get_join_list) ]
}

consul {
  address = "$(get_ip):8500"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
EOF
}

mk_nomad_server_conf() {
   cat <<EOF
advertise {
  http = "$(get_ip)"
  serf = "$(get_ip)"
  rpc  = "$(get_ip)"
}

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = $(vote_count)

  server_join {
     retry_join = [ $(get_join_list) ]
  }
}
EOF
}

mk_conf() {
   _nomad_conf_dir="/usr/local/etc/nomad"

   rm -Rf $_nomad_conf_dir/*
   
   mk_nomad_client_conf >$_nomad_conf_dir/client.hcl
   
   if [ "x$is_server" = "xyes" ];then
      mk_nomad_server_conf >$_nomad_conf_dir/server.hcl
   fi 

   chown -Rf nomad:nomad $_nomad_conf_dir

   sysrc nomad_enable="YES"
   sysrc nomad_args=" -config=/usr/local/etc/nomad"
   sysrc nomad_user="root"
   sysrc nomad_env="PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin"
}

datacenter="dc1"
servers=""
is_server="yes"

while [ $# -gt 0 ]; do
   case "$1" in
       dc=*)
           datacenter=$(echo $1 |awk -F= '{print $2}')
           shift
           ;;
       servers=*)
           servers=$(echo $1 |awk -F= '{print $2}' |sed -e 's/\"//g')
           shift
           ;;
       is_server=*)
           is_server=$(echo $1|awk -F= '{print $2}')
           shift
           ;;
       *)
           echo unkown argument: $1
           shift
           ;;
    esac
done

mk_conf
