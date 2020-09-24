#!/bin/bash

count=0
while IFS= read -r ip
do
  scp root@${ip}:/home/safe/node_data/node.stdout node-${count}.log
  let "count+=1"
done < ip_list