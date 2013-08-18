[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
amixer set Master 60% unmute -q
xbacklight -set 40
init --user &
redshift -l 41:2 &
syndaemon -t -k -i 1 -d &
eval $(gpg-agent --daemon) &
exec awesome --no-argb
