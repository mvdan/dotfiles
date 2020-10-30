#xrandr --dpi 144
ponymix set-volume 20
brightnessctl set 40%
setxkbmap us altgr-intl -option caps:none
nm-applet --no-agent &

# London
redshift -l 53.4:-1.6 &

# Barcelona
# redshift -l 41.4:2.0 &

# Seoul
# redshift -l 37.5:126.8 &

# Jakarta
# redshift -l -6.3:106.8 &

exec awesome
