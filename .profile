if [ -d "/nix" ]; then
  export IS_NIX=true
  if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
  if [ -e /etc/profiles/per-user/dane/etc/profile.d/hm-session-vars.sh ]; then . /etc/profiles/per-user/dane/etc/profile.d/hm-session-vars.sh; fi
else
  export IS_NIX=false
