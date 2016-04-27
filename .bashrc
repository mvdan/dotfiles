#!/bin/bash

alias ls="ls --color=auto -F"
alias grep="grep --color=auto"
alias ll="ls --color=auto -lhiF"
alias la="ls --color=auto -alhiF"
lt() { ls --color=always -Alhrt | tail -n 25; }

alias l="less"
alias s="sudo"
alias se="s -E"
alias zs="se $SHELL"
alias rr="rm -rf"
alias vs="se vim"
alias gh="grep <~/.history"

alias m="mount"
alias um="umount"

mkcd() { mkdir -p "$1" && cd "$1"; }
alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."
alias cd....="cd ../../../.."
cdg() { cd $GOPATH/src/github.com/mvdan; }
cdr() { cd $(git rev-parse --show-toplevel); }
pgr() { ps aux | grep -v grep | grep -i "$@"; }

fn() { find . -name "*$1*"; }
fni() { find . -iname "*$1*"; }

alias gg="go get -u -v"
alias gd="go get -u -v -d"
alias gb="go build -v"
alias gi="go install -v"

alias g="git"
alias gad="git add"
alias gadp="git add -p"
alias gap="git apply"
alias gba="git branch -a"
alias gbr="git branch"
alias gbs="git bisect"
alias gca="git commit -a -v"
alias gcm="git commit -v"
alias gcp="git cherry-pick"
alias gcle="git clean -dffx"
alias gclo="git clone"
alias gco="git checkout"
alias gdf="git diff"
alias gdfc="git diff --cached"
alias gdfm="git diff master..."
alias gdfo="git diff ORIG_HEAD..."
alias gdfu="git diff @{u}..."
alias gfe="git fetch -v -p"
alias gfea="git fetch --all -v -p"
alias ggr="git grep -In"
alias glo="git log --decorate"
alias glos="git log --decorate --stat"
alias gloo="git log --decorate ORIG_HEAD.."
alias glop="git log --decorate -p"
alias glopo="git log --decorate -p ORIG_HEAD.."
alias glou="git log --decorate @{u}.."
alias gls="git ls-files"
alias gmr="git merge"
alias gpl="git pull"
alias gplf="git pull --ff-only"
alias gplm="git pull --no-ff"
alias gplr="git pull --rebase=preserve"
alias gps="git push"
alias grb="git rebase"
alias grbi="git rebase -i"
alias grbia="git rebase -i --autosquash"
alias grm="git rm"
alias grmc="git rm --cached"
alias grs="git reset"
alias grsh="git reset --hard"
alias grsp="git reset -p"
alias grt="git remote"
alias grv="git revert"
alias gs="git status -sbuno"
alias gss="git status -sb"
alias gsh="git show"
alias gsm="git submodule"
alias gsmf="git submodule foreach --recursive"
alias gsmu="git submodule update --init --recursive"
alias gst="git stash"

alias gsmfc="gsmf 'git clean -dffx && git reset --hard' && gcle && grsh"

gbrd() { gbr -d $b && gps origin :$b; }

alias ssh="TERM=xterm ssh"
alias weeserv="ssh mvdan.cc -t TERM=screen-256color LANG=en_US.UTF-8 tmux -u new weechat"

[[ -n "$TMUX" ]] && export TERM=screen-256color

command_test() {
	command -v $1 >/dev/null 2>&1
	return $?
}

command_test pacman && {
	alias spc="sudo pacman"
	alias ssm="pacman -Ss"
	alias ssi="pacman -Sii"
	ssq() { pacman -Qs "$@" | sed -n 's_local/__p'; }
	alias srm="sudo pacman -Rns"
	alias sim="sudo pacman -S --needed"
	alias syu="sudo pacman -Syu"
	alias ssk="pacaur -Ss"
	alias sik="pacaur -S"
	alias syud="pacaur -Syu"
}

command_test systemctl && {
	alias sc="sudo systemctl"
	alias scu="systemctl --user"
	alias jc="sudo journalctl --full"
	alias scn="sudo systemctl restart netctl-auto@wlp3s0"
}

command_test netctl && {
	alias ncl="sudo -E netctl"
	alias nca="sudo -E netctl-auto"
	alias wm="sudo -E wifi-menu"
}

command_test fdroid && {
	alias fbld="fdroid build -l -v --no-tarball"
	alias fchk="fdroid checkupdates -v"
	alias flnt="fdroid lint -v"
	. ~/git/fsr/completion/bash-completion
	complete -F _fdroid_build fbld
	complete -F _fdroid_checkupdates fchk
	complete -F _fdroid_lint flnt
}

alias zcp="zmv -C"
alias zln="zmv -L"
alias rsv="rsync -ah --info=progress2"

alias pcat='curl -F "paste=<-" http://p.mvdan.cc'

alias grd="gradle --daemon"
logcat() { adb logcat | grep `adb shell ps | grep $1 | sed 1q | cut -c10-15`; }

da() { du -hs ./{.[!.]*,*} 2>/dev/null | sort -h; }

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

PR_PWD="${PR_BLUE}\${PWD}"

PS1="${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}] [${PR_YELLOW}\${?}${PR_CYAN}] [${PR_PWD}${PR_CYAN}] 
 ${PR_USER_OP}${PR_NONE} "
PS2='> '
PS3='> '
PS4='+ '
