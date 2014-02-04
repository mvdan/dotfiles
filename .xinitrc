[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
amixer -M set Master 50% unmute -q
init --user &
xbacklight -set 30%
redshift -l 41:2 &
syndaemon -t -k -i 1 -d &
eval $(gpg-agent --daemon) &
exec awesome --no-argb
