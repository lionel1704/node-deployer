cp vaults/safe-vault-genesis/vault.stdout vault-1.stdout
for i in {2..10}; do
    cp vaults/safe-vault-$i/vault.stdout vault-$i.stdout
done