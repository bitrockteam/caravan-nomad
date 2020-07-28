resource "null_resource" "nomad_cluster_node_deploy_config" {
  triggers = {
    ids = join("-", var.cluster_nodes_ids)
  }

  for_each = var.cluster_nodes

  provisioner "file" {
      destination = "/tmp/nomad.hcl.tmpl"
      content = <<-EOT
      ${templatefile(
      "${path.module}/nomad-server.hcl.tmpl",
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

 provisioner "file" {
    destination = "/tmp/nomad_cert.tmpl"
    content = file("${path.module}/nomad_cert.tmpl")

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      timeout     = var.ssh_timeout
      host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    }
  }

  provisioner "file" {
    destination = "/tmp/nomad_keyfile.tmpl"
    content = file("${path.module}/nomad_keyfile.tmpl")

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      timeout     = var.ssh_timeout
      host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    }
  }

  provisioner "file" {
    destination = "/tmp/nomad_ca.tmpl"
    content = file("${path.module}/nomad_ca.tmpl")

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = var.ssh_private_key
      timeout     = var.ssh_timeout
      host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    }
  }
  
  provisioner "remote-exec" {
  inline = ["sudo mv /tmp/nomad.hcl.tmpl /etc/nomad.d/nomad.hcl.tmpl && sudo mv /tmp/nomad_ca.tmpl /etc/nomad.d/nomad_ca && sudo mv /tmp/nomad_cert.tmpl /etc/nomad.d/nomad_cert && sudo mv /tmp/nomad_keyfile.tmpl /etc/nomad.d/nomad_keyfile"]
  connection {
    type        = "ssh"
    user        = var.ssh_user
    timeout     = var.ssh_timeout
    private_key = var.ssh_private_key
    host        = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
  }
}


}
