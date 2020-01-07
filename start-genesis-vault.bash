#!/bin/bash

## This script copies the vault binary to a remote machine and starts a genesis vault.
## It prints out the required connection information.

# Required arguments

# IP address of the remote machine
ip=$1
# Vault data path
data_path=$2

cd /home/safe
export RUST_LOG=routing=info
if [ -d "$data_path" ]; then 
    rm -rf $data_path/*; # Remove this line to preserve vault data
else
    mkdir ${data_path}
fi
nohup ./safe_vault --first --ip ${ip} --root-dir "${data_path}" &> "${data_path}"/vault.stdout &
sleep 2;

hcc="$(grep "peer_addr" "${data_path}"/vault.stdout)";
if [[ ${hcc} == "" ]]; then
    printf 'Genesis vault did not print its connection info or printed it in an unrecognised format\n.';
    exit 1;
else
    #Convert it into an array
    hcc="[${hcc}]";
fi
echo $hcc
