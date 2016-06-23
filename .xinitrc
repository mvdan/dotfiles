xrandr --dpi 144
xbacklight -set 40%
setxkbmap us altgr-intl -option caps:none
amixer -q -M set Master 50% mute
unclutter -idle 3 &
redshift -l 55:1.6 &
syndaemon -t -k -i 0.5 &
exec awesome
