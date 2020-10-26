#!/bin/bash
set -e

while ! curl --output /dev/null --silent --head --fail http://localhost:4646; do   
  sleep 5s
done
nomad acl bootstrap
awk '(/Secret/ || /Accessor/)'| sudo tee /root/nomad_tokens && \
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
export NOMAD_TOKEN="`sudo cat /root/nomad_tokens | awk '/Secret/{print $2}'`" && \
nomad acl policy apply -description "Anonymous policy (full-access)" anonymous nomad-anon.hcl && \
{ [ -z "`sudo cat /root/nomad_tokens | awk '/Secret/{print $2}'`" ] ||
  vault kv put secret/nomad/bootstrap_token secretid="`sudo cat /root/nomad_tokens | awk '/Secret/{print $2}'`" accessorid="`sudo cat /root/nomad_tokens | awk '/Access/{print $2}'`"
} && \
sudo rm -f /root/nomad_tokens nomad-anon.hcl