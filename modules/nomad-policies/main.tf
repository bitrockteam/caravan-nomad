resource "nomad_acl_policy" "nomad_anon" {
  name        = "nomad_anon_restricted"
  description = "Submit jobs to the nomad_anon environment. Restricted version."
  rules_hcl   = file("${path.module}/acls/nomad-anon-restricted.hcl")
}

resource "nomad_acl_policy" "nomad_ops" {
  name        = "nomad_ops"
  description = "Operations people policy"
  rules_hcl   = file("${path.module}/acls/nomad-ops.hcl")
}

resource "nomad_acl_policy" "nomad_app_devs" {
  name        = "nomad_app_devs"
  description = "Application developers policy"
  rules_hcl   = file("${path.module}/acls/nomad-app-devs.hcl")
}
