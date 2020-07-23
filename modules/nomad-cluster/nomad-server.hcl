datacenter = "hcpoc"
data_dir = "/var/lib/nomad"
log_level = "DEBUG"
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

plugin "raw_exec" {
  config {
    enabled = true
  }
}

consul {
  address = "${consul_address}"
  server_service_name = "nomad-server"
  client_service_name = "nomad-client"
  auto_advertise      = true
  server_auto_join    = true
  client_auto_join    = true

  ca_file    = "/etc/nomad.d/ca"
  cert_file  = "/etc/nomad.d/cert"
  key_file   = "/etc/nomad.d/keyfile"
  ssl        = true
  verify_ssl = true
}

telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}