xrandr --dpi 144
{
	brightnessctl set 40%
	ponymix set-volume 50
	ponymix mute
	setxkbmap us altgr-intl -option caps:none
} &
# London
# redshift -l 53.4:-1.6 &
# Barcelona
redshift -l 41.4:2.0 &
exec awesome
