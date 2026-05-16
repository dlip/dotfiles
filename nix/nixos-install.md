# NixOS Install

## Installation

Boot into the NixOS graphical installer, connect to the network and open the terminal:

Format the disk with [disko](https://github.com/nix-community/disko)

```sh
# Get the disko config
curl -OL https://raw.githubusercontent.com/dlip/dotfiles/refs/heads/main/nix/systems/disko.nix
# Find the root block device
lsblk
# Configure the filesystems and ensure the main device matches
vim disko.nix
# Format
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /disko.nix
```

Clone the configuration repository:

```sh
sudo -s
mkdir /mnt/root
cd /mnt/root
git clone https://github.com/dlip/dotfiles.git
cd dotfiles/nix
```

Set the system host name (replace foo with desired name)

```sh
export HOST=foo
```

Copy the new system template

```sh
cp -r systems/new systems/$HOST
nixos-generate-config --show-hardware-config --root /mnt > systems/$HOST/hardware-configuration.nix
git add systems/$HOST
```


Add the host to the bottom of the nixos modules eg. `// (mkHost { hostname = "foo"; })`

```sh
vim modules/nixos.nix
```

Install NixOS then reboot

```sh
nixos-install --flake ..#$HOST
reboot
```

## Setup dotfiles

Log in with password 'password', connect to the network and open a terminal

Install the dotfiles with changes to the current user

```sh
sudo rsync -av --chown=$(whoami):users /root/dotfiles/ .
git submodule update --init
```

Open a new shell and commit and push the changes

```sh
git commit -am 'install host'
git push
```

Enter github credentials, username 'pat' and use the generated token from here with repo access https://github.com/settings/tokens 

Test nixos config

```
nixosconfig
```

## Setup SOPS

If not using sshd generate keyfile

```sh
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
mkdir -p ~/.config/sops/age
sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | tee -a ~/.config/sops/age/keys.txt | age-keygen -y
```


On an existing machine, add public key to .sops.yaml and update keys in the common secrets

```sh
sops updatekeys systems/common/secrets/secrets.yaml
```

Create secrets

```sh
touch systems/<HOSTNAME>/secrets.yaml
sops systems/<HOSTNAME>/secrets.yaml
```

Generate wireguard key

```
wg genkey | tee /dev/tty | wg pubkey
```

Add the first line as `wireguard-key` in hosts secret file and add the second line to the peers in `systems/dex/configuration.nix`
