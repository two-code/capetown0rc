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
alias kk='kubectl'

alias ww_go-vet='go mod tidy && go mod vendor && go vet ./...'

alias ww_ps='ps -eLfMlyZ kuid,pid --cumulative'

alias ww_lsblk='sudo lsblk --sort PARTLABEL -o NAME,PARTLABEL,LABEL,SIZE,FSAVAIL,PHY-SEC,LOG-SEC,FSTYPE,TYPE,UUID,PARTUUID,MOUNTPOINT'
