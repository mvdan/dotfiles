#!/bin/bash

shopt -s globstar

HISTSIZE=8192 HISTFILESIZE=32000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

alias l="less"
alias s="sudo"
alias se="s -E"
alias v="vim"
alias sp="sed -r 's/([^:]*:[^:]*:)/\1\t/'"

alias m="sudo mount"
alias um="sudo umount"

mkcd() { mkdir -p "$1" && cd "$1"; }
cdr() { cd $(git rev-parse --show-toplevel); }
cdc() {
	local ref=${1:-HEAD}
	# cd into the repo root first
	cd $(git rev-parse --show-toplevel)
	# cd into the directory containing all the changes
	cd $(git diff-tree --no-commit-id --name-only -r $ref | sed -e 'N;s/^\(.*\).*\n\1.*$/\1\n\1/;D')
}

pgr() { ps aux | grep -v grep | grep -iE "$@"; }
alias rg="rg --no-heading --max-columns=150 --max-columns-preview"

source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash
_completion_loader git
galias() {
	alias $1="git ${3:-$2}"
	__git_complete $1 _git_$2
}

galias gad  add
galias gbi  bisect
galias gbr  branch
galias gcm  commit
galias gcp  cherry_pick "cherry-pick"
galias gclo clone
galias gco  checkout
galias gdf  diff
galias ggc  gc   "gc --prune=all"
galias ggr  grep "grep -InE"
galias glo  log  "-c core.pager='less -p \"^commit \"' log"
galias glop log  "-c core.pager='less -p \"^commit \"' log -p --format=fuller"
galias gmr  merge
galias gpl  pull "pull --stat"
galias gps  push
galias gpsf push "push --force-with-lease"
galias grb  rebase
galias grs  reset
galias grsh reset "reset --hard"
galias grt  remote
galias grv  revert
galias gsh  show
galias gsm  submodule
galias gst  stash "-c core.pager='less -p ^stash' stash"

__git_complete gbrd _git_branch
alias grbc="git rebase --continue"

alias spc="sudo pacman"
alias ssi="pacman -Sii"
ssq() { pacman -Qs "$@" | sed -n 's_local/__p'; }
alias srm="spc -Rns"
alias sim="spc -S --needed"
alias mksrcinfo="makepkg --printsrcinfo >.SRCINFO"

alias sc="sudo systemctl"
alias scu="systemctl --user"
alias jc="journalctl"

alias ls="ls -F"
alias ll="ls -lhiF"
alias la="ls -alhiF"
alias lt="ls -Alhrt"

alias zs="se $SHELL"
alias rr="rm -rf"

alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."

alias go1="/usr/bin/go"
withgo1() { PATH=${PATH//$HOME\/tip\/bin/} "$@"; }

alias gg="go get -u"
alias gd="go get -u -d"
alias gb="go build -v"
alias gi="go install -v"
alias gt="go test"
alias gts="go test -vet=off -short -timeout 10s"

gstr() {
	if [[ $# == 0 || $1 == help ]]; then
		echo "gstr [stress flags] ./test [test flags]"
		return
	fi
	go test -c -vet=off -o test && stress "$@"
}
gcov() {
	go test -coverpkg=./... "$@" -coverprofile=/tmp/c
	go tool cover -html=/tmp/c
}

gbench() {
	if [[ $# == 0 || $1 == help ]]; then
		echo "gbench [cur] [.] [6] [1s]"
		return
	fi
	perflock -governor=70% go test . -run='^$' -vet=off -bench=${2:-.} \
		-count=${3:-6} -benchtime=${4:-1s} | tee ${1:-cur} | grep -v :
}

alias gtoolcmp='go build -toolexec "toolstash -cmp" -a -v std cmd'
gtoolbench() {
	if [[ ! -f old ]]; then
		perflock -governor=70% compilebench -short -alloc -count 10 -compile $(toolstash -n compile) "$@" | tee old
	fi
	perflock -governor=70% compilebench -short -alloc -count 10 "$@" | tee new
	benchstat old new
}

gim() { goimports -l -w ${@:-*.go}; }
gfm() { gofumpt -s -l -w ${@:-*.go}; }
sfm() { shfmt -s -l -w ${@:-.}; }

alias ssm="pacman -Ss"
alias syu="sudo pacman -Syu"
alias ssk="yay -Ss"

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
alias glopo="glop --reverse ORIG_HEAD.."
alias glopu="glop --reverse ..@{u}"
alias glos="glo --stat"
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
	for d in $(find . -name .git -type d -prune); do
		echo ${d:2:-5}
	done
}
go-modules() {
	find . \( -name vendor -o -name '[._].*' -o -name node_modules \) -prune -o -name go.mod -print | sed 's:/go.mod$::'
}

git-file-sizes() { git ls-files -z | xargs -0 du -b | sort -n; }

gprc() {
	if git config remote.mvdan.url >/dev/null; then
		git push -f -u mvdan || return 1
	else
		# No fork present, so assume we are the only owner.
		git push -u origin || return 1
	fi
	if [[ $(git rev-list --count HEAD ^origin/master) == 1 ]]; then
		hub pull-request -f --no-edit "$@"
	else
		# Edit the PR body if there are many commits.
		hub pull-request -f "$@"
	fi
}
gmrc() { git push -u origin -o merge_request.create "$@"; }
alias gml="git-codereview mail"

alias ssh="TERM=xterm ssh"
alias weeserv="ssh shark.mvdan.cc -t TERM=screen-256color LANG=en_US.UTF-8 tmux -u new weechat"

alias rsv="rsync -avh --info=progress2"

alias clb='curl -F "clbin=<-" https://clbin.com'
alias bat='bat --pretty=false'
alias unr='arc unarchive'

alias kc='kubectl'
kcc() {
	if [[ $# -eq 0 ]]; then
		kc config get-contexts
	else
		kc config use-context "$@"
	fi
}

alias kcg='kc get'
alias kcga='kc get deploy,po,svc'
alias kcp='{ sleep 1; firefox http://127.0.0.1:8001/ui &>/dev/null; } & kc proxy'
alias kcd='kc describe'
alias kcl='kc logs --tail=200 -f'
alias kce='kc get events --sort-by=.metadata.creationTimestamp'

da() { du -h -d 1 "${@:-.}" | sort -h; }

case $TERM in
linux* | cons*) ;;
*) PS1="\[\033]0;\w\007\]" ;;
esac

export PS1='\$ '
