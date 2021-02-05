#! /bin/bash

NODES=(
  %{ for node in nodes ~}
  ${node}
  %{ endfor ~}
)

HOST=${host}

echo "Is service up?"
while ! curl --output /dev/null --silent --fail  http://localhost:4646; do 
  sleep 5s
done
echo "yes.."

echo "Join nodes"
for n in $${NODES[@]}; do
  if [[ "$n" != "$HOST" ]];
  then
    /usr/local/bin/nomad server join $n
  fi
done
