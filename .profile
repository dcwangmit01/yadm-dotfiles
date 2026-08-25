# ~/.profile — POSIX sh, sourced by login shells (sh/dash/bash) and by
# ~/.bashrc (for non-login interactive + non-interactive bash, e.g. `ssh host cmd`).
# Owns PATH and environment. Idempotent: every step below is guarded so
# re-sourcing in a nested shell is a no-op / order-preserving.
# Must NOT source ~/.bashrc (would create a cycle via the .bashrc -> .profile link).

# brew shellenv evals path_helper, which REBUILDS PATH (brew first, prior
# entries appended) — re-running in nested shells would reorder our prepends
# behind brew. HOMEBREW_PREFIX is exported by shellenv itself, so it doubles
# as the once-per-lineage guard (and saves a path_helper fork per shell).
[ -n "$HOMEBREW_PREFIX" ] || {
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$b" ] && { eval "$("$b" shellenv)"; break; }
  done
}

# prepend: our own tooling wins over system binaries (last-listed ends first)
for d in "$HOME/.local/bin" "$HOME/Dev/claude-custom/bin"; do
  [ -d "$d" ] || continue
  case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH";; esac
done

# append: fallbacks only
for d in "$HOME/bin" "$HOME/.bin"; do
  [ -d "$d" ] || continue
  case ":$PATH:" in *":$d:"*) ;; *) PATH="$PATH:$d";; esac
done

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"   # internally PATH-guarded

export PATH
unset b d
