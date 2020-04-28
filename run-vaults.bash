#!/bin/bash

## Currently, this script runs vaults on localhost (since that's the default if no IP address is given to the vaults)
## for the purposes of testing

# ****************************** The following can be modified as needed **********************************************

# 0 => No user interaction. The script will use the values set in the config variable below or defaults in some cases.
# 1 => User interaction turned on. The script will ask the values from the user in an interactive fashion.
INTERACTIVE=0;

# ------ Config options: Modify these to change the defaults and specially if using the non-interactive mode ------
# 0 => No debug output from the script.
# 1 => Debug output from the script.
DEBUG=1;
# Interval in seconds between starting of the vaults.
INTERVAL_BETWEEN_VAULTS=5;
# The directory containing the output directories for all the vaults started by this script.
VAULTS_GRP_DIR="./vaults";
# Number of vaults to spawn with the first one being the genesis. This number should be greater than 0.
NUM_VAULTS=10;
# Path to the vault executable file. This should include the file name too, not just the path to the directory as no
# assumption is made on the name of the executable (and hence must be provided by the user).
VAULT_EXE="./safe_vault";
# Vebosity level for vault logs.
# <blank> => log error.
# -v      => log error, warn.
# -vv     => log error, warn, info.
# -vvv    => log error, warn, info, debug.
# -vvvv   => log error, warn, info, debug, trace.
VAULT_LOGGING_VERBOSITY="-vvvv";

export RUST_LOG=safe=debug,qu=trace,routing=debug

# *********************************************************************************************************************
# *********************************************************************************************************************

if [[ ${INTERACTIVE} != 0 ]]; then
    read -p "Group directory for all vaults [default = ${VAULTS_GRP_DIR}]: " VAULTS_GRP_DIR_INPUT;
    if [[ "${VAULTS_GRP_DIR_INPUT}" != "" ]]; then
        VAULTS_GRP_DIR="${VAULTS_GRP_DIR_INPUT}";
    fi
fi
mkdir -p "${VAULTS_GRP_DIR}";

regex_check_num='^[0-9]+$';
if [[ ${INTERACTIVE} != 0 ]]; then
    read -p "Total number of vaults to run [default = ${NUM_VAULTS}]: " NUM_VAULTS_INPUT;
    if [[ "${NUM_VAULTS_INPUT}" != "" ]]; then
        NUM_VAULTS="${NUM_VAULTS_INPUT}";
    fi
fi

if [[ ! ${NUM_VAULTS} =~ ${regex_check_num} ]]; then
    printf 'ERROR: Unable to parse the number of vaults to run as a number.\n';
    exit 1;
fi
if [[ ${NUM_VAULTS} < 1 ]]; then
    printf 'No vaults to run.\n'
    exit 0;
fi

regex_check_verbosity='^-v{,4}$';
if [[ ${INTERACTIVE} != 0 ]]; then
    read -p 'Vault logging verbosity [check config section of this script for description]: ' VAULT_LOGGING_VERBOSITY;
    if [[ "${VAULT_LOGGING_VERBOSITY}" != "" && ! "${VAULT_LOGGING_VERBOSITY}" =~ ${regex_check_verbosity} ]]; then
        printf 'ERROR: Invalid verbosity specified. It must be either left blank or one of -v, -vv, -vvv or -vvvv.\n';
        exit 1;
    fi
fi

if [[ ${INTERACTIVE} != 0 ]]; then
    read -p "Full path to safe_vault executable [default = ${VAULT_EXE}]: " VAULT_EXE_INPUT;
    if [[ "${VAULT_EXE_INPUT}" != "" ]]; then
        VAULT_EXE="${VAULT_EXE_INPUT}";
    fi
fi

if [[ ! -f "${VAULT_EXE}" ]]; then
    printf 'ERROR: The given path does not correspond to a vault executable: %s\n' "${VAULT_EXE}";
    exit 1;
fi

if [[ ${DEBUG} != 0 ]]; then
    printf 'Running genesis vault: %s\n' "${VAULT_EXE}";
fi

root_dir="${VAULTS_GRP_DIR}"/safe-vault-genesis;
mkdir -p "${root_dir}";
nohup "${VAULT_EXE}" "${VAULT_LOGGING_VERBOSITY}" --first --root-dir="${root_dir}" &> "${root_dir}"/vault.stdout &

if [[ ${DEBUG} != 0 ]]; then
    printf 'Waiting for genesis vault to start up...\n';
fi
sleep 2;

hcc="$(cat ~/.config/safe_vault/vault_connection_info.config)";
#Convert it into an array
hcc="[${hcc}]";

if [[ ${DEBUG} != 0 ]]; then
    printf 'Genesis vault started with connection-info: %s\n' "${hcc}";
fi

for((i=2; i <= ${NUM_VAULTS}; ++i)); do
    if [[ ${DEBUG} != 0 ]]; then
        printf '\nRunning vault number: %d in... ' ${i};
    fi
    for((j=${INTERVAL_BETWEEN_VAULTS}; j > 0; --j)); do
        if [[ ${DEBUG} != 0 ]]; then
            printf '%d ' ${j};
        fi
        sleep 1;
    done
    root_dir="${VAULTS_GRP_DIR}"/safe-vault-${i};
    mkdir -p "${root_dir}";
    nohup "${VAULT_EXE}" "${VAULT_LOGGING_VERBOSITY}" --root-dir="${root_dir}" --hard-coded-contacts="${hcc}" &> "${root_dir}"/vault.stdout &
    if [[ ${DEBUG} != 0 ]]; then
        printf '\nVault number: %d has been started.' ${i};
    fi
done

if [[ ${DEBUG} != 0 ]]; then
    printf '\n\nDone!\n';
fi
