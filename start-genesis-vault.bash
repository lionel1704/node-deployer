#!/bin/bash

## This script copies the vault binary to a remote machine and starts a genesis vault.
## It prints out the required connection information.

# Required arguments

# IP address of the remote machine
ip=$1
# Vault data path
data_path=$2
# Log level
log_level=$3

cd /home/safe
export RUST_LOG=safe=debug,qu=debug,routing=debug
export RUST_BACKTRACE=1
if [ -d "$data_path" ]; then 
    rm -rf $data_path/*; # Remove this line to preserve vault data
else
    mkdir ${data_path}
fi
echo "" > ~/.config/safe_vault/vault_connection_info.config
nohup ./safe_vault ${log_level} --first --ip ${ip} --root-dir "${data_path}" &> "${data_path}"/vault.stdout &
sleep 2;

hcc="$(cat ~/.config/safe_vault/vault_connection_info.config)";

if [[ ${hcc} == "" ]]; then
    printf 'Genesis vault did not print its connection info or printed it in an unrecognised format\n.';
    exit 1;
fi
echo $hcc
