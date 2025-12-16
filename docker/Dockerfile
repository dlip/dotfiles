FROM alpine:latest

# Install Nix and dependencies
# 'nix': The package manager itself (available in Alpine community repos)
# 'gcompat': The glibc compatibility layer so Nix binaries can run
# 'git': Required if you plan to use Nix Flakes
# 'bash': Many Nix build scripts expect bash
RUN apk add --no-cache nix gcompat git zsh

RUN mkdir -p /etc/nix && \
  echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
  echo "sandbox = false" >> /etc/nix/nix.conf

WORKDIR /root
ENV USER=root

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && \
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && \
  nix-channel --update

RUN nix-shell '<home-manager>' -A install
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

RUN git clone https://github.com/dlip/dotfiles.git && \
  mv dotfiles/.git . && \
  git reset --hard && \
  git submodule update --init

CMD ["zsh"]
