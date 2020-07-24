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
  address = "127.0.0.1:8501"
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise      = true
  server_auto_join    = true
  client_auto_join    = true

  ca_file    = "/etc/consul.d/ca"
  cert_file  = "/etc/consul.d/cert"
  key_file   = "/etc/consul.d/keyfile"
  ssl        = true
  verify_ssl = true

}

tls {
    http = true
    rpc  = true

    ca_file    = "/etc/consul.d/ca"
    cert_file  = "/etc/consul.d/cert"
    key_file   = "/etc/consul.d/keyfile"

    verify_https_client    = false
    #verify_server_hostname = true
}

telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}