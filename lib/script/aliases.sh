alias ww_ls='ls -alghF'
alias ww_lsr='ls -alghFR1'
alias ww_lsf='ls -alghF'
alias ww_rm='rm -fRvd'

alias ww_dc-up-rebuild='docker-compose up --build -d --remove-orphans -V'
alias ww_dc-start='docker-compose start'
alias ww_dc='docker-compose'
alias ww_d-prune='docker system prune'

alias ww_sht='shutdown -P now'
alias ww_rbt='shutdown --reboot now'

alias ww_mi='microk8s'
alias ww_mik='microk8s kubectl'
alias kk='kubecolor'

alias ww_go-vet='go mod tidy && go mod vendor && go vet ./...'

alias ww_ps='ps -eLfMlyZ kuid,pid --cumulative'

alias ww_lsblk='sudo lsblk --sort PARTLABEL -o NAME,PARTLABEL,LABEL,SIZE,FSAVAIL,PHY-SEC,LOG-SEC,FSTYPE,TYPE,UUID,PARTUUID,MOUNTPOINT'
alias ww_lsblk_short='sudo lsblk --sort PARTLABEL -o NAME,PARTLABEL,LABEL,SIZE,PARTUUID,MOUNTPOINT'

alias ww_vpn_up='sudo route add -net 192.168.3.0/24 gw 192.168.4.1 metric 2; sudo route add default gw 192.168.4.1 metric 2; nmcli c up cd/main-ovpn; c0rc_info "sleep for 5 secs ..."; sleep 5; sudo systemctl restart dnsmasq.service && c0rc_info "done"'
alias ww_vpn_down='nmcli c down cd/main-ovpn'

if [ "$(hostname)" = "capetown0" ]; then
    alias ww_cap2_home_mount='sshfs cap2:/home/vitalik /media/vitalik/cap2-home-vitalik && ll /media/vitalik/cap2-home-vitalik && c0rc_info done'
    alias ww_cap2_home_umount='sudo sync -f; sudo umount /media/vitalik/cap2-home-vitalik && c0rc_info done'
elif [ "$(hostname)" = "capetown2" ]; then
    alias ww_cap0_home_mount='sshfs cap0:/home/vitalik /media/vitalik/cap0-home-vitalik && ll /media/vitalik/cap0-home-vitalik && c0rc_info done'
    alias ww_cap0_home_mount_beeline='sshfs cap0_beeline:/home/vitalik /media/vitalik/cap0-home-vitalik && ll /media/vitalik/cap0-home-vitalik && c0rc_info done'
    alias ww_cap0_home_umount='sudo sync -f; sudo umount /media/vitalik/cap0-home-vitalik && c0rc_info done'
fi

if [ "$(hostname)" = "capetown0" ]; then
    alias ww_cap2_mount='sudo cryptsetup open "$(realpath /dev/disk/by-partlabel/cap2)" cap2 && sudo vgscan && sudo vgchange -ay && sudo mkdir -p /media/vitalik/cap2 && sudo chown vitalik:vitalik /media/vitalik/cap2 && sudo mount -t xfs /dev/capetown2/root /media/vitalik/cap2/ && c0rc_info "done"'
    alias ww_cap2_umount='sudo sync -f && sudo umount /media/vitalik/cap2 && sudo vgchange -an; sudo cryptsetup close cap2 && c0rc_info "done"'
fi
