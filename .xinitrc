xrandr --dpi 144
{
	brightnessctl set 40%
	ponymix set-volume 50
	ponymix mute
	setxkbmap us altgr-intl -option caps:none
} &
redshift -l 51.5:-0.1 &
exec awesome
