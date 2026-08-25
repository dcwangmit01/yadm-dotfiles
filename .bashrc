# ~/.bashrc — canonical interactive-bash config, yadm-tracked, shared by Linux + macOS.
# Non-login shells (Linux terminals) read it directly; login shells (macOS terminals,
# ssh, tty) get here via the ~/.bash_profile stub. PATH/env live in ~/.profile,
# sourced below (idempotent, safe at any nesting depth). Host-specific config goes
# in ~/.bashrc.local, secrets in ~/.secrets (both git-ignored, sourced at the end).
# Must stay bash 3.2-safe (macOS system /bin/bash).

# PATH/env, above the interactive guard so non-interactive shells (ssh host cmd) get it too.
[ -r ~/.profile ] && . ~/.profile

# If not running interactively, don't do anything further.
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it; check window size after each command
shopt -s histappend checkwinsize

HISTSIZE=100000
HISTFILESIZE=200000
PROMPT_COMMAND='history -a'

# --- prompt ---
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|alacritty*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# --- colors (detected, not OS-switched) ---
# assumes: `ls --color=auto` exiting 0 ⇒ ls actually colorizes
# (holds for GNU ls and Apple/BSD ls here)
if ls --color=auto -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  command -v dircolors >/dev/null && eval "$(dircolors -b)"
else
  export CLICOLOR=1
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# --- completion ---
for f in /usr/share/bash-completion/bash_completion /etc/bash_completion \
         "${HOMEBREW_PREFIX:-/nonexistent}/etc/profile.d/bash_completion.sh"; do
  [ -r "$f" ] && { . "$f"; break; }
done
if [ -n "$HOMEBREW_PREFIX" ]; then
  for f in "$HOMEBREW_PREFIX"/etc/*.bash.inc "$HOMEBREW_PREFIX"/etc/*/*.bash.inc; do   # gcloud
    [ -r "$f" ] && . "$f"
  done
fi
export BASH_SILENCE_DEPRECATION_WARNING=1

# --- aliases / env ---
alias emacs='emacs -nw'
alias less='less -R'
export EDITOR=emacs
passwordgen() { LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c "${1:-32}"; echo; }
alias passwordgenhex="hexdump -vn16 -e'4/4 \"%08X\" 1 \"\n\"' /dev/urandom"

# --- hooks / completions, each only if the tool is installed ---
command -v direnv  >/dev/null && eval "$(direnv hook bash)"
command -v kubectl >/dev/null && . <(kubectl completion bash)
if command -v fzf >/dev/null; then
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"   # fzf >= 0.48 (brew)
  else                     # older distro fzf (Debian 0.44): first shipped file found, no network
    for f in /usr/share/doc/fzf/examples/key-bindings.bash "$HOME/.fzf/key-bindings.bash"; do
      [ -r "$f" ] && { . "$f"; break; }
    done
    for f in /usr/share/bash-completion/completions/fzf "$HOME/.fzf/completion.bash"; do   # distro first: ~/.fzf may be a newer master download
      [ -r "$f" ] && { . "$f"; break; }
    done
  fi
fi

# reopen detached tmux sessions, one alacritty window each
tma() {
  local tmux_bin
  tmux_bin=$(command -v tmux)
  for s in $("$tmux_bin" list-sessions -F '#S #{session_attached}' | awk '$2==0 {print $1}'); do
    alacritty msg create-window -e "$tmux_bin" attach -t "$s"
  done
}

# --- extension points (git-ignored): secrets, host-local config ---
for f in "$HOME/.secrets" "$HOME/.bashrc.local"; do
  [ -r "$f" ] && . "$f"
done
unset f
