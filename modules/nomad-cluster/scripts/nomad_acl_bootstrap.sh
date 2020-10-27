#!/bin/bash
set -e

while ! curl --output /dev/null --silent --fail  http://localhost:4646/v1/status/leader; do   
  sleep 5s
done
nomad acl bootstrap | awk '(/Secret/ || /Accessor/)'| sudo tee /root/nomad_tokens && \
sleep 5s
export `sudo sh /root/vault.vars` && \
sudo tee nomad-anon.hcl <<EOT
namespace "*" {
  policy       = "write"
  capabilities = ["alloc-node-exec"]
}

agent {
  policy = "write"
}

operator {
  policy = "write"
}

quota {
  policy = "write"
}

node {
  policy = "write"
}

host_volume "*" {
  policy = "write"
}
EOT
export NOMAD_TOKEN="`sudo cat /root/nomad_tokens | awk '/Secret/{print $4}'`" && \
nomad acl policy apply -description "Anonymous policy (full-access)" anonymous nomad-anon.hcl && \
{ [ -z "`sudo cat /root/nomad_tokens | awk '/Secret/{print $2}'`" ] ||
  vault kv put secret/nomad/bootstrap_token secretid="`sudo cat /root/nomad_tokens | awk '/Secret/{print $4}'`" accessorid="`sudo cat /root/nomad_tokens | awk '/Access/{print $4}'`" && \
  vault write nomad/config/access address=http://127.0.0.1:4646 token="`sudo cat /root/nomad_tokens | awk '/Secret/{print $4}'`" && \
  vault write nomad/role/token-manager type=management global=true
} && \
sudo rm -f /root/nomad_tokens nomad-anon.hcl
