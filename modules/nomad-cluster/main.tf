resource "null_resource" "nomad_cluster_node_deploy_config" {
  triggers = {
    ids = join("-", var.cluster_nodes_ids)
  }
  
  for_each = var.cluster_nodes

  provisioner "file" {
      destination = "/tmp/nomad.hcl"
      content = <<-EOT
      ${templatefile(
      "${path.module}/nomad.hcl",
      {
        cluster_nodes = var.cluster_nodes
        node_id       = each.key
      }
  )}
      EOT
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_private_key
    timeout     = var.ssh_timeout
    host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
  }
}
provisioner "remote-exec" {
  inline = ["sudo mv /tmp/nomad.hcl /etc/nomad.d/nomad.hcl"]
  connection {
    type        = "ssh"
    user        = var.ssh_user
    timeout     = var.ssh_timeout
    private_key = var.ssh_private_key
    host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
  }
}

}

resource "null_resource" "nomad_cluster_node_init" {
  count = length(var.cluster_nodes)
  depends_on = [
    null_resource.nomad_cluster_node_deploy_config
  ]
  triggers = {
    nodes = length(keys(null_resource.nomad_cluster_node_deploy_config)) > 0 ? join("-", [for k, v in null_resource.nomad_cluster_node_deploy_config : v.id]) : ""
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/nomad_cluster_init.sh"
    connection {
      type        = "ssh"
      user        = var.ssh_user
      timeout     = var.ssh_timeout
      private_key = var.ssh_private_key
      host        = var.cluster_nodes_public_ips[keys(var.cluster_nodes)[count.index]]
    }
  }
}