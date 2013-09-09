autoload -U compinit zcalc colors zsh/terminfo vcs_info edit-command-line zmv
compinit
colors

bindkey -v
bindkey '^r' history-incremental-search-backward
bindkey "\e[A" up-line-or-history
bindkey "\e[B" down-line-or-history
bindkey "\e[C" forward-char
bindkey "\e[D" backward-char
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" overwrite-mode
bindkey "\e[5C" forward-word
bindkey "\e[5D" backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

setopt auto_name_dirs
setopt auto_pushd
setopt complete_in_word
setopt extended_glob
setopt glob_complete
setopt ignore_eof
setopt multios
setopt no_case_glob
setopt no_clobber
setopt no_flow_control
setopt no_hup
setopt no_beep
setopt numeric_glob_sort
setopt prompt_subst
setopt pushd_ignore_dups
setopt pushd_minus
setopt pushd_silent
setopt pushd_to_home
setopt rc_expand_param
setopt list_ambiguous

_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}

setopt zle
zle -N edit-command-line

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _expand _force_rehash _complete _approximate _files _ignored
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*:default' menu 'select=0'
zstyle ':completion:*' file-sort modification reverse
zstyle ':completion:*' list-colors "=(#b) #([0-9]#)*=36=31"
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:man:*' menu yes select
zstyle ':completion:*' list-separator 'fREW'
zstyle ':completion:*:windows' menu on=0
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:approximate:*' max-errors 'reply=(  $((  ($#PREFIX+$#SUFFIX)/3  ))  )'
zstyle ':completion:*:corrections' format '%B%d (errors %e)%b'
zstyle ':completion::*:(rm|vi):*' ignore-line true
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion::approximate*:*' prefix-needed false
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -au $USER -o pid,%cpu,tty,cputime,cmd'

sudo-command-line() {
    [[ -z $BUFFER ]] && return
    if [[ $BUFFER == "s "* ]]; then
        CURSOR=$(( CURSOR-2 ))
        BUFFER="${BUFFER:2}"
    else
        BUFFER="s $BUFFER"
        CURSOR=$(( CURSOR+2 ))
    fi
}

zle -N sudo-command-line
bindkey "^s" sudo-command-line

jump_after_first_word() {
    local words=(${(z)BUFFER})
    if (( ${#words} <= 1 )) ; then
        CURSOR=${#BUFFER}
    else
        CURSOR=${#${words[1]}}
    fi
}

zle -N jump_after_first_word
bindkey '^f' jump_after_first_word

setopt vi
bindkey -M viins 'jj' vi-cmd-mode
bindkey -M viins '\C-i' complete-word
bindkey -M viins ' ' magic-space
bindkey -M vicmd 'v' edit-command-line
bindkey -M vicmd 'u' undo
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M vicmd '//' history-beginning-search-backward
bindkey -M vicmd '??' history-beginning-search-forward
bindkey -M vicmd 'q' push-line

if [[ $HOST == royal ]]; then
    HISTSIZE=3000
    SAVEHIST=3000
else
    SAVEHIST=1000
    HISTSIZE=1000
fi

HISTFILE=~/.history
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt hist_no_store
setopt hist_verify
setopt extended_history
setopt hist_save_no_dups
setopt hist_expire_dups_first
setopt hist_find_no_dups

[[ -n ${commands[vim]} ]] && export EDITOR=vim || export EDITOR=vi
[[ -n ${commands[vimpager]} ]] && {
    export PAGER="vimpager"
    alias less="vimpager"
    alias zless="vimpager"
} || export PAGER="less"
[[ -n "$DISPLAY" ]] && export BROWSER=dwb
[[ -n "$TMUX" ]] && export TERM=screen-256color

alias -s log="$PAGER"
alias -s pdf="zathura"
alias -s mp4="mplayer"
alias -s flv="mplayer"
alias -s mpg="mplayer"
alias -s mpeg="mplayer"
alias -s mkv="mplayer"
alias -s avi="mplayer"
alias -s ogv="mplayer"
alias -s flac="mplayer"
alias -s mp3="mplayer"
alias -s ogg="mplayer"
alias -s oga="mplayer"
alias -s png="feh"
alias -s jpg="feh"
alias -s jpeg="feh"
alias -s bmp="feh"
alias -s gif="feh"
alias -s svg="$BROWSER"
alias -s html="$BROWSER"
alias -s xhtml="$BROWSER"
alias -s htm="$BROWSER"

alias -g G="| grep"
alias -g L="| $PAGER"
alias -g S="| sed"
alias -g D="| vimdiff"

alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias ll="ls --color=auto -lh"
alias la="ls --color=auto -alh"
lt () { [[ $# > 0 ]] &&
    ls --color=always -Alhrt "$1" | tail -n 25 ||\
    ls --color=always -Alhrt | tail -n 25 }
-lt () { [[ $# > 0 ]] &&
    ls --color=always -Alhrt "$1" | head -n 25 ||\
    ls --color=always -Alhrt | head -n 25 }
da() { [[ $# > 0 ]] && du -hs --apparent-size "${1%/}/"*(DN) 2>/dev/null | sort -h\
    || du -hs --apparent-size ./*(DN) 2>/dev/null | sort -h
}

alias mkd="mkdir -p"
mkcd() { mkdir -p $1 && cd $1 }
alias cd..="cd .."
alias cd...="cd ../.."
alias cd....="cd ../../.."
alias cd.....="cd ../../../.."
alias 1="cd -"
alias 2="cd +2"
alias 3="cd +3"
alias 4="cd +4"
alias 5="cd +5"
alias 6="cd +6"
alias 7="cd +7"
alias 8="cd +8"
alias 9="cd +9"

alias md="mkdir -p"
alias rd="rmdir"
alias rr="rm -rf"
alias d="dirs -v"

alias p="print -l"
alias l="${PAGER}"
alias c="cat"
alias v="vim"
alias s="sudo "
alias se="sudo -E "
alias ng="noglob"
alias lm="mount | sed 's/ \(on\|type\) /;;/g' | column -t -s ';;'"
alias m="mount"
alias um="umount"
alias umo="umount /media/"

alias pk="pkill -SIGKILL"
pgr () { ps aux | grep -v grep | grep "$@" -i --color=auto; }
fn () { [[ $# > 1 ]] && find $1 -iname "*$2*" || find . -iname "*$1*" }
alias udb="sudo updatedb"
lc () { [[ $# > 1 ]] && locate -i "$(readlink -f $1)/*$2*" || locate -i "$(readlink -f .)/*$1*" }

alias g="git"
alias gad="git add"
alias gap="git apply"
alias gbs="git bisect"
alias gba="git branch -a"
alias gbr="git branch"
alias gca="git commit -a"
alias gcl="git clone"
alias gcm="git commit"
alias gco="git checkout"
alias gdf="git diff"
alias gdfc="git diff --cached"
alias gdfo="git diff ORIG_HEAD.."
alias gdfs="git diff --submodule"
alias gdfu="git diff @{u}.."
alias gfe="git fetch"
alias ggr="git grep"
alias glo="git log"
alias glop="git log -p"
alias glou="git log @{u}.."
alias gloup="git log -p @{u}.."
alias gls="git ls-files"
alias gmr="git merge"
alias gpl="git pull"
alias gpla="git pull --all"
alias gplr="git pull -r"
alias gps="git push"
alias grb="git rebase"
alias grm="git rm"
alias grmc="git rm --cached"
alias grs="git reset"
alias grt="git remote"
alias grv="git revert"
alias gs="git status -sb -uno"
alias gsa="git status -sb"
alias gsm="git submodule"
alias gss="git status"
alias gst="git stash"

alias gsvn="git svn"

alias dwbr="ip r | sed 's/default via \([^ ]*\).*/\1/' | xargs dwb &"
wpa_sup() { wpa_passphrase $1 $2 | sudo wpa_supplicant -iwlan0 -d -c /dev/stdin }


[[ -x ~/git/fdroidserver/fdroid ]] && {
    autoload -U bashcompinit
    bashcompinit
    fdroid() { python2 $HOME/git/fdroidserver/fdroid "$@" }
    fbld() { fdroid build -l -v -p "$@" }
    fcheckup() { fdroid checkupdates -v -p "$@" }
    source $HOME/git/fdroidserver/completion/bash-completion
    complete -F _fdroid_build_project fbld
    complete -F _fdroid_checkupdates_project fcheckup
    alias commitupdates="$HOME/git/fdroidserver/commitupdates"
}
chfdroid() { export HOME=/media/dan/fdroid zsh && cd }

alias mtp="sudo mtpfs -o allow_other /mnt"
alias umtp="fusermount -u /mnt"
alias mss="sshfs -C -o follow_symlinks"
alias mserv="sshfs mvdan@mvdan.cc:/home/mvdan/ ~/srv -C -o follow_symlinks"
alias umserv="fusermount -u ~/srv"
alias weeserv="ssh mvdan.cc -t TERM=screen-256color LANG=en_US.UTF-8 tmux -u new weechat-curses"
alias devserv="ssh dev1 -t TERM=screen-256color LANG=en_US.UTF-8 tmux -u new"

[[ -n ${commands[aptitude]} ]] && {
    alias ap="aptitude"
    alias ag="apt-get"
    alias syu="sudo aptitude update && sudo aptitude dist-upgrade"
    alias ssm="aptitude search"
    alias sim="sudo aptitude install"
}

[[ -n ${commands[pacman]} ]] && {
    alias pc="pacman"
    alias spc="sudo -E pacman"
    alias ssm="pacman -Ss"
    ssq() { pacman -Qs "$@" | sed -n 's_local/__p' }
    ssw() { pacman -Qo $(which $1) }
    alias srm="sudo -E pacman -Rns"
    alias sim="sudo -E pacman -S --needed"
    alias syu="sudo -E pacman -Syu"
    alias syyu="sudo -E pacman -Syyu"
    alias p_size="pacman -Qi | sed -n 's/^\(Name\|Installed\).*\:[ ]*\(.*\)/\2/p'\
 | sed '/^[^ ]*$/N;s/\(.*\)\n\(.*\)/\2 \1/' | sort -h | column -t"
}

[[ -n ${commands[pacaur]} ]] && {
    alias ssk="pacaur -Ss"
    alias sik="pacaur -S"
    alias syud="pacaur -Syu"
}

[[ -n ${commands[systemctl]} ]] && {
    alias sc="sudo systemctl"
    alias scr="sudo systemctl reload-or-restart"
    alias scu="systemctl --user"
    alias scs="sudo systemctl --system"
    alias jc="sudo journalctl --full"
}

[[ -n ${commands[netctl]} ]] && {
    nc() { sudo NETCTL_DEBUG=yes netctl "$@" }
    compdef _netctl nc
    alias wm="sudo wifi-menu"
}

alias tlf="sudo tailf"
alias zs="sudo -E zsh"
alias vis="sudo -E vim"
alias vdifs="sudo -E vimdiff"

alias zcp="zmv -C"
alias zln="zmv -L"
alias cr="rsync -ahvP --"
alias xp="xsel -p"
alias xb="xsel -b"

spr() {
    if [ -t 0 ]; then
        [ "$*" ] || return 1
        if [ -f "$*" ]; then
            echo "Uploading the file "$*"..." >&2
            cat "$*"
        else
            echo "Uploading the string \""$*"\"..." >&2
            echo "$*"
        fi | curl -F 'sprunge=<-' http://sprunge.us
    else
        echo "Uploading from stdin..." >&2
        curl -F 'sprunge=<-' http://sprunge.us
    fi
}

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

[[ -d ~/.misc ]] && {
    alias chsid="sudo -E $HOME/.misc/debian-chroot.sh /home/debian"
    alias setup_enc="$HOME/.misc/setup-conceptronic.sh"
    alias enc="$HOME/.misc/encode-conceptronic.sh"
    alias p_independent="$HOME/.misc/pacman-independent.sh"
    alias p_disowned="$HOME/.misc/pacman-disowned.sh"
    alias flacc="$HOME/.misc/flac2.sh"
}

[[ -n ${commands[dpkg]} ]] && {
    alias dcl="rm -fR */(N) *.{deb,changes,dsc,upload}(N)"
    dpr() { [[ ! -d *(/) ]] &&\
        tar -xf *orig* && tar -xf *debian* && mv debian/ ^debian/ && cd ^debian/ }
    dpk() { [[ -f debian/changelog ]] && {
        NAME=`head -n 1 debian/changelog | sed -ne 's/\(.*\) (\(.*\)).*/\1_\2/p'`;
        tar -cf ../$NAME.debian.tar.gz debian/ } }
    alias dbl="dpkg-buildpackage -sa && cd .."
    alias dln="lintian -Ii --pedantic *.changes(N)"
    alias ql="quilt"
}

export FULLNAME="Daniel Martí"
export EMAIL="mvdan@mvdan.cc"
export DEBFULLNAME="Daniel Martí"
export DEBEMAIL="mvdan@mvdan.cc"

for color in RED GREEN YELLOW BLUE CYAN; do
    eval PR_$color='%{$fg[${(L)color}]%}'
done
PR_NONE="%{$terminfo[sgr0]%}"

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' use-simple true
zstyle ':vcs_info:git*' formats "%R\0%S\0%b %m %a"

precmd() {
    vcs_info
    [[ -n ${vcs_info_msg_0_} ]]\
        && {
            git_loc=${vcs_info_msg_0_#*\\0}
            git_extra_info=${git_loc#*\\0}
            git_loc=${git_loc%%\\0*}
            PR_PWD="${PR_BLUE}${vcs_info_msg_0_%%\\0*}${PR_RED}/$git_loc" }\
        || PR_PWD="${PR_BLUE}%d"
    [[ $UID -ge 1000 ]]\
        && { PR_USER="${PR_GREEN}%n"; PR_USER_OP="${PR_GREEN}%#"; }\
        || { PR_USER="${PR_RED}%n"; PR_USER_OP="${PR_RED}%#"; }
    [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]\
        && PR_HOST="${PR_YELLOW}%m${PR_CYAN}:${PR_YELLOW}%l"\
        || PR_HOST="${PR_GREEN}%m${PR_CYAN}:${PR_GREEN}%l"
    case $TERM in
        linux*|cons*)
            PR_TITLEBAR="";;
        *)
            PR_TITLEBAR=$'%{\e]0;[%n@%m:%l] [%T] [%d] [%?]\a%}';;
    esac
    PROMPT="${(e)PR_TITLEBAR}${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}] \
[${PR_YELLOW}%T${PR_CYAN}] [${PR_PWD}${PR_CYAN}] [${PR_YELLOW}%?${PR_CYAN}] ${PR_YELLOW}$git_extra_info
 ${PR_USER_OP}${PR_NONE} "
}
