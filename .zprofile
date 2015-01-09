stty erase '^H'

. ~/.envrc

[[ ! -f /tmp/${USER}-startx-done ]] && [[ $(tty) = /dev/tty1 ]] && [[ $UID -ge 1000 ]] && {
    touch /tmp/${USER}-startx-done
    exec startx
}
