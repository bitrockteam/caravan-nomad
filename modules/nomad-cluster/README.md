# Nomad Cluster module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| null | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_nodes | A map in form of 'node-name' => 'node's private IP' of the nodes to provision the cluster on | `map(any)` | n/a | yes |
| cluster\_nodes\_ids | list of strings which are IDs of the instance resources and are used to `trigger` the provisioning of `null` resources on instance recreation | `list(string)` | n/a | yes |
| cluster\_nodes\_public\_ips | The public IPs of the node to SSH into them | `map(any)` | `null` | no |
| control\_plane\_vault\_role | n/a | `string` | `null` | no |
| dc\_name | Name of the datacenter of the consul cluster | `string` | n/a | yes |
| nomad\_home | The directory where the consul's data is kept on the nodes | `string` | `"/var/lib/nomad"` | no |
| ssh\_bastion\_host | n/a | `string` | `null` | no |
| ssh\_bastion\_port | n/a | `string` | `"22"` | no |
| ssh\_bastion\_private\_key | n/a | `string` | `null` | no |
| ssh\_bastion\_user | n/a | `string` | `null` | no |
| ssh\_private\_key | n/a | `string` | n/a | yes |
| ssh\_timeout | n/a | `string` | `"15s"` | no |
| ssh\_user | n/a | `string` | `"centos"` | no |

## Outputs

No output.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
