#!/bin/sh
# Print a red SWAP indicator when macOS is paging to swap; silent otherwise.
sysctl -n vm.swapusage 2>/dev/null | awk '
  {
    u = $6
    sub(/M$/, "", u)
    if (u + 0 > 0) printf "#[fg=colour196,bold]SWAP %.1fG#[default] ", (u + 0) / 1024
  }'
