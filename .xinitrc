xrandr --dpi 144
brightnessctl set 40%
setxkbmap us altgr-intl -option caps:none
ponymix set-volume 50 && ponymix mute
unclutter -idle 3 &
redshift -l 51:0 &
syndaemon -t -k -i 0.5 &
exec awesome
