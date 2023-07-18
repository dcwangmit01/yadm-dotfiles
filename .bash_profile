#####################################################################
# Globals
system_type=$(uname -s)

# aliases
alias emacs='emacs -nw'
alias gits='gits --no-master'
alias k=kubectl
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
# SSH-AGENT

if true; then
  # if [ "$system_type" = "Darwin" ]; then
  # Dev machine (OSX)
  # Ensure an ssh-agent is running
  SSH_ENV="$HOME/.ssh/agent-environment"

  function start_agent {
      echo "Initialising new SSH agent..."
      /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
      echo succeeded
      chmod 600 "${SSH_ENV}"
      . "${SSH_ENV}" > /dev/null
      /usr/bin/ssh-add;
  }

  # Source SSH settings, if applicable
  if [ -f "${SSH_ENV}" ]; then
      . "${SSH_ENV}" > /dev/null
      ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
          start_agent;
      }
  else
      start_agent;
  fi
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
  for bash_include_file in $(find /opt/homebrew -name *.bash.inc); do
      source $bash_include_file
  done
fi

# Brew Java
if [ -d /usr/local/opt/java/bin ]; then
    export PATH=/usr/local/opt/java/bin:$PATH
    export JAVA_HOME=/usr/local/opt/java
fi

# for golang
# export GOPATH=/go
# export PATH=$PATH:$GOPATH/bin:./bin/linux_amd64/:./vendor/bin:

# Enable pyenv
#   Search home directory first and then system, allow pyenv
#     installed in home to override that of system
#   KDK has system pyenv installed in /usr/local
if [[ -d "$HOME/.pyenv/bin" ]]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
elif [[ -d "/usr/local/pyenv/bin" ]]; then
    export PATH="/usr/local/pyenv/bin:$PATH"
    export PYENV_ROOT="/usr/local/pyenv"
fi
if  [[ -n ${PS1:-''} ]] && which pyenv &>/dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

###############################################################################
# Load hooks

# for direnv; only if interactive shell and direnv is installed
if [[ -n ${PS1:-''} ]] && which direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# for hub alias; only if interactive shell and hub is installed
if [[ -n ${PS1:-''} ]] && which hub &>/dev/null; then
    eval "$(hub alias -s)"
fi

#####################################################################
# bash-profile extra configs in Keybase and local mount

# Search for an execute an extra bash profile stored in keybase
for kd in /keybase /Volumes/Keybase; do
  if [[ -d $kd/private ]]; then
    # Find this current user's private directory (any dir without a comma in it)
    user_private_dir=$(ls $kd/private |grep -v ',')
    private_bash_profile="$kd/private/$user_private_dir/.bash_profile_private"
    if [[ -f "$private_bash_profile" ]]; then
      echo "Executing additional bash profile $private_bash_profile"
      source $private_bash_profile
    fi
  fi
done

# Search for an extra bash profile in potential host-mounted locations
for extra_bash_profile in "$HOME/.bash_profile_private" "$HOME/.config/kdk/.bash_profile_private"; do
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

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
