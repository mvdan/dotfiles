command_test() {
	command -v $1 >/dev/null 2>&1
}

bashcomp() {
	for f in "$@"; do
		source "$f"
	done
}

source ~/.shrc

bhelp () {
	help "$@"
}

set -o vi

PR_RED="\e[31m"
PR_GREEN="\e[32m"
PR_YELLOW="\e[33m"
PR_BLUE="\e[34m"
PR_CYAN="\e[36m"
PR_NONE="\e[39m"

if [[ $UID -ge 1000 ]]; then
	PR_USER="${PR_GREEN}\u"
	PR_USER_OP="${PR_GREEN}\$"
else
	PR_USER="${PR_RED}\u"
	PR_USER_OP="${PR_RED}\$"
fi

if [[ -n $SSH_CLIENT || -n $SSH2_CLIENT ]]; then
	PR_HOST="${PR_YELLOW}\h${PR_CYAN}:${PR_YELLOW}pts/\l"
else
	PR_HOST="${PR_GREEN}\h${PR_CYAN}:${PR_GREEN}pts/\l"
fi

PR_PWD="${PR_BLUE}${PWD}"

PS1="${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}] \
[${PR_YELLOW}\A${PR_CYAN}] [${PR_PWD}${PR_CYAN}] [${PR_YELLOW}${?}${PR_CYAN}]
 ${PR_USER_OP}${PR_NONE} "
PS2='> '
PS3='> '
PS4='+ '
