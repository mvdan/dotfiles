stty erase '^H'

[[ ! -f /tmp/${USER}-xinit-done ]] && [[ $(tty) = /dev/tty1 ]] && [[ $UID -ge 1000 ]] && {
    touch /tmp/${USER}-xinit-done
    exec xinit
}
