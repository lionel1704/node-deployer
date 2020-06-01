#!/bin/bash

## This script starts a vault on a remote machine to join an existing section.
## It requires the connection information to be passed to it.

# Required arguments

# Vault data path
data_path=$1
# Hard coded contacts
hcc=$2
# Log level
log_level=$3

export RUST_LOG=safe=debug,qu=trace,routing=debug
export RUST_BACKTRACE=1
rm -rf ~/.cache/quic-p2p
rm -rf ~/.config/quic-p2p
cd /home/safe
if [ -d "$data_path" ]; then 
    rm -rf $data_path/*; # Remove this line to preserve vault data
else
    mkdir ${data_path}
fi
nohup ./safe_vault ${log_level} --root-dir=${data_path} --hard-coded-contacts ${hcc} &> ${data_path}/vault.stdout &