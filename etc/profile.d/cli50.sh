# alias
alias cp="cp -i"
alias ll="ls -l --color=auto"
alias mv="mv -i"
alias rm="rm -i"

# EDITOR
export EDITOR=nano

# PS1
if [ "$PS1" ]; then
    cat /etc/motd
    #export PS1='\[$(printf "\x0f")\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)") $ '
fi
