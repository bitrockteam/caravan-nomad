datacenter = "${dc_name}"
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

acl {
  enabled = true
}

telemetry {
  collection_interval = "10s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
