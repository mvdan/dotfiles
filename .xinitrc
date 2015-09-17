xrandr --dpi 144
xbacklight -set 30%
setxkbmap us altgr-intl -option caps:none
amixer -q -M set Master 100% mute
unclutter -idle 3 &
redshift -l 37:-122 &
syndaemon -t -k -i 0.5 &
exec awesome
