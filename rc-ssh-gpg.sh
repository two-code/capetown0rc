unset SSH_AGENT_PID;
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket);
export GPG_TTY=$(tty);
gpg-connect-agent updatestartuptty /bye >/dev/null;
gpgconf --launch gpg-agent
