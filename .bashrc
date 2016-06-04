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

alias g="git"
alias gad="git add"
alias gbr="git branch"
alias gcm="git commit -v"
alias gcp="git cherry-pick"
alias gclo="git clone"
alias gco="git checkout"
alias gdf="git diff"
alias ggr="git grep -In"
alias glo="git log --decorate"
alias gmr="git merge"
alias gpl="git pull"
alias gplr="git pull --rebase=preserve"
alias gps="git push"
alias grb="git rebase"
alias grm="git rm"
alias grmc="git rm --cached"
alias grs="git reset"
alias grsh="git reset --hard"
alias grt="git remote"
alias grv="git revert"
alias gsh="git show"
alias gsm="git submodule"
alias gsmf="git submodule foreach --recursive"
alias gst="git stash"

gbrd() { for b in $@; do gbr -d $b && gps origin :$b; done; }
gbrdm() { gbrd $(git branch --merged | grep -vE '(^\*| master$)'); }

[[ -n "$TMUX" ]] && export TERM=screen-256color

alias spc="sudo pacman"
alias ssi="pacman -Sii"
ssq() { pacman -Qs "$@" | sed -n 's_local/__p'; }
alias srm="sudo pacman -Rns"
alias sim="sudo pacman -S --needed"

alias sc="sudo systemctl"
alias scu="systemctl --user"

# Any aliases after this don't need completion
. ~/.bin/alias-completion
alias_completion

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
alias grbi="git rebase -i"
alias grbia="git rebase -i --autosquash"
alias gs="git status -sb"
alias gso="git status -sbuno"
alias gss="git status -sb --ignored"
alias gsmu="git submodule update --init --recursive"

alias gsmfc="gsmf 'git clean -dffx && git reset --hard' && gcle && grsh"

alias ssh="TERM=xterm ssh"
alias weeserv="ssh mvdan.cc -t TERM=screen-256color LANG=en_US.UTF-8 tmux -u new weechat"

alias rsv="rsync -ah --info=progress2"

alias jc="sudo journalctl --full"
alias scn="sudo systemctl restart netctl-auto@wlp3s0"

alias pcat='curl -F "paste=<-" https://p.mvdan.cc'
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
