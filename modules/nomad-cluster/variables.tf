variable "cluster_nodes" {
  type = map(any)
}
variable "cluster_nodes_public_ips" {
  type = map(any)
}
variable "nomad_home" {
  type    = string
  default = "/var/lib/nomad"
}
variable "ssh_private_key" {
  type = string
}
variable "ssh_user" {
  type    = string
  default = "centos"
}
variable "ssh_timeout" {
  type    = string
  default = "15s"
}
variable "cluster_nodes_ids" {
  type = list(string)
}
variable "consul_address" {
  type = string
}
# variable "vault_token_file" {
#   type = string
#   default = ".root_token"
# }