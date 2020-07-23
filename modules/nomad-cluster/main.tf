resource "null_resource" "nomad_cluster_node_deploy_config" {
  triggers = {
    ids = join("-", var.cluster_nodes_ids)
  }

  for_each = var.cluster_nodes

  provisioner "file" {
    destination = "/tmp/nomad-cert.tmpl"
    content = file("${path.module}/cert.tmpl")

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      timeout     = var.ssh_timeout
      host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    }
  }

  provisioner "file" {
    destination = "/tmp/nomad-keyfile.tmpl"
    content = file("${path.module}/keyfile.tmpl")

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      timeout     = var.ssh_timeout
      host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    }
  }

  provisioner "file" {
    destination = "/tmp/nomad-ca.tmpl"
    content = file("${path.module}/ca.tmpl")

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      timeout     = var.ssh_timeout
      host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    }
  }


  provisioner "file" {
      destination = "/tmp/nomad.hcl"
      content = <<-EOT
      ${templatefile(
      "${path.module}/nomad-server.hcl",
      {
        cluster_nodes   = var.cluster_nodes
        node_id         = each.key
        consul_address  = var.consul_address
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
  inline = ["sudo mv /tmp/nomad.hcl /etc/nomad.d/nomad.hcl && sudo mv /tmp/nomad-ca.tmpl /etc/nomad.d/ca.tmpl && sudo mv /tmp/nomad-cert.tmpl /etc/nomad.d/cert.tmpl && sudo mv /tmp/nomad-keyfile.tmpl /etc/nomad.d/keyfile.tmpl"]
  connection {
    type        = "ssh"
    user        = var.ssh_user
    timeout     = var.ssh_timeout
    private_key = var.ssh_private_key
    host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
  }
}

}
