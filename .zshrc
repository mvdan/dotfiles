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
bindkey '^Y' up-line-or-history
bindkey '^E' down-line-or-history

setopt auto_name_dirs
setopt auto_pushd
setopt complete_in_word
setopt extended_glob
setopt glob_complete
setopt ignore_eof
setopt multios
setopt no_case_glob
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

noglob-command-line() {
	[[ -z $BUFFER ]] && return
	if [[ $BUFFER == "ng "* ]]; then
		CURSOR=$(( CURSOR-3 ))
		BUFFER="${BUFFER:2}"
	else
		BUFFER="ng $BUFFER"
		CURSOR=$(( CURSOR+3 ))
	fi
}

zle -N noglob-command-line
bindkey "^n" noglob-command-line

jump_after_first_word() {
	local words=(${(z)BUFFER})
	if (( ${#words} <= 1 )); then
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
	HISTSIZE=8000
	SAVEHIST=8000
else
	SAVEHIST=4000
	HISTSIZE=4000
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

bashcomp_done=false
bashcomp() {
	$bashcomp_done && return
	autoload -U bashcompinit
	bashcompinit
	bashcomp_done=true

	for f in "$@"; do
		. "$f"
	done
}

. ~/.shrc

bhelp () {
	bash -c "help \"$@\""
}

da() {
	if [[ $# > 0 ]]; then
	   	du -hs --apparent-size "$1"/*(DN) 2>/dev/null | sort -h
	else
		du -hs --apparent-size ./*(DN) 2>/dev/null | sort -h
	fi
}

alias zcp="noglob zmv -C"
alias zln="noglob zmv -L"
alias mmv='noglob zmv -W'

alias -s log="$PAGER"
alias -s pdf="zathura"
alias -s mp4="mpv"
alias -s flv="mpv"
alias -s mpg="mpv"
alias -s mpeg="mpv"
alias -s mkv="mpv"
alias -s avi="mpv"
alias -s ogv="mpv"
alias -s flac="mpv"
alias -s mp3="mpv"
alias -s ogg="mpv"
alias -s oga="mpv"
alias -s png="feh"
alias -s jpg="feh"
alias -s jpeg="feh"
alias -s bmp="feh"
alias -s gif="feh"
alias -s svg="$BROWSER"
alias -s html="$BROWSER"
alias -s xhtml="$BROWSER"
alias -s htm="$BROWSER"

for color in RED GREEN YELLOW BLUE CYAN; do
	eval PR_$color='%{$fg[${(L)color}]%}'
done
PR_NONE="%{$terminfo[sgr0]%}"

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' use-simple true
zstyle ':vcs_info:git*' formats "%R\0%S\0%b %m %a"

precmd() {
	vcs_info
	if [[ -n ${vcs_info_msg_0_} ]]; then
		git_loc=${vcs_info_msg_0_#*\\0}
		git_extra_info=${git_loc#*\\0}
		git_loc=${git_loc%%\\0*}
		PR_PWD="${PR_BLUE}${vcs_info_msg_0_%%\\0*}${PR_RED}/$git_loc"
	else
		PR_PWD="${PR_BLUE}%d"
		git_extra_info=
	fi

	if [[ $UID -ge 1000 ]]; then
		PR_USER="${PR_GREEN}%n"
		PR_USER_OP="${PR_GREEN}%#"
	else
		PR_USER="${PR_RED}%n"
		PR_USER_OP="${PR_RED}%#"
	fi

	if [[ -n $SSH_CLIENT || -n $SSH2_CLIENT ]]; then
		PR_HOST="${PR_YELLOW}%m${PR_CYAN}:${PR_YELLOW}%l"
	else
		PR_HOST="${PR_GREEN}%m${PR_CYAN}:${PR_GREEN}%l"
	fi

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
