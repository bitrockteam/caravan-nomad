resource "null_resource" "nomad_cluster_node_deploy_config" {
  triggers = {
    ids = join("-", var.cluster_nodes_ids)
  }

  for_each = var.cluster_nodes

  provisioner "file" {
      destination = "/tmp/nomad.hcl"
      content = <<-EOT
      ${templatefile(
      "${path.module}/nomad-server.hcl",
      {
        cluster_nodes   = var.cluster_nodes
        node_id         = each.key
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
