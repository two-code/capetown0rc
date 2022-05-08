alias __ls='ls -alghF'
alias __ls-r='ls -alghFR1'
alias __lsf='ls -alghF'
alias __rm='rm -fRvd'

alias __dc-up-rebuild='docker-compose up --build -d --remove-orphans -V'
alias __dc-start='docker-compose start'
alias __dc='docker-compose'
alias __d-prune='docker system prune'

alias __sht='shutdown -P now'
alias __rbt='shutdown --reboot now'

alias mi='microk8s'
alias mikk='microk8s kubectl'
alias kk='kubectl'
alias k8='kubectl'

alias __go-vet='go mod tidy && go mod vendor && go vet ./...'

alias __ps='ps -eLfMlyZ kuid,pid --cumulative'

alias ww_lsblk='sudo lsblk --sort PARTLABEL -o NAME,SIZE,FSAVAIL,PHY-SEC,LOG-SEC,FSTYPE,TYPE,UUID,PARTUUID,PARTLABEL,MOUNTPOINT'
