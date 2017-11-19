# Interactive shells
if [ "$PS1" ]; then
    cat /etc/motd
    export PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
fi
