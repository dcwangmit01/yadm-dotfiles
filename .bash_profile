# Login shells (macOS terminals, ssh, tty): defer entirely to ~/.bashrc,
# which non-login interactive shells (Linux terminals) read directly.
[ -f ~/.bashrc ] && . ~/.bashrc
