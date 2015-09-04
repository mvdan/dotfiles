autoload -U compinit colors zsh/terminfo zmv
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

setopt extended_glob
setopt glob_complete
setopt multios
setopt no_case_glob
setopt no_flow_control
setopt no_hup
setopt no_beep
setopt numeric_glob_sort
setopt prompt_subst

zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _expand _complete _approximate _files _ignored
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

SAVEHIST=50000
HISTSIZE=50000

HISTFILE=~/.history
setopt hist_ignore_dups
setopt share_history
setopt shwordsplit

bash_compat_init() {
	autoload -U bashcompinit
	bashcompinit
}

. ~/.shrc

bhelp () {
	bash -c "help \"$@\""
}

da() {
	if [[ $# > 0 ]]; then
		du -hs "$1"/*(DN) 2>/dev/null | sort -h
	else
		du -hs ./*(DN) 2>/dev/null | sort -h
	fi
}

alias zcp="noglob zmv -C"
alias zln="noglob zmv -L"
alias mmv='noglob zmv -W'

for color in RED GREEN YELLOW BLUE CYAN; do
	eval PR_$color='%{$fg[${(L)color}]%}'
done
PR_NONE="%{$terminfo[sgr0]%}"

precmd() {
	PR_PWD="${PR_BLUE}%d"

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
[${PR_YELLOW}%T${PR_CYAN}] [${PR_PWD}${PR_CYAN}] [${PR_YELLOW}%?${PR_CYAN}]
 ${PR_USER_OP}${PR_NONE} "
}
