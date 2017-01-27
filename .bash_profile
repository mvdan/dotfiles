export FULLNAME="Daniel Martí" EMAIL="mvdan@mvdan.cc"

export GOPATH="$HOME/go/land:$HOME/go"
export PATH="$HOME/.bin:$HOME/tip/bin:$HOME/go/bin:$HOME/go/land/bin:$PATH"

export PAGER=less LESS=-FXRi LESSHISTFILE=-
export EDITOR=nvim DIFF_VIEWER='nvim -d'
export BROWSER=chromium

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
