#!/bin/bash

shopt -s globstar

HISTSIZE=8000 HISTFILESIZE=64000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

alias l="less"
alias s="sudo"
alias se="s -E"
alias v="nvim"
alias sp="sed -r 's/([^:]*:[^:]*:)/\1\t/'"

alias m="sudo mount"
alias um="sudo umount"

mkcd() { mkdir -p "$1" && cd "$1"; }
cdl() { cd $(go list -e -f {{.Dir}} $1); }
cdr() { cd $(git rev-parse --show-toplevel); }
pgr() { ps aux | grep -v grep | grep -i "$@"; }

cdm() {
	if [[ $# == 0 ]]; then
		cd $HOME/go/src/mvdan.cc
	else
		cd $HOME/go/src/mvdan.cc/*$1*
	fi
}
cdg() {
	if [[ $# == 0 ]]; then
		cd $HOME/go/src/github.com
	else
		cd $HOME/go/src/github.com/*$1
	fi
}
cdb() {
	if [[ $# == 0 ]]; then
		cd $HOME/go/src/brank.as
	else
		cd $HOME/go/src/brank.as/*$1
	fi
}

fn() { find . -name "$1"; }
fni() { find . -iname "$1"; }

[[ -f /usr/share/git/completion/git-completion.bash ]] && {
	galias() {
		alias $1="git $3"
		__git_complete $1 _git$2
	}
	. /usr/share/git/completion/git-completion.bash

	galias gad  _add         "add"
	galias gbi  _bisect      "bisect"
	galias gbr  _branch      "branch"
	galias gcm  _commit      "commit"
	galias gcp  _cherry_pick "cherry-pick"
	galias gclo _clone       "clone"
	galias gco  _checkout    "checkout"
	galias gdf  _diff        "diff"
	galias ggc  _gc          "gc --prune=all"
	galias ggr  _grep        "grep -In"
	galias glo  _log         "-c core.pager='less -p ^commit ' log"
	galias glop _log         "-c core.pager='less -p ^commit ' log -p"
	galias gmr  _merge       "merge"
	galias gpl  _pull        "pull"
	galias gps  _push        "push"
	galias grb  _rebase      "rebase"
	galias grs  _reset       "reset"
	galias grsh _reset       "reset --hard"
	galias grt  _remote      "remote"
	galias grv  _revert      "revert"
	galias gsh  _show        "show"
	galias gsm  _submodule   "submodule"
	galias gst  _stash       "-c core.pager='less -p ^stash' stash"

	__git_complete gbrd _git_branch
	alias grbc="git rebase --continue"
}

tm() { [[ -z $TMUX ]] && exec tmux; }
[[ -n $TMUX ]] && export TERM=screen-256color

alias spc="sudo pacman"
alias ssi="pacman -Sii"
ssq() { pacman -Qs "$@" | sed -n 's_local/__p'; }
alias srm="spc -Rns"
alias sim="spc -S --needed"
alias mksrcinfo="makepkg --printsrcinfo >.SRCINFO"

alias sc="sudo systemctl"
alias jc="journalctl"

wifi-down() {
	sudo systemctl stop netctl-auto@wlp3s0
	sudo echo auto >/sys/bus/usb/devices/2-4/power/control
}
wifi-up() {
	sudo systemctl start netctl-auto@wlp3s0
}

alias ls="ls -F"
alias ll="ls -lhiF"
alias la="ls -alhiF"
alias lt="ls -Alhrt"

alias zs="se $SHELL"
alias rr="rm -rf"
alias gh="grep <~/.bash_history"

alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."

alias go1="/usr/bin/go"
alias gg="go get -u -v"
alias gd="go get -u -v -d"
alias gb="go build -v"
alias gi="go install -v"
alias gt="go test"
alias gts="go test -short -timeout 2s"
gim() { goimports -l -w ${@:-*.go}; }
gfm() { gofmt -s -l -w ${@:-*.go}; }

gcov() {
	go test $@ -coverprofile=/tmp/c
	go tool cover -html=/tmp/c
}

gbench() {
	perflock go test . -run='^$' -benchmem -bench=${2:-.} \
		-count=${3:-6} -benchtime=${4:-1s} | tee ${1:-cur} | grep -v :
}

goxg() {
	gox -gocmd=/usr/bin/go -ldflags='-w -s' -output="{{.Dir}}_$(git describe)_{{.OS}}_{{.Arch}}"
}

alias gtoolcmp='go build -toolexec "toolstash -cmp" -a -v std cmd'
gtoolbench() {
	if [[ ! -f old ]]; then
		perflock compilebench -short -alloc -count 10 -compile $(toolstash -n compile) $@ | tee old
	fi
	perflock compilebench -short -alloc -count 10 $@ | tee new
	benchstat old new
}

sfm() { shfmt -s -l -w ${@:-.}; }

alias ssm="pacman -Ss"
alias syu="sudo pacman -Syu"
alias ssk="yay -Ss"
alias sik="yay -S"
alias syud="yay -Syu"

alias gca="gcm -a"
alias gcam="gcm -a --amend"
alias gcle="git clean -dffx"
alias gdfs="gdf --stat"
alias gdfc="gdf --cached"
alias gdfm="gdf master..."
alias gdfo="gdf ORIG_HEAD..."
alias gdfu="gdf @{u}..."
alias gfe="git fetch -v -p"
alias gfea="git fetch -v -p --all"
alias gloo="glo ORIG_HEAD.."
alias glopo="glo -p --reverse ORIG_HEAD.."
alias glopu="glo -p --reverse master..origin/master"
alias glos="glo --stat"
alias glou="glo ..@{u}"
alias gplr="git pull --rebase=preserve"
alias grbi="grb -i"
alias grbia="grb -i --autosquash"
alias grmc="git rm --cached"
alias gs="git status -sb"
alias gso="git status -sbuno"
alias gss="git status -sb --ignored"
alias gsmf="gsm foreach --recursive"
alias gsmu="gsm update --init --recursive"

alias gsmfc="gsmf 'git clean -dffx && git reset --hard' && gcle && grsh"

git-repos() {
	for d in $(find * -name .git -type d -prune); do
		echo ${d::-5}
	done
}

git-file-sizes() {
	git ls-files | xargs du -b | sort -n
}

alias gprc="gps -u mvdan && hub pull-request -f --no-edit"
alias gml="git-codereview mail"

alias ssh="TERM=xterm ssh"
alias weeserv="ssh shark.mvdan.cc -t TERM=screen-256color LANG=en_US.UTF-8 tmux -u new weechat"

alias rsv="rsync -avh --info=progress2"

alias scn="sudo systemctl restart netctl-auto@wlp3s0"

alias clb='curl -F "clbin=<-" https://clbin.com'
alias ncl="sudo netctl"
alias nca="TERM=dumb sudo netctl-auto"
alias bat='bat --pretty=false'

alias kc='kubectl'
kcc() {
	if [[ $# -eq 0 ]]; then
		kc config get-contexts
	else
		kc config use-context $@
	fi
}
alias tf='terraform'

alias gcl='gcloud'
gclc() {
	if [[ $# -eq 0 ]]; then
		gcl config configurations list
	else
		gcl config configurations activate $@
	fi
}

alias kcg='kc get'
alias kcga='kc get deploy,po,svc'
alias kcp='{ sleep 1; chromium http://127.0.0.1:8001/ui &>/dev/null; } & kc proxy'
alias kcd='kc describe'
alias kcl='kc logs --tail=200 -f'

da() { du -h -d 1 "${@:-.}" | sort -h; }

docker-cleanup() {
	echo "removing exited containers"
	docker ps -qa --no-trunc --filter "status=exited" | xargs -r docker rm
	echo "removing untagged images"
	docker images | grep "none" | awk '/ / { print $3 }' | xargs -r docker rmi
	echo "removing dangling volumes"
	docker volume ls -qf dangling=true | xargs -r docker volume rm
}

case $TERM in
linux* | cons*) ;;
*) PS1="\[\033]0;[\w]\007\]" ;;
esac

PS1="$PS1[\u@\h:\l] [\${?}] [\${PWD}]
 \$ "
