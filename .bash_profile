#####################################################################
# Globals
system_type=$(uname -s)

# aliases
alias emacs='emacs -nw'
alias gits='gits --no-master'
alias k=kubectl
alias passwordgen='cat /dev/urandom | LC_CTYPE=C tr -dc A-Za-z0-9 | head -c${1:-32};echo;'

if [ "$system_type" = "Darwin" ]; then
  # Enable OSX color
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
  alias less='less -R'
fi

#####################################################################
# SSH-AGENT

if [ "$system_type" = "Darwin" ]; then
  # Dev machine (OSX)
  # Modern OSX starts an ssh-agent automatically
  #   https://www.dribin.org/dave/blog/archives/2007/11/28/ssh_agent_leopard/
  # Add the user's default key
  ssh-add -l 2>&1| grep "The agent has no identities" &>/dev/null && ssh-add &>/dev/null
fi

#####################################################################
# OSX Configs

# Add to path if paths exist and aren't already in $PATH (mostly for OSX brew components)
potential_bin_dirs=( \
  ~/bin \
  # for brew \
  /usr/local/bin \
  /usr/local/sbin \
  # for golang \
  /usr/local/opt/go/libexec/bin \
  /usr/local/go/bin \
  # for protocol buffers \
  /usr/local/protoc/bin \
  # for terraform
  /usr/local/terraform/bin \
  # for brew gnu-sed (required for kubernetes build) \
  /usr/local/opt/gnu-sed/libexec/gnubin \
  # for brew gnu-tar (required for kubernetes build) \
  /usr/local/opt/gnu-tar/libexec/gnubin \
  # for gnu emacs \
  /usr/local/opt/emacs/bin \
  # for openssl \
  /usr/local/opt/openssl/bin \
  # for curl \
  /usr/local/Cellar/curl/7.54.1/bin \
  # for gcloud, kubectl
  /usr/local/google-cloud-sdk/bin \
  # for ruby rvm
  ~/.rvm/bin \
  # for graphviz
  /usr/local/opt/graphviz/bin \
  # for java
  /usr/local/opt/java/bin \
)
for potential_bin_dir in "${potential_bin_dirs[@]}"; do
  if [[ -d "$potential_bin_dir" ]] && ! echo $PATH | grep "$potential_bin_dir" &>/dev/null; then
    export PATH=$PATH:$potential_bin_dir
  fi
done

# for brew java
if [ -d /usr/local/opt/java/bin ]; then
    export PATH=/usr/local/opt/java/bin:$PATH
    export JAVA_HOME=/usr/local/opt/java
fi

# for golang
export GOPATH=/go
export PATH=$PATH:$GOPATH/bin:./bin/linux_amd64/:./vendor/bin:

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

# Enable pulumi
if [[ -d "$HOME/.pulumi/bin" ]]; then
    export PATH="$HOME/.pulumi/bin:$PATH"
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
