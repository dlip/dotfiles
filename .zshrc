export PATH=~/bin:~/.local/bin:~/.nix-profile/bin:~/go/bin:~/.docker/bin:~/.docker/cli-plugins:/Applications/Docker.app/Contents/Resources/bin:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:/Applications/Ollama.app/Contents/Resources:$PATH
export EDITOR=nvim
export XDG_DATA_DIRS=~/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS

if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
if [ -e ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . ~/.nix-profile/etc/profile.d/hm-session-vars.sh; fi

if [ -e "$HOME/.brew/bin/brew" ]; then
  eval "$($HOME/.brew/bin/brew shellenv)"
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

if [ -e ~/.zshrc.local ]; then . ~/.zshrc.local; fi
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/dane.lipscombe/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
