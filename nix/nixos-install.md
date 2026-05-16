# NixOS Install

Boot into the NixOS installer and get a shell:

```sh
sudo -s
# Optional: connect to wifi
# wpa_cli device wifi connect 'SSID' password='PASSWORD'
```

Clone the configuration repository:

```sh
git clone https://github.com/dlip/dotfiles.git
cd dotfiles/nix
```

Copy the new system template (replace foo with the hostname)

```sh
cp systems/new systems/foo
```

Use vim to edit the contents of `systems/foo/*.nix`

Format the disk and mount it using `disko`. Edit the `disko-template.nix` file to match your disk device (e.g., `/dev/nvme0n1`):

```sh
vim nix/disko-template.nix # update `device = "/dev/nvme0n1";`
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko nix/disko-template.nix
```

You will be prompted to enter a LUKS passphrase for encryption.

Generate hardware configuration:

```sh
nixos-generate-config --root /mnt
```

Set up the new host configuration:

```sh
export HOST=new-machine
mkdir -p nix/systems/$HOST
cp /mnt/etc/nixos/hardware-configuration.nix nix/systems/$HOST/
```

Create the system configuration:

```sh
vim nix/systems/$HOST/configuration.nix
```

```nix
{ config, pkgs, ... }:

{
  networking.hostName = "new-machine";
  # Enable wifi
  networking.networkmanager.enable = true;

  users.users.dane = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
    git
  ];
}
```

Update `flake.nix` by copying an existing `nixosConfigurations` entry, replace the host name with the new one, and remove the `sops` import if not yet set up.

```sh
vim flake.nix
```

Install the system:

```sh
git add .
nixos-install --flake .#$HOST
reboot
```

Setup SOPS

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
