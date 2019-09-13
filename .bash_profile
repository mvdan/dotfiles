export FULLNAME="Daniel Martí" EMAIL="mvdan@mvdan.cc"

export PATH="$HOME/.bin:$HOME/tip/bin:$HOME/go/bin:$PATH"

export PAGER=less LESS=-FXRi LESSHISTFILE=-
export EDITOR=vim DIFF_VIEWER="vim -d" DIFFPROG="vim -d"
export BROWSER=firefox

# Gnome doesn't detect the dpi from xrandr well?
export GDK_DPI_SCALE=1.5
# Make Firefox use pixel-perfect scrolling
export MOZ_USE_XINPUT2=1

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
