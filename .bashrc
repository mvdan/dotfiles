#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

shopt -s globstar

HISTSIZE=8192 HISTFILESIZE=32000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

alias l="less"
alias s="sudo"
alias se="sudoedit"
alias hx="helix"

alias m="sudo mount"
alias um="sudo umount"

mkcd() { mkdir -p "$1" && cd "$1"; }
cdr() { cd $(git rev-parse --show-toplevel); }

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
galias gdf  diff
galias glo  log  "-c core.pager='less -p \"^commit \"' log"
galias glop log  "-c core.pager='less -p \"^commit \"' log -p --format=fuller --stat --show-signature"
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
galias gwt  worktree
galias gr   restore

gwm() { gw "$@" $(git-default-branch); }
gdfm() { gdf "$@" $(git-default-branch); }
grbm() { grb "$@" $(git-default-branch); }
glot() { GIT_EXTERNAL_DIFF=difft glop --ext-diff; }
gdft() { GIT_EXTERNAL_DIFF=difft gdf; }

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
alias jcu="journalctl --user"

alias ls="ls -F"
alias ll="ls -lhiF"
alias la="ls -alhiF"
alias lt="ls -Alhrt"

alias zs="sudo -E $SHELL"
alias rr="rm -rf"

alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."

alias gg="go get"
alias ggn="go generate"
alias gb="go build"
alias gi="go install"
alias gt="go test"
alias gts="go test -vet=off -short -timeout 10s"
alias gf="go test -run=- -vet=off -fuzz"

# gomajor is still useful for bumping major versions,
# but "go list" and "go get" are enough and less buggy for others.
go-updates() {
	go list -u -m -f '{{if and (not .Indirect) .Update}}{{.}}{{end}}' all
}
go-updates-do() {
	go get $(go list -u -m -f '{{if not .Indirect}}{{with .Update}}{{.Path}}@{{.Version}}{{end}}{{end}}' all)
	go mod tidy
}

wbin() { PATH=/usr/bin:${PATH} "$@"; }

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

alias gtoolcmp='go build -toolexec "toolstash -cmp" -a std cmd'

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
alias gcle="git clean -f"
alias gclef="git clean -dffx"
alias gdfs="gdf --stat"
alias gdfc="gdf --cached"
alias gdfo="gdf ORIG_HEAD"
alias gdfu="gdf @{u}"
alias gfe="git fetch -v -p"
alias gfea="git fetch -v -p --all"
alias glopo="glop --reverse ORIG_HEAD.."
alias glopu="glop --reverse ..@{u}"
alias glos="glo --stat"
alias grbi="grb -i"
alias grmc="git rm --cached"
alias gs="git status -sb"
alias gso="git status -sbuno"
alias gss="git status -sb --ignored"
alias gsmf="gsm foreach --recursive"
alias gsmu="gsm update --init --recursive"

alias gsmfc="gsmf 'git clean -dffx && git reset --hard' && gcle && grsh"

git-default-branch-fix() { git remote set-head origin -a; }
git-default-branch() { git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'; }
git-file-sizes() { git ls-files -z | xargs -0 du -b | sort -n; }

gfork() { gh repo fork --remote --remote-name mvdan; }
gprf() { gh pr checkout --branch=pr-$1 $1; }
gmrc() { git push origin -o merge_request.create "$@"; }
alias gml="git-codereview mail"

alias ssh="TERM=xterm ssh"
alias rsv="rsync -avh --info=progress2"

alias clb='curl -F "clbin=<-" https://clbin.com'
alias procs='procs --color=disable'
alias unr='arc unarchive'
alias kc='kubectl'
alias kcl='kubectl logs'
alias kcg='kubectl get'
alias kcd='kubectl describe'

case $TERM in
linux* | cons*) ;;
*) PS1="\[\033]0;\w\007\]" ;;
esac

export PS1+='\$ '

# https://codeberg.org/dnkl/foot/wiki#user-content-shell-integration
osc7_cwd() {
	local strlen=${#PWD}
	local encoded=""
	local pos c o
	for (( pos=0; pos<strlen; pos++ )); do
		c=${PWD:$pos:1}
		case "$c" in
			[-/:_.!\'\(\)~[:alnum:]] ) o="${c}" ;;
			* ) printf -v o '%%%02X' "'${c}" ;;
		esac
		encoded+="${o}"
	done
	printf '\e]7;file://%s%s\e\\' "${HOSTNAME}" "${encoded}"
}
PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }osc7_cwd
prompt_marker() {
    printf '\e]133;A\e\\'
}
PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }prompt_marker
