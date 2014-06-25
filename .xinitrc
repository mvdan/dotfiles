([ -f ~/.Xresources ] && xrdb -merge ~/.Xresources) &
(xrandr --dpi 150; xbacklight -set 30%; setxkbmap es; setxkbmap -option caps:none; amixer -M set Master 50% unmute -q) &
unclutter -idle 3 &
redshift -l 41:2 &
syndaemon -t -k -i 1 &
exec awesome --no-argb
