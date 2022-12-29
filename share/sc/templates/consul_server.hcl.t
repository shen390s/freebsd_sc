server = true
client_addr = "%%MY_IP%%"
bootstrap_expect = %%VOTE_COUNT%%

connect {
    enabled = true
}


addresses {
    grpc = "0.0.0.0"
}

ports {
    grpc = 8502
}

ui_config {
    enabled = true
}
