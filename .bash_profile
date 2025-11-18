#####################################################################
# Globals
system_type=$(uname -s)

# aliases
alias emacs='emacs -nw'
alias gits='gits --no-master'
alias passwordgen='cat /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c${1:-32};echo;'
alias passwordgenhex="hexdump -vn16 -e'4/4 \"%08X\" 1 \"\n\"' /dev/urandom"

if [ "$system_type" = "Darwin" ]; then
  # Enable OSX color
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
  alias less='less -R'
fi

#####################################################################
# OSX Configs

# Add to path if paths exist and aren't already in $PATH (mostly for OSX brew components)
potential_bin_dirs=( \
  ~/bin \
  # for brew gnu-sed (required for kubernetes build) \
  /usr/local/opt/gnu-sed/libexec/gnubin \
  # for brew gnu-tar (required for kubernetes build) \
  /usr/local/opt/gnu-tar/libexec/gnubin \
)
for potential_bin_dir in "${potential_bin_dirs[@]}"; do
  if [[ -d "$potential_bin_dir" ]] && ! echo $PATH | grep "$potential_bin_dir" &>/dev/null; then
    export PATH=$PATH:$potential_bin_dir
  fi
done

# Google Cloud
if [ -d /opt/homebrew ]; then
  for bash_include_file in $(find /opt/homebrew/etc -name *.bash.inc); do
      source $bash_include_file
  done
fi


###############################################################################
# Load hooks

# for direnv; only if interactive shell and direnv is installed
if [[ -n ${PS1:-''} ]] && which direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

#####################################################################
# Search for an extra bash profile in potential host-mounted locations
#  May be used for Google Drive
for extra_bash_profile in "$HOME/.bash_profile_private"; do
    if [[ -f "$extra_bash_profile" ]]; then
      echo "Executing additional bash profile $extra_bash_profile"
      source $extra_bash_profile
    fi
done

#####################################################################
# Enable bash completion for debian based distros
if [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

#####################################################################
# Enable kubectl completion

if [[ -n ${PS1:-''} ]] && which kubectl &>/dev/null; then
    source <(kubectl completion bash)
fi

#####################################################################
# Enable kops completion

if [[ -n ${PS1:-''} ]] && which kops &>/dev/null; then
    source <(kops completion bash)
fi

#####################################################################
# Enable fzf completion

if which fzf &>/dev/null; then
    if [ ! -d ~/.fzf ]; then
	mkdir -p ~/.fzf
    fi
    for f in key-bindings.bash completion.bash; do
	if [ ! -f ~/.fzf/$f ]; then
	    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/shell/$f > ~/.fzf/$f
	fi
	source ~/.fzf/$f
    done
fi

#####################################################################
# Load .bashrc if present

if [[ -f .bashrc ]]; then
    source .bashrc
fi

export EDITOR=emacs
