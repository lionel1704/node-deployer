#!/bin/bash

## This script copies the node binary to a remote machine and starts a genesis node.
## It prints out the required connection information.

# Required arguments

# IP address of the remote machine
ip=$1
# Node data path
data_path=$2
# Log level
log_level=$3

cd /home/safe
rm -rf ~/.cache/quic-p2p
rm -rf ~/.config/quic-p2p
export RUST_LOG=safe=trace,qu=trace,routing=debug
export RUST_BACKTRACE=1
if [ -d "$data_path" ]; then 
    rm -rf $data_path/*; # Remove this line to preserve node data
else
    mkdir ${data_path}
fi
echo "" > ~/.config/sn_node/node_connection_info.config
nohup ./sn_node ${log_level} --first --ip ${ip} --root-dir "${data_path}" &> "${data_path}"/node.stdout &
sleep 5;

hcc="$(cat ~/.config/sn_node/node_connection_info.config)";

if [[ ${hcc} == "" ]]; then
    printf 'Genesis node did not print its connection info or printed it in an unrecognised format\n.';
    exit 1;
fi
echo $hcc
