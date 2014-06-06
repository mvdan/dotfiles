[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources &
amixer -M set Master 50% unmute -q
xbacklight -set 30% &
unclutter -idle 3 &
init --user &
redshift -l 41:2 &
syndaemon -t -k -i 1 &
exec awesome --no-argb
