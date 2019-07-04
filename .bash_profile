export FULLNAME="Daniel Martí" EMAIL="mvdan@mvdan.cc"

# Where to put Go binaries, and the cache
export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export GOCACHE="$HOME/go/cache"

# Never include debug symbols in Go binaries, to speed up builds and save
# space. We don't use a debugger anyway.
#export GOFLAGS="-ldflags=-s -ldflags=-w"
export GOFLAGS="-ldflags=-w"

export GO111MODULE=on
export GOPROXY="https://proxy.golang.org"
export GOPRIVATE='brank.as/*'

export PATH="$HOME/.bin:$HOME/tip/bin:$HOME/go/bin:$PATH"

export PAGER=less LESS=-FXRi LESSHISTFILE=-
export EDITOR=vim DIFF_VIEWER="vim -d" DIFFPROG="vim -d"
export BROWSER=firefox

# Gnome doesn't detect the dpi from xrandr well?
export GDK_DPI_SCALE=1.5
# Make Firefox use pixel-perfect scrolling
export MOZ_USE_XINPUT2=1

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
