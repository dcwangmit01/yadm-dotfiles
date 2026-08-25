# --- PATH: add dirs that exist and aren't already present (this file re-runs in nested shells) ---
# prepend: our own tooling wins over system binaries
for d in "$HOME/.local/bin" "$HOME/Dev/claude-custom/bin"; do
  [ -d "$d" ] || continue
  case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH";; esac
done
# append: fallbacks only — on macOS BSD sed/tar keep winning over brew gnubin (scripts call gsed/gtar explicitly)
for d in "$HOME/bin" "$HOME/.bin" \
         /opt/homebrew/opt/gnu-sed/libexec/gnubin /opt/homebrew/opt/gnu-tar/libexec/gnubin \
         /usr/local/opt/gnu-sed/libexec/gnubin  /usr/local/opt/gnu-tar/libexec/gnubin; do
  [ -d "$d" ] || continue
  case ":$PATH:" in *":$d:"*) ;; *) PATH="$PATH:$d";; esac
done
# ~/.bashrc — canonical interactive-bash config, yadm-tracked, shared by Linux + macOS.
# Non-login shells (Linux terminals) read it directly; login shells (macOS terminals,
# ssh, tty) get here via the ~/.bash_profile stub. OS deltas live in the single Darwin
# case below; host-specific config goes in ~/.bashrc.local, secrets in ~/.secrets
# (both git-ignored, sourced at the end). Lines up to the completion block are the
# stock Debian body — every Debian-specific bit is file-exists-guarded, inert elsewhere.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color|alacritty*) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|alacritty*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#####################################################################
# Shared config (portable). Keep OS-specific lines inside the Darwin case only.

# --- Darwin-only deltas ---
case "$(uname -s)" in
  Darwin)
    alias ls='ls -G'   # the dircolors block above is skipped on macOS (no /usr/bin/dircolors)
    export BASH_SILENCE_DEPRECATION_WARNING=1
    for f in /opt/homebrew/etc/profile.d/bash_completion.sh /usr/local/etc/profile.d/bash_completion.sh \
             /opt/homebrew/etc/*.bash.inc /opt/homebrew/etc/*/*.bash.inc /usr/local/etc/*.bash.inc /usr/local/etc/*/*.bash.inc; do   # brew bash-completion, gcloud
      [ -r "$f" ] && . "$f"
    done
    ;;
esac

# --- PATH: prepend if the dir exists and isn't already present (re-runs in nested shells) ---
for d in "$HOME/.local/bin" "$HOME/bin" "$HOME/.bin" "$HOME/Dev/claude-custom/bin" \
         /opt/homebrew/opt/gnu-sed/libexec/gnubin /opt/homebrew/opt/gnu-tar/libexec/gnubin \
         /usr/local/opt/gnu-sed/libexec/gnubin  /usr/local/opt/gnu-tar/libexec/gnubin; do
  [ -d "$d" ] || continue
  case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH";; esac
done
export PATH
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"   # internally PATH-guarded

# --- aliases / env ---
alias emacs='emacs -nw'
alias gits='gits --no-master'
alias less='less -R'
alias passwordgen='cat /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c${1:-32};echo;'
alias passwordgenhex="hexdump -vn16 -e'4/4 \"%08X\" 1 \"\n\"' /dev/urandom"
export EDITOR=emacs

# --- hooks / completions, each only if the tool is installed ---
command -v direnv  >/dev/null && eval "$(direnv hook bash)"
command -v kubectl >/dev/null && . <(kubectl completion bash)
command -v kops    >/dev/null && . <(kops completion bash)
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

# --- extension points (all git-ignored): secrets, host-local config, private profile ---
for f in "$HOME/.secrets" "$HOME/.bashrc.local" "$HOME/.bash_profile_private"; do
  [ -f "$f" ] && . "$f"
done
unset d f
