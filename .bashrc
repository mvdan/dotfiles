#!/bin/bash

shopt -s globstar

HISTSIZE=8192 HISTFILESIZE=32000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

alias l="less"
alias s="sudo"
alias se="sudoedit"
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

# Git 2.32 broke completions with __git_complete.
# For now, use this as a workaround.
__git_cmd_idx=1

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
galias gdf  diff
galias glo  log  "-c core.pager='less -p \"^commit \"' log"
galias glop log  "-c core.pager='less -p \"^commit \"' log -p --format=fuller --stat"
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
galias gw   switch
galias gr   restore

gwm() { gw "$@" $(git-default-branch); }
gdfm() { gdf "$@" $(git-default-branch)...; }
grbm() { grb "$@" $(git-default-branch); }

__git_complete gbrd _git_branch
alias gclo="git clone"
alias grbc="git rebase --continue"
alias ggc="git gc --prune=all"
alias ggr="git grep -InE"

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

alias zs="sudo -E $SHELL"
alias rr="rm -rf"

alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."

wgo1() { PATH=/usr/lib/go/bin:${PATH} "$@"; }
wgo() {
	local gocmd=go${1}
	shift

	PATH=$(${gocmd} env GOROOT)/bin:${PATH} "$@"
}

alias gg="go get"
alias gb="go build -v"
alias gi="go install -v"
alias gt="go test"
alias gts="go test -vet=off -short -timeout 10s"
alias gf="go test -run=- -vet=off -fuzz"

gstr() {
	if [[ $# == 0 || $1 == help ]]; then
		echo "gstr [stress flags] ./test [test flags]"
		return
	fi
	echo "go test -c -vet=off -o test && stress $@"
	go test -c -vet=off -o test && stress "$@"
}
gcov() {
	go test -coverpkg=./... "$@" -coverprofile=/tmp/c
	go tool cover -html=/tmp/c
}

alias gtoolcmp='go build -toolexec "toolstash -cmp" -a -v std cmd'

gim() { goimports -l -w ${@:-*.go}; }
gfm() { gofumpt -l -w ${@:-*.go}; }
sfm() { shfmt -s -l -w ${@:-.}; }

alias ssm="pacman -Ss"
alias ssk="yay -Ss"
syu() {
	echo " -- yay --"
	yay -Syu || return 1

	echo " -- flatpak --"
	flatpak update || return 1

	echo " -- fwupdmgr --"
	sudo fwupdmgr refresh || return 1
	sudo fwupdmgr get-updates || true # no updates is code 1
}

alias gca="gcm -a"
alias gcam="gcm -a --amend"
alias gcle="git clean -dffx"
alias gdfs="gdf --stat"
alias gdfc="gdf --cached"
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
go-modules-foreach() {
	for dir in $(go-modules); do
		(
			echo $dir
			cd $dir
			"$@"
		)
	done
}

git-default-branch-set() { git remote set-head origin -a; }
git-default-branch() { git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'; }
git-file-sizes() { git ls-files -z | xargs -0 du -b | sort -n; }

gfork() {
	gh repo fork --remote --remote-name mvdan
}
gmrc() { git push -u origin -o merge_request.create "$@"; }
alias gml="git-codereview mail"

alias ssh="TERM=xterm ssh"
alias rsv="rsync -avh --info=progress2"

alias clb='curl -F "clbin=<-" https://clbin.com'
alias bat='bat --pretty=false'
alias unr='arc unarchive'

case $TERM in
linux* | cons*) ;;
*) PS1="\[\033]0;\w\007\]" ;;
esac

export PS1+='\$ '
