export FULLNAME="Daniel Martí" EMAIL="mvdan@mvdan.cc"

export PATH="$HOME/.bin:$HOME/tip/bin:$HOME/go/bin:$PATH"

export PAGER=less LESS=-FXRi LESSHISTFILE=-
export EDITOR=vim DIFF_VIEWER="vim -d" DIFFPROG="vim -d" BROWSER=firefox

# Make Firefox use pixel-perfect scrolling
export MOZ_USE_XINPUT2=1
# Keep Wine quiet by default.
export WINEDEBUG=-all

# Force apps to use Wayland.
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1

# Screen sharing with Sway.
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway

# If running from tty1 start sway
if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway 2>/tmp/sway.log
fi
