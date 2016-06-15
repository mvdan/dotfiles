#!/bin/bash

shopt -s globstar
set -o vi

HISTSIZE=4000
HISTFILESIZE=8000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

alias l="less"
alias s="sudo"
alias se="s -E"

alias m="mount"
alias um="umount"

mkcd() { mkdir -p "$1" && cd "$1"; }
cdg() { cd $GOPATH/src/github.com/mvdan; }
cdr() { cd $(git rev-parse --show-toplevel); }
pgr() { ps aux | grep -v grep | grep -i "$@"; }

fn() { find . -name "*$1*"; }
fni() { find . -iname "*$1*"; }

[[ -f /usr/share/git/completion/git-completion.bash ]] && {
	galias() {
		alias $1="git $3"
		__git_complete $1 _git$2
	}
	. /usr/share/git/completion/git-completion.bash
	galias g "" ""

	galias gad  _add         "add"
	galias gbr  _branch      "branch"
	galias gcm  _commit      "commit -v"
	galias gcp  _cherry_pick "cherry-pick"
	galias gclo _clone       "clone"
	galias gco  _checkout    "checkout"
	galias gdf  _diff        "diff"
	galias ggr  _grep        "grep -In"
	galias glo  _log         "log --decorate"
	galias gmr  _merge       "merge"
	galias gpl  _pull        "pull"
	galias gps  _push        "push"
	galias grb  _rebase      "rebase"
	galias grm  _rm          "rm"
	galias grs  _reset       "reset"
	galias grsh _reset       "reset --hard"
	galias grt  _remote      "remote"
	galias grv  _revert      "revert"
	galias gsh  _show        "show"
	galias gsm  _submodule   "submodule"
	galias gst  _stash       "stash"

	gbrd() { for b in $@; do gbr -d $b && gps origin :$b; done; }
	__git_complete gbrd _git_branch
	gbrdm() { gbrd $(git branch --merged | grep -vE '(^\*| master$)'); }
}

[[ -n $TMUX ]] && export TERM=screen-256color

alias spc="sudo pacman"
alias ssi="pacman -Sii"
ssq() { pacman -Qs "$@" | sed -n 's_local/__p'; }
alias srm="sudo pacman -Rns"
alias sim="sudo pacman -S --needed"

alias sc="sudo systemctl"
alias scu="systemctl --user"

alias ls="ls --color=auto -F"
alias grep="grep --color=auto"

alias ll="ls --color=auto -lhiF"
alias la="ls --color=auto -alhiF"
lt() { ls --color=always -Alhrt; }

alias zs="se $SHELL"
alias rr="rm -rf"
alias gh="grep <~/.bash_history"

alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."
alias cd....="cd ../../../.."

alias gg="go get -u -v"
alias gd="go get -u -v -d"
alias gb="go build -v"
alias gi="go install -v"

gbench() {
	: >$1
	for i in $(seq 1 ${2:-10}); do
		go test -benchmem -bench=${3:-.} -benchtime=${4:-0.2s} | tee -a $1
	done
}

alias ssm="pacman -Ss"
alias syu="sudo pacman -Syu"
alias ssk="pacaur -Ss"
alias sik="pacaur -S"
alias syud="pacaur -Syu"

alias gca="git commit -a -v"
alias gcle="git clean -dffx"
alias gdfs="git diff --stat"
alias gdfc="git diff --cached"
alias gdfm="git diff master..."
alias gdfo="git diff ORIG_HEAD..."
alias gdfu="git diff @{u}..."
alias gfea="git fetch --all -v -p"
alias gloo="git log --decorate ORIG_HEAD.."
alias glop="git log --decorate -p"
alias glopo="git log --decorate -p ORIG_HEAD.."
alias glou="git log --decorate ..@{u}"
alias gplr="git pull --rebase=preserve"
alias grbi="git rebase -i"
alias grbia="git rebase -i --autosquash"
alias grmc="git rm --cached"
alias gs="git status -sb"
alias gso="git status -sbuno"
alias gss="git status -sb --ignored"
alias gsmf="git submodule foreach --recursive"
alias gsmu="git submodule update --init --recursive"

alias gsmfc="gsmf 'git clean -dffx && git reset --hard' && gcle && grsh"

alias ssh="TERM=xterm ssh"
alias weeserv="ssh mvdan.cc -t TERM=screen-256color LANG=en_US.UTF-8 tmux -u new weechat"

alias rsv="rsync -ah --info=progress2"

alias jc="sudo journalctl --full"
alias scn="sudo systemctl restart netctl-auto@wlp3s0"

alias spr='curl -F "sprunge=<-" http://sprunge.us'
alias grd="gradle --daemon"
alias ncs="sudo -E netctl-auto switch-to"

[[ -d ~/git/fsr ]] && {
	alias fbld="fdroid build -l -v --no-tarball"
	alias fchk="fdroid checkupdates -v"
	alias flnt="fdroid lint -v"
	. ~/git/fsr/completion/bash-completion
	complete -F _fdroid_build fbld
	complete -F _fdroid_checkupdates fchk
	complete -F _fdroid_lint flnt
}

logcat() { adb logcat | grep `adb shell ps | grep $1 | sed 1q | cut -c10-15`; }

da() { du -h -d 1 ${@:-.} | sort -h; }

PR_RED="\e[31m"
PR_GREEN="\e[32m"
PR_YELLOW="\e[33m"
PR_BLUE="\e[34m"
PR_CYAN="\e[36m"
PR_NONE="\e[39m"

if [[ $UID -ge 1000 ]]; then
	PR_USER="${PR_GREEN}\u"
else
	PR_USER="${PR_RED}\u"
fi

if [[ -n $SSH_CLIENT ]]; then
	PR_HOST="${PR_YELLOW}\h${PR_CYAN}:${PR_YELLOW}\l"
else
	PR_HOST="${PR_GREEN}\h${PR_CYAN}:${PR_GREEN}\l"
fi

case $TERM in
linux* | cons*) PR_TITLE="" ;;
*) PR_TITLE="\[\033]0;[\u@\h:\l] [\w]\007\]" ;;
esac

PS1="${PR_TITLE}${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}] [${PR_YELLOW}\${?}${PR_CYAN}] [${PR_BLUE}\${PWD}${PR_CYAN}]
 \[${PR_GREEN}\]\$\[${PR_NONE}\] "
