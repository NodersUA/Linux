#!/bin/bash

tee ~/.ssh/config > /dev/null <<EOF
Host *
  StrictHostKeyChecking accept-new
EOF

chmod 600 ~/.ssh/id_rsa
