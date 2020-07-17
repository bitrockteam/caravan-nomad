data_dir = "/var/lib/nomad"
server {
  enabled = true
  bootstrap_expect = 3
}

server_join {
    retry_join = [
        %{ for n in setsubtract(keys("${cluster_nodes}"), [node_id]) ~}
        "${cluster_nodes[n]}:4647",
        %{ endfor ~}
    ]
}

consul {
  address = "127.0.0.1:8500"
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise      = true
  server_auto_join    = true
  client_auto_join    = true
}