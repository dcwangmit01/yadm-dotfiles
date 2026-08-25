# Login shell chain: ~/.bash_profile (here) -> ~/.bashrc -> ~/.profile.
# Login shells (macOS terminals, ssh, tty) get here first and defer entirely
# to ~/.bashrc, which non-login interactive shells (Linux terminals) read
# directly; ~/.bashrc in turn sources ~/.profile for PATH/env (idempotent,
# safe at any nesting depth).
[ -f ~/.bashrc ] && . ~/.bashrc
