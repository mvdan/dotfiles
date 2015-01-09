([ -f ~/.Xresources ] && xrdb -merge ~/.Xresources) &
(
	xrandr --dpi 150;
	xbacklight -set 30%;
	setxkbmap us altgr-intl -option caps:none;
	amixer -q -M set Master 100% mute;
)&
unclutter -idle 3 &
redshift -l 41:2 &
syndaemon -t -k -i 1 &
exec awesome
