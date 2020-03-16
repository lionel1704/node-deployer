#!/bin/bash

count=0
while IFS= read -r ip
do
  scp root@${ip}:/home/safe/vault_data/vault.stdout vault-${count}.log
  let "count+=1"
done < ip_list