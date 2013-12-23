command_test() {
	command -v $1 >/dev/null 2>&1
}
setup_bashcomp() {
	return
}
source ~/.shrc
