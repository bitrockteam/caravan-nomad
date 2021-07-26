# Caravan Nomad Cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.nomad_acl_bootstrap](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.nomad_cluster_node_deploy_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.nomad_server_join](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_nodes"></a> [cluster\_nodes](#input\_cluster\_nodes) | A map in form of 'node-name' => 'node's private IP' of the nodes to provision the cluster on | `map(any)` | n/a | yes |
| <a name="input_cluster_nodes_ids"></a> [cluster\_nodes\_ids](#input\_cluster\_nodes\_ids) | list of strings which are IDs of the instance resources and are used to `trigger` the provisioning of `null` resources on instance recreation | `list(string)` | n/a | yes |
| <a name="input_dc_name"></a> [dc\_name](#input\_dc\_name) | Name of the datacenter of the consul cluster | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | n/a | `string` | n/a | yes |
| <a name="input_cluster_nodes_public_ips"></a> [cluster\_nodes\_public\_ips](#input\_cluster\_nodes\_public\_ips) | The public IPs of the node to SSH into them | `map(any)` | `null` | no |
| <a name="input_control_plane_vault_role"></a> [control\_plane\_vault\_role](#input\_control\_plane\_vault\_role) | n/a | `string` | `null` | no |
| <a name="input_license"></a> [license](#input\_license) | Nomad Enterprise License | `string` | `""` | no |
| <a name="input_nomad_home"></a> [nomad\_home](#input\_nomad\_home) | The directory where the consul's data is kept on the nodes | `string` | `"/var/lib/nomad"` | no |
| <a name="input_ssh_bastion_host"></a> [ssh\_bastion\_host](#input\_ssh\_bastion\_host) | n/a | `string` | `null` | no |
| <a name="input_ssh_bastion_port"></a> [ssh\_bastion\_port](#input\_ssh\_bastion\_port) | n/a | `string` | `"22"` | no |
| <a name="input_ssh_bastion_private_key"></a> [ssh\_bastion\_private\_key](#input\_ssh\_bastion\_private\_key) | n/a | `string` | `null` | no |
| <a name="input_ssh_bastion_user"></a> [ssh\_bastion\_user](#input\_ssh\_bastion\_user) | n/a | `string` | `null` | no |
| <a name="input_ssh_timeout"></a> [ssh\_timeout](#input\_ssh\_timeout) | n/a | `string` | `"15s"` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | n/a | `string` | `"centos"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
