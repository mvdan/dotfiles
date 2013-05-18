[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
amixer set Master 60% unmute -q
xbacklight -set 60
init --user &
redshift -l 41:2 &
syndaemon -t -k -i 1 -d &
exec awesome --no-argb
