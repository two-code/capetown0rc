alias _ls='ls -alghF'
alias _ls-r='ls -alghFR1'
alias _lsf='ls -alghF'
alias _cd-iw='cd ~/workspace/dev/_iw'
alias _cd-iw-stand='cd ~/workspace/dev/_iw/dome-stand'
alias _rm='rm -fRvd'

alias _dc-up-rebuild='docker-compose up --build -d --remove-orphans -V'
alias _dc-start='docker-compose start'
alias _dc='docker-compose'

alias _sht='shutdown -P now'
alias _rbt='shutdown --reboot now'

alias _m8='microk8s'
alias _m8kctl='microk8s kubectl'
alias _kctl='kubectl'
alias _k8='kubectl'

alias _go-vet='go mod tidy && go mod vendor && go vet ./...'

alias _srch='{ cat ~/.zsh_history; cat /root/.zsh_history; } | uniq -iu | grep -E $1'

alias _ps='ps -eLfMlyZ kuid,pid --cumulative'

PATH="${PATH}:${HOME}/go/bin"
