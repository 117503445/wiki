# ArchLinux Swap

ref <https://wiki.archlinuxcn.org/wiki/Swap>

```sh
# not for Btrfs
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
chmod 0600 /swapfile
mkswap -U clear /swapfile
swapon /swapfile

echo "/swapfile none swap defaults 0 0" >> /etc/fstab
```
