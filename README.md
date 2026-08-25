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

### Shell chain

Login shells (macOS terminals, ssh, tty) start at [`.bash_profile`](.bash_profile),
a stub that sources [`.bashrc`](.bashrc); non-login interactive shells (Linux
terminals) read `.bashrc` directly. Either way, `.bashrc` sources
[`.profile`](.profile) — above its own interactive guard, so non-interactive
invocations (`ssh host cmd`) get it too. `.profile` owns `PATH` and environment
and is idempotent, safe to source at any nesting depth:

```
login shell → .bash_profile → .bashrc → .profile (PATH/env)
                                  │
                     non-login interactive shell also lands here
```

### `.local` extension points

These git-ignored files, sourced/included where noted, hold anything
machine- or person-specific:

* `~/.secrets` — `export` lines for tokens; sourced by `.bashrc`. Create with
  `install -m 600 /dev/null ~/.secrets`
* `~/.bashrc.local` — host-specific shell config (library paths, agent sockets);
  sourced by `.bashrc`
* `~/.ssh/config.local` — machine-local ssh config (e.g. an `IdentityAgent`);
  `Include`d by `.ssh/config`
* `~/.gitconfig.local` — your identity and any machine-local git config;
  `include`d by `.gitconfig`

`.bashrc`/`.secrets`/`.bashrc.local` are sourced on **every** interactive
shell, so keep them to `export`s and function definitions — no one-shot setup
commands. `.bashrc` and `.inputrc` are tracked: on a machine that already has
local versions, move their custom lines into `~/.bashrc.local` first, then
`yadm checkout -- .bashrc .inputrc` (a `yadm reset --hard` would discard them).

### Example: `~/.bashrc.local` and `~/.gitconfig.local`

```
# ~/.bashrc.local
export HOMEBREW_GITHUB_API_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

```
# ~/.gitconfig.local
[user]
	name = First Last
	email = email@domain.com
```

### colima caveat

colima re-adds `Include $HOME/.colima/ssh_config` to the tracked
`~/.ssh/config` if it can't find that line there. To keep the tracked file
clean, that `Include` line lives in `~/.ssh/config.local` instead — colima
finds it and leaves the tracked file alone.
