export PATH=~/bin:~/.local/bin:~/.docker/bin:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:/Applications/Ollama.app/Contents/Resources:$PATH
export EDITOR=nvim

if $IS_NIX; then
  if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
else
  eval "$($HOME/.brew/bin/brew shellenv)"
  export HOMEBREW_NO_INSTALL_FROM_API=1
  export HOMEBREW_NO_AUTO_UPDATE=1
  export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/mysql-client@8.4/lib"
  export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/mysql-client@8.4/include"
  export PKG_CONFIG_PATH="${HOMEBREW_PREFIX}/opt/mysql-client@8.4/lib/pkgconfig"
fi

# yazi - keep current dir when exiting
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

source ~/.antidote/antidote.zsh
antidote load
# Autocomplete config
# https://github.com/marlonrichert/zsh-autocomplete?tab=readme-ov-file#reassign-keys
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select
bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
bindkey -M menuselect '^M' .accept-line
bindkey -M menuselect '\e' send-break

bindkey '^[e' edit-command-line

set -o emacs
alias e="$EDITOR"

