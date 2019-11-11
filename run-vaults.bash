#!/bin/bash

## Currently, this script runs vaults on localhost (since that's the default if no IP address is given to the vaults)
## for the purposes of testing

DEBUG=1;
INTERVAL_BETWEEN_VAULTS=5;

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

if [[ ${DEBUG} -ne 0 ]]; then
    printf 'Waiting for genesis vault to start up...\n';
fi
sleep 2;

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

for((i=2; i <= ${num_vaults}; ++i)); do
    if [[ ${DEBUG} -ne 0 ]]; then
        printf '\nRunning vault number: %d in... ' ${i};
    fi
    for((j=${INTERVAL_BETWEEN_VAULTS}; j > 0; --j)); do
        if [[ ${DEBUG} -ne 0 ]]; then
            printf '%d ' ${j};
        fi
        sleep 1;
    done
    root_dir="${vaults_group_dir}"/safe-vault-${i};
    mkdir -p "${root_dir}";
    nohup "${vault_exe}" --root-dir="${root_dir}" --hard-coded-contacts="${hcc}" &> "${root_dir}"/vault.stdout &
    if [[ ${DEBUG} -ne 0 ]]; then
        printf '\nVault number: %d has been started.' ${i};
    fi
done

if [[ ${DEBUG} -ne 0 ]]; then
    printf '\n\nDone!\n';
fi
