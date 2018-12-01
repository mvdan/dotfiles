export FULLNAME="Daniel Martí" EMAIL="mvdan@mvdan.cc"

# Where to put Go binaries, code, and cache
export GOBIN="$HOME/go/bin"
export GOPATH="$HOME/go/land:$HOME/go"
export GOCACHE="$HOME/go/cache"

# Never include debug symbols in Go binaries, to speed up builds and save
# space. We don't use a debugger anyway.
export GOFLAGS="-ldflags=-s -ldflags=-w"

export PATH="$HOME/.bin:$HOME/tip/bin:$HOME/go/bin:$PATH"

export PAGER=less LESS=-FXRi LESSHISTFILE=-
export EDITOR=nvim DIFF_VIEWER='nvim -d' DIFFPROG='nvim -d'
export BROWSER=chromium

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
