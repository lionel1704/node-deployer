#!/bin/bash

## This script registers the remote machines in the `known_hosts`

while IFS= read -r ip
do
  ssh-keyscan -H ${ip} >> ~/.ssh/known_hosts
done < ip_list
