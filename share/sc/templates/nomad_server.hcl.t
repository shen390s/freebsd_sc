advertise {
  http = "%%MY_IP%%"
  serf = "%%MY_IP%%"
  rpc  = "%%MY_IP%%"
}

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = %%VOTE_COUNT%%

  server_join {
     retry_join = [ %%JOIN_LIST%% ] 
  }
}
