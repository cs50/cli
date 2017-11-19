# Interactive shells
if [ "$PS1" ]; then

    cat /etc/motd

	cwdSlashAtEnd () {
		TITLE="$(dirs +0)"

		if [ -z "$1" ] ; then
			# no argument, full cwd
			TITLE="${TITLE%/}"
		else
			# one arg, basename only
			TITLE="${TITLE##*/}"
		fi

		echo -n "${TITLE}/"
	}

	PS1='\[$(printf "\x0f")\033[01;34m\]$(cwdSlashAtEnd)\[\033[00m\]$(__git_ps1 " (%s)") $ '

	case "$TERM" in
	xterm-*|rxvt*|screen*)
		PS1='\[\e]0;\a\033k$(cwdSlashAtEnd base)\033\\\]'"$PS1"
		;;
	*)
		;;
	esac

fi
