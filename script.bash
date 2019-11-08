#!/bin/bash

DEBUG=1;

read -p 'Group directory for all vaults [default = ${PWD}/vaults]: ' vaults_group_dir;
if [[ ${vaults_group_dir} == "" ]]; then
    vaults_group_dir="./vaults";
fi
mkdir -p "${vaults_group_dir}";

regex_check_num='^[0-9]+$';
read -p "Total number of vaults to run: " num_vaults;
if [[ ! ${num_vaults} =~ ${regex_check_num} ]]; then
    printf 'ERROR: Not a number.\n';
    exit 1;
fi

if [[ ${num_vaults} -lt 1 ]]; then
    printf 'No vaults to run.\n'
    exit 0;
fi

read -p "Full path to safe_vault executable: " vault_exe;
if [[ ${vault_exe} == "" ]]; then
    vault_exe="./safe_vault";
fi

if [[ ${DEBUG} -ne 0 ]]; then
    printf 'Running genesis vault: %s\n' "${vault_exe}";
fi

root_dir="${vaults_group_dir}"/safe-vault-genesis;
mkdir -p "${root_dir}";
nohup "${vault_exe}" --root-dir="${root_dir}" &> "${root_dir}"/vault.stdout &

sleep 3;

hcc="$(grep "peer_addr" "${root_dir}"/vault.stdout)";
if [[ ${hcc} == "" ]]; then
    printf 'Genesis vault did not print its connection info or printed it in an unrecognised format\n.';
    exit 1;
else
    #Convert it into an array
    hcc="[${hcc}]";
fi

if [[ ${DEBUG} -ne 0 ]]; then
    printf 'Genesis connection-info: %s\n' "${hcc}";
fi

for((i=1; i < ${num_vaults}; ++i)); do
    if [[ ${DEBUG} -ne 0 ]]; then
        printf 'Running vault num: %d...\n' $((${i} + 1));
    fi
    root_dir="${vaults_group_dir}"/safe-vault-${i};
    mkdir -p "${root_dir}";
    nohup "${vault_exe}" --root-dir="${root_dir}" --hard-coded-contacts="${hcc}" &> "${root_dir}"/vault.stdout &
    if [[ ${i} -ne $((${num_vaults} - 1)) ]]; then
        sleep 10;
    fi
done
