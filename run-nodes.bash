#!/bin/bash

## Currently, this script runs nodes on localhost (since that's the default if no IP address is given to the nodes)
## for the purposes of testing

# ****************************** The following can be modified as needed **********************************************

# 0 => No user interaction. The script will use the values set in the config variable below or defaults in some cases.
# 1 => User interaction turned on. The script will ask the values from the user in an interactive fashion.
INTERACTIVE=0;

# ------ Config options: Modify these to change the defaults and specially if using the non-interactive mode ------
# 0 => No debug output from the script.
# 1 => Debug output from the script.
DEBUG=1;
# Interval in seconds between starting of the nodes.
INTERVAL_BETWEEN_NODES=5;
# The directory containing the output directories for all the nodes started by this script.
NODES_GRP_DIR="./nodes";
# Number of nodes to spawn with the first one being the genesis. This number should be greater than 0.
NUM_NODES=10;
# Path to the node executable file. This should include the file name too, not just the path to the directory as no
# assumption is made on the name of the executable (and hence must be provided by the user).
NODE_EXE="./sn_node";
# Vebosity level for node logs.
# <blank> => log error.
# -v      => log error, warn.
# -vv     => log error, warn, info.
# -vvv    => log error, warn, info, debug.
# -vvvv   => log error, warn, info, debug, trace.
NODE_LOGGING_VERBOSITY="-vvvv";

export RUST_LOG=safe=trace,routing=debug
killall sn_node
rm -rf nodes

# *********************************************************************************************************************
# *********************************************************************************************************************

if [[ ${INTERACTIVE} != 0 ]]; then
    read -p "Group directory for all nodes [default = ${NODES_GRP_DIR}]: " NODES_GRP_DIR_INPUT;
    if [[ "${NODES_GRP_DIR_INPUT}" != "" ]]; then
        NODES_GRP_DIR="${NODES_GRP_DIR_INPUT}";
    fi
fi
mkdir -p "${NODES_GRP_DIR}";

regex_check_num='^[0-9]+$';
if [[ ${INTERACTIVE} != 0 ]]; then
    read -p "Total number of nodes to run [default = ${NUM_NODES}]: " NUM_NODES_INPUT;
    if [[ "${NUM_NODES_INPUT}" != "" ]]; then
        NUM_NODES="${NUM_NODES_INPUT}";
    fi
fi

if [[ ! ${NUM_NODES} =~ ${regex_check_num} ]]; then
    printf 'ERROR: Unable to parse the number of nodes to run as a number.\n';
    exit 1;
fi
if [[ ${NUM_NODES} < 1 ]]; then
    printf 'No nodes to run.\n'
    exit 0;
fi

regex_check_verbosity='^-v{,4}$';
if [[ ${INTERACTIVE} != 0 ]]; then
    read -p 'Node logging verbosity [check config section of this script for description]: ' NODE_LOGGING_VERBOSITY;
    if [[ "${NODE_LOGGING_VERBOSITY}" != "" && ! "${NODE_LOGGING_VERBOSITY}" =~ ${regex_check_verbosity} ]]; then
        printf 'ERROR: Invalid verbosity specified. It must be either left blank or one of -v, -vv, -vvv or -vvvv.\n';
        exit 1;
    fi
fi

if [[ ${INTERACTIVE} != 0 ]]; then
    read -p "Full path to sn_node executable [default = ${NODE_EXE}]: " NODE_EXE_INPUT;
    if [[ "${NODE_EXE_INPUT}" != "" ]]; then
        NODE_EXE="${NODE_EXE_INPUT}";
    fi
fi

if [[ ! -f "${NODE_EXE}" ]]; then
    printf 'ERROR: The given path does not correspond to a node executable: %s\n' "${NODE_EXE}";
    exit 1;
fi

if [[ ${DEBUG} != 0 ]]; then
    printf 'Running genesis node: %s\n' "${NODE_EXE}";
fi

root_dir="${NODES_GRP_DIR}"/sn-node-genesis;
mkdir -p "${root_dir}";
nohup "${NODE_EXE}" "${NODE_LOGGING_VERBOSITY}" --first --local --root-dir="${root_dir}" &> "${root_dir}"/node.stdout &

if [[ ${DEBUG} != 0 ]]; then
    printf 'Waiting for genesis node to start up...\n';
fi
sleep 2;

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    hcc="$(cat ~/.config/sn_node/node_connection_info.config)";
elif [[ "$OSTYPE" == "darwin"* ]]; then
    username="$(id -un)"
    hcc="$(cat /Users/${username}/Library/Preferences/net.maidsafe.sn_node/node_connection_info.config)";
fi

#Convert it into an array
hcc="[${hcc}]";

if [[ ${DEBUG} != 0 ]]; then
    printf 'Genesis node started with connection-info: %s\n' "${hcc}";
    printf 'Genesis node process id: %d\n' $!;
fi

for((i=2; i <= ${NUM_NODES}; ++i)); do
    if [[ ${DEBUG} != 0 ]]; then
        printf '\nRunning node number: %d in... ' ${i};
    fi
    for((j=${INTERVAL_BETWEEN_NODES}; j > 0; --j)); do
        if [[ ${DEBUG} != 0 ]]; then
            printf '%d ' ${j};
        fi
        sleep 1;
    done
    root_dir="${NODES_GRP_DIR}"/sn-node-${i};
    mkdir -p "${root_dir}";
    nohup "${NODE_EXE}" "${NODE_LOGGING_VERBOSITY}" --local --root-dir="${root_dir}" --hard-coded-contacts="${hcc}" &> "${root_dir}"/node.stdout &
    if [[ ${DEBUG} != 0 ]]; then
        printf '\nNode number: %d has been started.' ${i};
        printf '\nNode %d process id: %d\n' ${i} $!;
    fi
done

if [[ ${DEBUG} != 0 ]]; then
    printf '\n\nDone!\n';
fi
