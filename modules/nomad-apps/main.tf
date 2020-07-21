provider "nomad" {
  address = "http://${var.nomad_endpoint}:4646"
  region  = "us-east-2"
}

resource "nomad_job" "jaeger" {
  jobspec = file("${path.module}/files/jaeger.hcl")
}