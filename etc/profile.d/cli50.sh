# alias
alias cp="cp -i"
alias ll="ls -l --color=auto"
alias mv="mv -i"
alias pip="pip3"
alias python="python3"
alias rm="rm -i"

# EDITOR
export EDITOR=nano

# PS1
if [ "$PS1" ]; then
    cat /etc/motd
    export PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
fi
