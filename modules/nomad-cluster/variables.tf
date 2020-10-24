variable "cluster_nodes" {
  type = map(any)
}
variable "cluster_nodes_public_ips" {
  type    = map(any)
  default = null
}
variable "dc_name" {
  type    = string
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
variable "ssh_bastion_host" {
  type    = string
  default = null
}
variable "ssh_bastion_port" {
  type    = string
  default = "22"
}
variable "ssh_bastion_private_key" {
  type    = string
  default = null
}
variable "ssh_bastion_user" {
  type    = string
  default = null
}
variable "cluster_nodes_ids" {
  type = list(string)
}
variable "pre13_depends_on" {
  type    = any
  default = null
}
