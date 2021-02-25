set -o allexport
source <(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
set +o allexport

# If running from tty1, start sway.
if [ "$(tty)" = "/dev/tty1" ]; then
	# mv /tmp/sway.log /tmp/sway-previous.log
	# exec sway -d 2>/tmp/sway.log
	WLR_DRM_NO_MODIFIERS=1 exec sway 2>/tmp/sway.log
fi
