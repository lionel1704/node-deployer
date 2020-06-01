
printf 'Chunk count in all vault-*/chunks/immutable dirs (including used_space file)\n';

for d in vaults/*; do
  if [ -d "$d" ]; then
    echo "$d : $(ls -1q $d/chunks/immutable | wc -l)" 
  fi
done
