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
      cluster_nodes           = var.cluster_nodes
      node_id                 = each.key
      dc_name                 = var.dc_name
      control_plane_role_name = var.control_plane_vault_role
    }
)}
      EOT
connection {
  type                = "ssh"
  user                = var.ssh_user
  private_key         = var.ssh_private_key
  timeout             = var.ssh_timeout
  host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
  bastion_host        = var.ssh_bastion_host
  bastion_port        = var.ssh_bastion_port
  bastion_private_key = var.ssh_bastion_private_key
  bastion_user        = var.ssh_bastion_user
}
}

provisioner "file" {
  destination = "/tmp/nomad-server.hcl"
  content = <<-EOT
      ${templatefile(
  "${path.module}/nomad-server.hcl",
  {
    cluster_nodes = var.cluster_nodes
    node_id       = each.key
    dc_name       = var.dc_name
  }
)}
      EOT
connection {
  type                = "ssh"
  user                = var.ssh_user
  private_key         = var.ssh_private_key
  timeout             = var.ssh_timeout
  host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
  bastion_host        = var.ssh_bastion_host
  bastion_port        = var.ssh_bastion_port
  bastion_private_key = var.ssh_bastion_private_key
  bastion_user        = var.ssh_bastion_user
}
}

provisioner "file" {
  destination = "/tmp/nomad_cert.tmpl"
  content     = file("${path.module}/nomad_cert.tmpl")

  connection {
    type                = "ssh"
    user                = var.ssh_user
    private_key         = var.ssh_private_key
    timeout             = var.ssh_timeout
    host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    bastion_host        = var.ssh_bastion_host
    bastion_port        = var.ssh_bastion_port
    bastion_private_key = var.ssh_bastion_private_key
    bastion_user        = var.ssh_bastion_user
  }
}

provisioner "file" {
  destination = "/tmp/nomad_keyfile.tmpl"
  content     = file("${path.module}/nomad_keyfile.tmpl")

  connection {
    type                = "ssh"
    user                = var.ssh_user
    private_key         = var.ssh_private_key
    timeout             = var.ssh_timeout
    host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    bastion_host        = var.ssh_bastion_host
    bastion_port        = var.ssh_bastion_port
    bastion_private_key = var.ssh_bastion_private_key
    bastion_user        = var.ssh_bastion_user
  }
}

provisioner "file" {
  destination = "/tmp/nomad_ca.tmpl"
  content     = file("${path.module}/nomad_ca.tmpl")

  connection {
    type                = "ssh"
    user                = var.ssh_user
    private_key         = var.ssh_private_key
    timeout             = var.ssh_timeout
    host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    bastion_host        = var.ssh_bastion_host
    bastion_port        = var.ssh_bastion_port
    bastion_private_key = var.ssh_bastion_private_key
    bastion_user        = var.ssh_bastion_user
  }
}

provisioner "remote-exec" {
  inline = ["sudo mv /tmp/nomad.hcl.tmpl /etc/nomad.d/nomad.hcl.tmpl && sudo mv /tmp/nomad_ca.tmpl /etc/nomad.d/nomad_ca.tmpl && sudo mv /tmp/nomad_cert.tmpl /etc/nomad.d/nomad_cert.tmpl && sudo mv /tmp/nomad_keyfile.tmpl /etc/nomad.d/nomad_keyfile.tmpl && sudo mv /tmp/nomad-server.hcl /etc/nomad.d/nomad-server.hcl"]
  connection {
    type                = "ssh"
    user                = var.ssh_user
    timeout             = var.ssh_timeout
    private_key         = var.ssh_private_key
    host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[each.key] : each.value
    bastion_host        = var.ssh_bastion_host
    bastion_port        = var.ssh_bastion_port
    bastion_private_key = var.ssh_bastion_private_key
    bastion_user        = var.ssh_bastion_user
  }
}


}


resource "null_resource" "nomad_server_join" {
  depends_on = [
    null_resource.nomad_cluster_node_deploy_config
  ]
  provisioner "file" {
    destination = "/tmp/nomad_join.sh"
    content = <<-EOT
    ${templatefile("${path.module}/scripts/nomad_join_nodes.sh",
    {
      nodes = var.cluster_nodes
      host  = var.cluster_nodes[keys(var.cluster_nodes)[0]]
})}
    EOT
connection {
  type                = "ssh"
  user                = var.ssh_user
  timeout             = var.ssh_timeout
  private_key         = var.ssh_private_key
  host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[keys(var.cluster_nodes)[0]] : var.cluster_nodes[keys(var.cluster_nodes)[0]]
  bastion_host        = var.ssh_bastion_host
  bastion_port        = var.ssh_bastion_port
  bastion_private_key = var.ssh_bastion_private_key
  bastion_user        = var.ssh_bastion_user
}
}
provisioner "remote-exec" {
  inline = ["chmod +x /tmp/nomad_join.sh && sh /tmp/nomad_join.sh"]
  connection {
    type                = "ssh"
    user                = var.ssh_user
    timeout             = var.ssh_timeout
    private_key         = var.ssh_private_key
    host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[keys(var.cluster_nodes)[0]] : var.cluster_nodes[keys(var.cluster_nodes)[0]]
    bastion_host        = var.ssh_bastion_host
    bastion_port        = var.ssh_bastion_port
    bastion_private_key = var.ssh_bastion_private_key
    bastion_user        = var.ssh_bastion_user
  }
}
}

resource "null_resource" "nomad_acl_bootstrap" {
  depends_on = [
    null_resource.nomad_server_join
  ]

  provisioner "remote-exec" {
    script = "${path.module}/scripts/nomad_acl_bootstrap.sh"
    connection {
      type                = "ssh"
      user                = var.ssh_user
      timeout             = var.ssh_timeout
      private_key         = var.ssh_private_key
      host                = var.cluster_nodes_public_ips != null ? var.cluster_nodes_public_ips[keys(var.cluster_nodes)[0]] : var.cluster_nodes[keys(var.cluster_nodes)[0]]
      bastion_host        = var.ssh_bastion_host
      bastion_port        = var.ssh_bastion_port
      bastion_private_key = var.ssh_bastion_private_key
      bastion_user        = var.ssh_bastion_user
    }
  }
}
