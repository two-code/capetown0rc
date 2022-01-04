#!/bin/zsh

set -o errexit
set -o nounset
set -o pipefail

echo "";
echo -e "${__color_yellow}===================================================${__color_none}";
echo -e "${__color_yellow}==== Unlocking ${__color_red}_docs${__color_yellow}:${__color_none}";
gocryptfs -rw -extpass "${__script_root}/__docs-passwd.sh" "${HOME}/workspace/_docs_secured" "${HOME}/workspace/_docs" && echo -en "${__color_yellow}done${__color_none}";

#  commented by vitalik 2021-10-31T18:46
# echo "";
# echo -e "${__color_yellow}===================================================${__color_none}";
# echo -e "${__color_yellow}==== Unlocking ${__color_red}@especial${__color_yellow}:${__color_none}";
# gocryptfs -rw "${HOME}/workspace/_media/_videos/@especial_secured" "${HOME}/workspace/_media/_videos/@especial" && echo -e "${__color_yellow}done!${__color_none}";


# echo "";
# echo -e "${__color_yellow}===================================================${__color_none}";
# echo -e "${__color_yellow}==== Unlocking ${__color_red}storage-z-backup-vault${__color_yellow}:${__color_none}";
# Setup:
# mkdir -pv /mnt/storage-z-backup && chown vitalik:vitalik /mnt/storage-z-backup && chmod a+r /mnt/storage-z-backup;
# mkdir -pv /mnt/storage-z-backup-vault && chown vitalik:vitalik /mnt/storage-z-backup-vault && chmod a+r /mnt/storage-z-backup-vault;
# sudo mount.cifs //192.168.3.1/storage-z/_backup /mnt/storage-z-backup -o user=vitalik,password=,noperm,rw,nodev,noexec,nosuid,uid=vitalik,forceuid,gid=vitalik,forcegid,guest,cache=strict,soft;
# sudo dd if=/dev/zero of=/mnt/storage-z-backup/vault.img bs=1 count=0 seek=54G;
# sudo cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --iter-time 4000 --label storage-z-backup-vault --key-size 512 --pbkdf argon2i --use-urandom --verify-passphrase --sector-size 4096 luksFormat /mnt/storage-z-backup/vault.img;
# sudo losetup /dev/loop1000 /mnt/storage-z-backup/vault.img;
# sudo cryptsetup luksOpen --allow-discards /dev/loop1000 storage-z-backup-vault;
# sudo mkfs.btrfs -s 4096 /dev/mapper/storage-z-backup-vault;
# sudo mount -t btrfs -o noacl,discard,clear_cache,compress-force=zstd:15,x-gvfs-show,x-gvfs-name=bck-vault /dev/mapper/storage-z-backup-vault /mnt/storage-z-backup-vault;
# sudo chown vitalik:vitalik /mnt/storage-z-backup-vault;
# sudo chmod a+r /mnt/storage-z-backup-vault;

# sudo mount.cifs //192.168.3.1/storage-z/_backup2 /mnt/storage-z-backup -o user=vitalik,password=,noperm,rw,nodev,noexec,nosuid,uid=vitalik,forceuid,gid=vitalik,forcegid,guest,cache=strict,soft;
# sudo losetup /dev/loop1000 /mnt/storage-z-backup/vault.img
# sudo cryptsetup luksOpen --allow-discards /dev/loop1000 storage-z-backup-vault;
# sudo cryptsetup luksDump /dev/loop1000;
# sudo cryptsetup luksUUID /dev/loop1000;
# sudo mount -t btrfs -o noacl,discard,clear_cache,compress-force=zstd:15,x-gvfs-show,x-gvfs-name=bck-vault /dev/mapper/storage-z-backup-vault /mnt/storage-z-backup-vault && echo -e "${__color_yellow}Done!${__color_none}";

echo "";


