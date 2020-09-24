cp nodes/sn-node-genesis/node.stdout node-1.stdout
for i in {2..10}; do
    cp nodes/sn-node-$i/node.stdout node-$i.stdout
done