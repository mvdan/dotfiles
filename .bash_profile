export FULLNAME="Daniel Martí" EMAIL="mvdan@mvdan.cc"

export GOPATH="$HOME/go/land:$HOME/go"
export GOCACHE="$HOME/go/cache"
export PATH="$HOME/.bin:$HOME/tip/bin:$HOME/go/bin:$HOME/go/land/bin:$PATH"
export CDPATH=".:$HOME/tip/src:$HOME/go/src:$HOME/go/land/src"

export PAGER=less LESS=-FXRi LESSHISTFILE=-
export EDITOR=nvim DIFF_VIEWER='nvim -d' DIFFPROG='nvim -d'
export BROWSER=chromium

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
