# alias
alias cp="cp -i"
alias ll="ls -l --color=auto"
alias mv="mv -i"
alias pip="pip3"
alias python="python3"
alias rm="rm -i"

# environment
export EDITOR=nano

# interactive shells
if [ "$PS1" ]; then
    cat /etc/motd
    export PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
    eval "$(pyenv init -)"
    eval "$(rbenv init -)"
fi
