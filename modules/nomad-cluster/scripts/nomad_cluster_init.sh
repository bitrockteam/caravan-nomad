#!/bin/bash
set -e
sudo ls -la /etc/nomad.d/ && \
sudo systemctl start nomad &&  \
sleep 10s && \
systemctl status nomad
