# yadm-dotfiles

This dotfile repo uses the
[yadm](https://thelocehiliosan.github.io/yadm/docs/overview) tool in order to
provision and configure dotfiles on a system.

## Usage

Prerequisite: [`yadm`
installation](https://thelocehiliosan.github.io/yadm/docs/install)

```
# Get the Dotfiles onto the system
yadm clone git@github.com:dcwangmit01/yadm-dotfiles.git

# If the clone results in warnings because of pre-existing dotfiles, overwrite
#   the existing files.
yadm reset --hard HEAD

# Check for changes in your local dotfiles
yadm diff

# Commit changes back to the repo
yadm add -u :/
yadm commit -m "The description of changes"
yadm push
```

## Customizing your setup

Shell startup is one shared, portable file: [`.bashrc`](.bashrc) (Linux + macOS;
OS deltas live in a single `Darwin` case). `.bash_profile` is a stub that sources
it, so login and non-login shells behave identically. At the end, `.bashrc` sources
these git-ignored extension points if they exist, in order:

* `$HOME/.secrets` — `export` lines for tokens; create with `install -m 600 /dev/null ~/.secrets`
* `$HOME/.bashrc.local` — host-specific config (library paths, agent sockets)
* `$HOME/.bash_profile_private` — legacy private-profile hook

These are sourced on **every** interactive shell, so keep them to `export`s / functions
(no one-shot setup commands). `.bashrc` and `.inputrc` are tracked: on a machine that
already has local versions, move their custom lines into `~/.bashrc.local` first, then
`yadm checkout -- .bashrc .inputrc` (a `yadm reset --hard` would discard them).

One may customize their own private settings by creating any of the files above.  Here is an example of what the content could look like.

```
# OSX brew, to get around API limits
export HOMEBREW_GITHUB_API_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Github
git config --global user.name "First Last"
git config --global user.email email@domain.com

###############################################################################
# AWS Custom Configurations

## AWS config file
cat << 'EOF' > ~/.aws/config
[profile project-foo]
output = json
region = us-west-1

[profile project-bar]
output = json
region = us-west-1
EOF

## AWS credentials file
cat << 'EOF' > ~/.aws/credentials
[project-foo]
aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

[project-bar]
aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
EOF
###############################################################################
```
