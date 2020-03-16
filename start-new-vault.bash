#!/bin/bash

## This script starts a vault on a remote machine to join an existing section.
## It requires the connection information to be passed to it.

# Required arguments

# IP address of the remote machine
ip=$1
# Vault data path
data_path=$2
# Hard coded contacts
hcc=$3
# Log level
log_level=$4

export RUST_LOG=safe=debug,qu=trace,routing=debug
export RUST_BACKTRACE=1
cd /home/safe
if [ -d "$data_path" ]; then 
    rm -rf $data_path/*; # Remove this line to preserve vault data
else
    mkdir ${data_path}
fi
nohup heaptrack ./safe_vault ${log_level} --ip ${ip} --root-dir=${data_path} --hard-coded-contacts ${hcc} &> ${data_path}/vault.stdout &