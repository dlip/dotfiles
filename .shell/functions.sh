# yazi - keep current dir when exiting
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# view a CSV as a Markdown table in the pager
csv() {
	csv2md "$@" | less -S
}

force_terminal_reset() {
  # 1. \ec : Reset to Initial State (RIS)
  # 2. \e[?1u : Turn off extended keyboard protocols (Kitty/CSI u)
  # 3. \e[?1000l ... \e[?1006l : Turn off all mouse tracking modes
  # 4. \e[?1049l : Exit alternate screen buffer (if stuck in an app view)
  printf '\ec\e[?1u\e[?1000l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l\e[?1049l'

  # Clear the screen and redraw the zsh prompt cleanly
  zle clear-screen
  zle reset-prompt
}
