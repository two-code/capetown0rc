ll
id
hostname
cat -n /etc/profile
source /etc/profile
clear
mount
nano
clear
nano /etc/fstab 
which echo
which cryptsetup
grub-install --target=x86_64-efi --efi-directory=/boot 
ll /boot
grub-install --target=x86_64-efi --efi-directory=/boot/efi
lsblk
mount /boot
mount -t vfat /dev/sdh1 /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi
update-grub
grub-mkconfig
update-grub
nano /etc/default/grub
source /etc/profile
clear
history
nano /etc/default/grub
lsblk -o NAME,UUID,MOUNTPOINT,FSTYPE
grub-install /dev/sdh1
file /boot/efi/EFI/kali/grubx64.efi 
stat /boot/efi/EFI/kali/grubx64.efi 
stat /boot/grub/grub.cfg 
ll /boot/grub
ll /boot/grub/x86_64-efi/
nano /etc/default/grub
stat /boot/grub/grub.cfg
update-grub
stat /boot/grub/grub.cfg
grub-mkconfig
stat /boot/grub/grub.cfg
grub-mkconfig -o /boot/grub/grub.cfg
stat /boot/grub/grub.cfg
nano /boot/grub/grub.cfg
nano /boot/grub/grub.cfg | grep lvmid
cat /boot/grub/grub.cfg | grep lvmid
cat /boot/grub/grub.cfg | grep IxtD
nano /boot/grub/grub.cfg
cat /boot/grub/grub.cfg | grep cryptomount
grub-install
exit
nano /boot/grub/grub.cfg 
exit
grub-install -V
exit
cat /etc/default/grub
grub-install -V
lsblk
exit
ll /
ll /boot
exit
mount /dev/sda1 /boot/efi
mkdir -pv /boot/efi
mount /dev/sda1 /boot/efi
lsblks
lsblk
grub-install -V
grub-install --bootloader-id=capetown2-0409
exit
mount -o remount,rw /sys/firmware/efi/efivars 
grub-install --bootloader-id=capetown2-0409
exit
whereis efibootmgr
grub-install --bootloader-id=capetown2-0409 --recheck
grub-install --bootloader-id=capetown2-0409 --recheck /dev/sda
update-grup
update-grub
stat /boot/grub/grub.cfg
nano /boot/grub/grub.cfg
stat /boot/grub/grub.cfg
grub-install --bootloader-id=capetown2-0409 --recheck /dev/sda1
grub-install --bootloader-id=capetown2-0409 --recheck /dev/sda
stat /boot/grub/grub.cfg
update-grub -o /boot/grub/grub.cfg 
stat /boot/grub/grub.cfg
nano /boot/grub/grub.cfg
exit
nano /etc/default/grub
ls /etc/default/grub.d/
cat /etc/default/grub.d/init-select.cfg 
grub-mkconfig -o /boot
ll /boot
mount
lsblk
mount /dev/mapper/main-boot /boot
grub-mkconfig
grub-install --bootloader-id=capetown2-0409 --recheck /dev/sda
grub-install --bootloader-id=capetown2-0409 --efi-directory=/boot/efi --recheck /dev/sda
grub-install --bootloader-id=capetown2-0409 --efi-directory=/boot/efi --recheck /dev/sda1
lsblk
grub-install --bootloader-id=capetown2-0409 --efi-directory=/boot/efi/EFI --recheck /dev/sda1
grub-install --bootloader-id=capetown2-0409 --efi-directory=/boot/efi --recheck /dev/sda1
umount /boot/efi
umount /boot
umount /boot/efi
mount /dev/mapper/main-boot /boot
lsblk
mount /dev/sda1 /boot/efi
lsblk
grub-install --bootloader-id=capetown2-0409 --recheck /dev/sda1
grub-install --bootloader-id=capetown2-0409 --recheck /dev/sda
update-grub
nano /boot/grub/grub.cfg
exit
grub-install -V
mount /dev/mapper/main-boot /boot
mount /dev/sda1 /boot/efi
lsblk
ls /boot/efi
ls /boot/efi/EFI
grub-install --bootloader-id=capetown2-00 --recheck --removable /dev/sda
exit
apt-get install -y grub-efi-amd64-signed
grub-glue-efi --help
exit
stat /boot/efi/EFI/capetown2-0409/grubx64.efi 
ls /boot/efi/EFI/capetown2-0409
stat /boot/efi/EFI/capetown2-0409/grubx64.efi 
grub-install --bootloader-id=capetown2-00 --recheck --removable /dev/sda
grub-install --bootloader-id=capetown2-00 --recheck --removable /dev/sda1
stat /boot/efi/EFI/BOOT/BOOTX64.EFI 
stat /boot/efi/EFI/BOOT/
grub-install --bootloader-id=capetown2-00 --recheck /dev/sda1
grub-install --bootloader-id=capetown2-00 --recheck --removable /dev/sda
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1
ll /lib/grub/x86_64-efi/
exit
nano /etc/default/grub
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1 >/grub-install.log
cat /grub-install.log 
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1 &1>/grub-install.log
cat /grub-install.log 
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1 >/grub-install.log
cat /grub-install.log 
nano /etc/default/grub
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1
clear
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1
stat /boot/efi/EFI/BOOT/BOOTX64.EFI 
nano /etc/default/grub
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1
stat /boot/efi/EFI/BOOT/BOOTX64.EFI 
update-grub
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1
stat /boot/efi/EFI/BOOT/BOOTX64.EFI 
nano /etc/default/grub
grub-mkconfig 
grub-mkconfig | grep crypt
nano /etc/default/grub
grub-mkconfig | grep crypt
nano /etc/default/grub
grub-mkconfig | grep crypt
grub-install --bootloader-id=capetown2-00 --recheck -v --removable /dev/sda1
grub-install --bootloader-id=capetown2-00 --recheck --removable /dev/sda1
grub-mkimage  --help
grub-mkimage 
grub-mkimage -c /boot/grub/grub.cfg 
grub-mkimage  --help
grub-mkimage -c=/boot/grub/grub.cfg 
grub-mkimage -c=/boot/grub/grub.cfg --format=x86_64-efi
grub-mkimage -c=/boot/grub/grub.cfg --format=x86_64-efi -p=/boot
grub-mkimage --format=x86_64-efi -p=/boot
grub-mkimage  --help
grub-mkimage --format=x86_64-efi -p=/boot -o=/grum-image.img
grub-mkimage --format=x86_64-efi -p=/boot --output=/grub-image.img
stat /grub-image.img 
grub-mkimage --format=x86_64-efi -p=/boot --output=/grub-image.img --config=/boot/grub/grub.cfg 
stat /grub-image.img 
stat /boot/efi/EFI/capetown2-00/grubx64.efi 
grep -E 'crypto' /boot/efi/EFI/capetown2-00/grubx64.efi 
grep -E 'crypto' /grub-image.img 
file /grub-image.img 
file /boot/efi/EFI/capetown2-00/grubx64.efi 
nano /boot/grub/grub.cfg
grub-mkconfig -o /grub-cfg.cfg
nano /grub-cfg.cfg
cp /grub-cfg.cfg /boot/grub/grub.cfg 
grub-install --bootloader-id=capetown2-00 --recheck --removable /dev/sda1
grub-install --bootloader-id=capetown2-00 --recheck /dev/sda1
grub-reboot --help
grub-mkpasswd-pbkdf2  --help
stat /boot/efi/EFI/kali/grubx64.efi
stat /boot/efi/EFI/capetown2-00/grubx64.efi 
nano /grub-cfg.cfg 
nano /etc/grub.d/00_header 
nano /etc/grub.d/10_linux 
grep -E 'crypt' /etc/grub.d/* 
grep -E 'grub' /etc/grub.d/* 
grep -E 'luks' /etc/grub.d/* 
exit
fdisk -l
mount /dev/sdf2 /boot
mount /dev/mapper/main-boot /boot
mount /dev/sdf1 /boot/efi
lsblk
grub-install /dev/sdf

grub-install --bootloader-id=capetown2-00 --recheck /dev/sdf1
nano /boot/grub/grub.cfg 
grub-install --bootloader-id=cap2 --recheck /dev/sdf1
cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
update-grub
diff /boot/grub/grub.cfg /boot/grub/grub.cfg.bak 
diff /boot/grub/grub.cfg.bak /boot/grub/grub.cfg
whereis efibootmgr
mount | grep evivars
exit
mount
mount | grep efi
exit
ll
grub-install -V
nano /etc/default/grub
lsblk 
lsblk -o NAME,UUID,LABEL
lsblk -o NAME,UUID,LABEL,FSTYPE,SIZE
lsblk -o NAME,UUID,LABEL,FSTYPE,SIZE,MOUNTPOINT
clear
lsblk -o NAME,UUID,LABEL,FSTYPE,SIZE,MOUNTPOINT
mount /dev/mapper/main-boot /boot
lsblk -o NAME,UUID,LABEL,FSTYPE,SIZE,MOUNTPOINT
mount /dev/sda2 /boot/efi
mount /dev/sda1 /boot/efi
lsblk -o NAME,UUID,LABEL,FSTYPE,SIZE,MOUNTPOINT
ll /boot/efi
ll /boot/efi/EFI
rm fvdr /boot/efi/EFI/*
rm -fvdr /boot/efi/EFI/*
ll /boot/efi/EFI
lsblk -o NAME,UUID,LABEL,FSTYPE,SIZE,MOUNTPOINT
lsblk -o NAME,UUID,LABEL,FSTYPE,SIZE,MOUNTPOINT,PARTLABEL
mount
apt-get install -y grub-efi-amd64
nano /etc/default/grub
grub-install --target=x86_64-efi --uefi-secure-boot --efi-directory=/boot/efi --bootloader=cap2 --boot-directory=/boot/efi/EFI/cap2 --recheck /dev/sda
stat /boot/efi/EFI/cap2/grubx64.efi 
ls /boot/efi/EFI/cap2/grub
ls /boot/efi/EFI/cap2/grub/x86_64-efi/
grub-mkconfig -o /boot/efi/EFI/cap2/grub/grub.cfg
nano /boot/efi/EFI/cap2/grub/grub.cfg
nano /etc/default/grub
grub-mkconfig -o /boot/efi/EFI/cap2/grub/grub.cfg
nano /boot/efi/EFI/cap2/grub/grub.cfg
grub-mkimage --help
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi luks luks2 part_gpt crypto cryptodisk gcry_rijndael pbkdf2 gcry_sha256 ext2 all_video lvm
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi luks part_gpt crypto cryptodisk gcry_rijndael pbkdf2 gcry_sha256 ext2 all_video lvm
nano /boot/efi/EFI/cap2/grub/grub.cfg
nano /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/(insmod\s[a-z0-9_])/\1/'
/boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/(insmod\s[a-z0-9_])/\1/'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/(insmod\s[a-z0-9_])/\1/'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/(insmod\s[a-z0-9_])/\1/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/^(insmod\s[a-z0-9_])/\1/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -r 's/^(insmod\s[a-z0-9_])/\1/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/^(insmod\s+[a-z0-9_]+)/\1/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -E 'insmod\s+[a-z0-9_]+'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/^insmod\s+[a-z0-9_]+/\1/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/^(insmod\s+[a-z0-9_]+)/aa/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/^(insmod\s+[a-z0-9_]+)/aa/'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/(insmod\s+[a-z0-9_]+)/aa/'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed 's/(insmod\s+[a-z0-9_]+)/aa/'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/(insmod\s+[a-z0-9_]+)\s/aa/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -E 's/(insmod)\s/aa/g'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E '/(insmod)\s/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E '/(insmod)\s//p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E '/(insmod)\s/\1/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E '/(insmod)\s/\1'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E '/(insmod)\s/'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E '/(insmod)\s/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E 's/(insmod)\s/\1/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E 's/(insmod)\s/aa\1/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E 's/(insmod\s[a-z0-9_)\s/\1/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E 's/(insmod\s[a-z0-9_)/\1/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | sed -n -E 's/(insmod\s+[a-z0-9_]+)/\1/p'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | column 
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 1
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 2-6
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 2-
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 4-
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 7-
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8-
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | uniq
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | tr -d \n
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq 
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | IFS= '' uniq 
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | IFS='' uniq 
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | readarray -t ARRAY
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | IFS=',' uniq 
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | readarray -t ARRAY 
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | tr -d '\n'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | tr '\n' ' '
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi all_video crypto cryptodisk efi_gop efi_uga ext2 gettext gfxmenu gfxterm gzio ieee1275_fb luks lvm lzopio part_gpt png vbe vga video_bochs video_cirrus xzio
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi all_video crypto cryptodisk efi_gop efi_uga ext2 gettext gfxmenu gfxterm gzio luks lvm lzopio part_gpt png vbe vga video_bochs video_cirrus xzio
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi all_video crypto cryptodisk efi_gop efi_uga ext2 gettext gfxmenu gfxterm gzio luks lvm lzopio part_gpt png vga video_bochs video_cirrus xzio
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi all_video crypto cryptodisk efi_gop efi_uga ext2 gettext gfxmenu gfxterm gzio luks lvm lzopio part_gpt png video_bochs video_cirrus xzio
man install
install -v /tmp/grubx64.efi /boot/efi/EFI/cap2/grubx64.efi 
cp -v /tmp/grubx64.efi /grubx64.efi.custom
stat /boot/efi/EFI/cap2/grubx64.efi 
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | tr '\n' ' '
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | xargs -I{} stat /boot/efi/EFI/cap2/grub/x86_64-efi/{}
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | xargs -I{} stat /boot/efi/EFI/cap2/grub/x86_64-efi/{}.mod
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'insmod\s+[a-z0-9_]+' | cut -c 8- | sort | uniq | xargs -I{} stat /boot/efi/EFI/cap2/grub/x86_64-efi/{}.mod | grep -o -E 'No such'
exit
lsblk
lsblk -o UUID
lsblk -o NAME,UUID
lsblk -o NAME,UUID,MOUNTPOINT
mount /dev/mapper/main-boot /boot
mount /dev/sda1 /boot/efi
stat /boot/efi/EFI/cap2/grubx64.efi 
cat /boot/efi/EFI/cap2/grub/grub.cfg
stat /boot/efi/EFI/cap2/grubx64.efi 
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi all_video crypto cryptodisk efi_gop efi_uga ext2 gettext gfxmenu gfxterm gzio luks lvm lzopio part_gpt png video_bochs video_cirrus xzio
install -v /tmp/grubx64.efi /boot/efi/EFI/cap2/grubx64.efi 
stat /boot/efi/EFI/cap2/grubx64.efi 
nano /boot/efi/EFI/cap2/grub/grub.cfg
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub.cfg -o /tmp/grubx64.efi all_video crypto cryptodisk efi_gop efi_uga ext2 gettext gfxmenu gfxterm gzio luks lvm lzopio part_gpt png video_bochs video_cirrus xzio
stat /boot/efi/EFI/cap2/grubx64.efi 
install -v /tmp/grubx64.efi /boot/efi/EFI/cap2/grubx64.efi 
stat /boot/efi/EFI/cap2/grubx64.efi 
exit
stat /boot/efi/EFI/cap2/grubx64.efi 
stat /boot/grub/grub.cfg 
lsblk /dev/sda
nano /boot/grub/grub.cfg 
cat /boot/grub/grub.cfg | grep -E 'menu'
cat /boot/grub/grub.cfg | grep -E 'menuentry'
cat /boot/grub/grub.cfg | grep -o -E 'menuentry'
cat /boot/grub/grub.cfg | grep -o -E 'menuentry.+'
clear
mkdir -p /main-boot
mount /dev/main/boot /main-boot
cat /main-boot/grub/grub.cfg | grep -o -E 'menuentry.+'
nano /main-boot/grub/grub.cfg
nano /boot/grub/grub.cfg
nano /main-boot/grub/grub.cfg
rm -fdvr /main-boot/*
clear
update-grub
nano /main-boot/grub/grub.cfg
nano /boot/grub/grub.cfg
ls /boot
ls /boot/efi
rm -fdvr /boot/*
ls /boot
clear
update-grub
mkdir /boot/grub
update-grub
nano /boot/grub/grub.cfg
nano /etc/default/grub
ls /main-boot
umount /main-boot
mkdir -p /boot/efi
mount /dev/sda1 /boot/efi
nano /boot/efi/EFI/cap2/grub/grub.cfg
man update-grub
nano /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry\s[A-Za-z0-9'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry\s[A-Za-z0-9]'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry\s[A-Za-z0-9]+'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry.+'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry \''
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry \'''
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry '''
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry ''K'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry.+K'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry.+Kali'
cat /boot/efi/EFI/cap2/grub/grub.cfg | grep -o -E 'menuentry.+'
clear
ls /
install -v /grubx64.efi.custom /boot/efi/EFI/cap2/grubx64.efi 
grub-install
ls /boot/grub
ls /boot/grub/x86_64-efi/
ls /boot/efi/
ls /boot/efi/EFI
ls /boot/efi/EFI/kali
stat /boot/efi/EFI/kali/grubx64.efi 
fsof /boot/efi/EFI/kali/grubx64.efi 
file /boot/efi/EFI/kali/grubx64.efi 
stat /boot/efi/EFI/kali/grubx64.efi 
lsblk -o NAME,MOUNTPOINT
rm -fdvr /boot/efi/EFI/kali
touch /boot/efi/EFI/cap2/grub/grub-custom-pre.cfg
nano /boot/efi/EFI/cap2/grub/grub-custom-pre.cfg 
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub-custom-pre.cfg -o /grubx64.efi.custom all_video crypto cryptodisk efi_gop efi_uga ext2 gettext gfxmenu gfxterm gzio luks lvm lzopio part_gpt png video_bochs video_cirrus xzio normal configfile search_fs_uuid
find / -name 'all_video*' -type f
ll /usr/lib/grub/x86_64-efi/
ll /usr/lib/grub/x86_64-efi/ | grep -o -E '[A-Za-z0-9_]\.mod$'
ll /usr/lib/grub/x86_64-efi/ | grep -o -E '[A-Za-z0-9_]+\.mod$'
ll /usr/lib/grub/x86_64-efi/ | grep -o -E '[A-Za-z0-9_]+\.mod$' | sed -E 's/([A-Za-z0-9_]+)\.mod/\1/'
ll /usr/lib/grub/x86_64-efi/ | grep -o -E '[A-Za-z0-9_]+\.mod$' | sed -E 's/([A-Za-z0-9_]+)\.mod/\1/' | sort | uniq | tr '\n' ' '
grub-mkimage -p /boot/grub -O x86_64-efi -c /boot/efi/EFI/cap2/grub/grub-custom-pre.cfg -o /grubx64.efi.custom acpi adler32 affs afs ahci all_video aout appleldr archelp ata at_keyboard backtrace bfs bitmap bitmap_scale blocklist boot bsd bswap_test btrfs bufio cat cbfs cbls cbmemc cbtable cbtime chain cmdline_cat_test cmp cmp_test configfile cpio cpio_be cpuid crc64 crypto cryptodisk cs5536 ctz_test date datehook datetime disk diskfilter div div_test dm_nv echo efifwsetup efi_gop efinet efi_uga ehci elf eval exfat exfctest ext2 extcmd f2fs fat file fixvideo font fshelp functional_test gcry_arcfour gcry_blowfish gcry_camellia gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_idea gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael gcry_rmd160 gcry_rsa gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger gcry_twofish gcry_whirlpool geli gettext gfxmenu gfxterm gfxterm_background gfxterm_menu gptsync gzio halt hashsum hdparm hello help hexdump hfs hfsplus hfspluscomp http iorw iso9660 jfs jpeg keylayouts keystatus ldm legacycfg legacy_password_test linux linux16 linuxefi loadbios loadenv loopback ls lsacpi lsefi lsefimmap lsefisystab lsmmap lspci lssal luks lvm lzopio macbless macho mdraid09 mdraid09_be mdraid1x memdisk memrw minicmd minix minix2 minix2_be minix3 minix3_be minix_be mmap morse mpi msdospart mul_test multiboot multiboot2 nativedisk net newc nilfs2 normal ntfs ntfscomp odc offsetio ohci part_acorn part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool password password_pbkdf2 pata pbkdf2 pbkdf2_test pcidump pgp play png priority_queue probe procfs progress raid5rec raid6rec random rdmsr read reboot regexp reiserfs relocator romfs scsi search search_fs_file search_fs_uuid search_label serial setjmp setjmp_test setpci sfs shift_test shim_lock signature_test sleep sleep_test spkmodem squash4 strtoull_test syslinuxcfg tar terminal terminfo test test_blockarg testload testspeed tftp tga time tpm tr trig true udf ufs1 ufs1_be ufs2 uhci usb usb_keyboard usbms usbserial_common usbserial_ftdi usbserial_pl2303 usbserial_usbdebug usbtest video video_bochs video_cirrus video_colors video_fb videoinfo videotest videotest_checksum wrmsr xfs xnu xnu_uuid xnu_uuid_test xzio zfs zfscrypt zfsinfo zstd
stat /grubx64.efi.custom 
install -v /grubx64.efi.custom /boot/efi/EFI/cap2/grubx64.efi 
exit
clear
lsblk
mount /dev/sdi1 /boot/efi
clear
lsblk
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --recheck
ls -a /boot/efi/EFI
ls -a /boot/efi/EFI/kali
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck
ls -a /boot/efi/EFI/cap2/
stat /boot/efi/EFI/cap2
rm -fdvr /boot/efi/EFI/kali
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules=cryptodisk,lvm
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules=cryptodisk lvm
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules="cryptodisk lvm"
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules="cryptodisk lvm crypto luks"
ls -a /boot/efi/EFI/cap2/
stat /boot/efi/EFI/cap2/grubx64.efi 
exit
clear
ll
mkdir -p grub-v2.06-arch
ping 192.168.3.1
cd grub-v2.06-arch
git clone https://aur.archlinux.org/grub-improved-luks2-git.git .
ll
ls -aL
ls -al
cat grub.default 
cat mm_1.patch 
ls -a
ll
ls -aL
ls -al
ls -alt
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules="cryptodisk lvm crypto luks luks2"
history | grep mount
lsblk
mount /dev/sdc1 /boot/efi
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules="cryptodisk lvm crypto luks luks2"
find / -iname 'luks2.mod' -type f
find / -iname '*luks2*' -type f
cat /grub-v2.06-arch/grub-improved-luks2-git.install
cd ..
ls -al
cd grub-from-source/
ls
ls -a
grub-install -V
curl -O ftp.gnu.org/gnu/grub/grub-2.06.tar.gz
wget
apt-get install -u curl
apt-get install -y curl
apt-get install -y 
history | grep apt
lsblk
apt-cache show -a curl
apt-cache show -a btrfs-progs
cat /etc/apt/sources.list
apt update
apt install -y curl
curl
curl -O ftp.gnu.org/gnu/grub/grub-2.06.tar.gz
apt install -y gcc
apt install -y make
ls /dev
curl -O ftp.gnu.org/gnu/grub/grub-2.06.tar.gz.sig
gpg --keyserver keyserver.ubuntu.com --receive-keys BE5C23209ACDDACEB20DB0A28C8189F1988C2166
ping keyserver.ubuntu.com
gpg --verify grub-2.06.tar.gz.sig
tar -xvzf grub-2.06.tar.gz
clear
cd grub-2.06/
clear
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats --enable-grub-themes
apt install -y bison
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats --enable-grub-themes
apt install -y flex gettext
apt install -y binutils
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats --enable-grub-themes
grub-mkfont --help
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats --enable-grub-themes
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats
apt install -y libfuse-dev 
apt install -y libfuse-dev libdevmapper-dev 
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats
apt -y install libfreetype-dev libfreetype6-dev
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats
apt -y install libfont-freetype-perl 
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats
apt -y install zfs-fuse zfs-dkmsm libzfs
apt -y install zfs-fuse zfs-dkmsm libzfslinux-dev libzfs4linux 
apt -y install zfs-fuse zfs-dkms libzfslinux-dev libzfs4linux 
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats
apt -y install  libfreetype-dev
lsblk
mkdir /cap1
mount /dev/sdb3 /cap1
cp -vLa /cap1/home/vitalik/workspace/_garbage/_downloads/DejaVu* /usr/share/fonts/truetype/
umount /cap1
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats --enable-grub-themes
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats
nproc
make -j8
make clean
./configure --help
whereis grub-install
whereis grub-mkimage
./configure --with-platform=efi --enable-grub-mount --enable-boot-time --enable-cache-stats --prefix=/usr
make -j8
make install
grub-install -V
grub-mkimage --help
grub-mkimage -V
history | grep grub
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules="cryptodisk lvm crypto luks luks2"
apt -y install efibootmgr 
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
grub-install --boot-directory=/boot/efi/EFI/cap2 --efi-directory=/boot/efi --bootloader-id=cap2  --recheck --modules="cryptodisk lvm crypto luks luks2"
history | grep stat
stat /boot/efi/EFI/cap2/grubx64.efi
exit
clear
lsblk
ll /boot
ll
update-initramfs -v -c -k all
cat -n /etc/fstab
update-initramfs -v -c
update-initramfs -k all -c
update-initramfs -k all -c -v
uname
uname 0a
uname -a
whereis mkinitcpio
find / -iname 'vmlinuz'
find / -iname '*vmlinuz*'
ll
file /boot/config-5.15.0-kali3-amd64 
cat -n /boot/config-5.15.0-kali3-amd64 
exit
