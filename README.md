# nix-flocke

My NixOS Configuration

Based on <https://gitlab.com/hmajid2301/nixicle>

## 💽 Usage

<details>
  <summary>Install</summary>

To install NixOS on any of my devices I now use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere/blob/main/docs/howtos/no-os.md).
You will need to be able to SSH to the target machine from where this command will be run. Load nix installer ISO if
no OS on the device. You need to copy ssh keys onto the target machine
`mkdir -p ~/.ssh && curl https://github.com/danielpieper.keys > ~/.ssh/authorized_keys` in my case I can copy them from GitHub.

```bash
git clone git@github.com:danielpieper/nix-flocke.git ~/nix-flocke/
cd nix-flocke

nix develop

nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'

nixos-anywhere --flake '.#tars' nixos@192.168.X.X -i ~/.ssh/id_ed25519
```

After building it you can copy the ISO from the `result` folder to your USB.
Then run `nix_installer`, which will then ask you which host you would like to install.

</details>

### Building

To build my config for a specific host you can do something like:

```bash
git clone git@github.com:danielpieper/nix-flocke.git ~/nix-flocke/
cd nix-flocke

nix develop

# To build system configuration (uses hostname to build flake)
nh os switch

# To build user configuration (uses hostname and username to build flake)
nh home switch

# Build ISO in result/ folder
nix build .#install-isoConfigurations.graphical
nix build .#install-isoConfigurations.minimal

# Deploy my to remote server i.e. Home Lab (using SSH)
deploy .#hal --hostname hal --ssh-user nixos --skip-checks
```

## 🚀 Features

Some features of my config:

- Structured to allow multiple **NixOS configurations**, including **desktop**, **laptop** and **homelab**
- **Custom** live ISO for installing NixOS
- **Styling** with stylix
- **Opt-in persistance** through impermanence + blank snapshot
- **Encrypted BTRFS partition**
- **sops-nix** for secrets management
- Different environments like **hyprland** and **gnome**
- Homelab all configured in nix.

## Appendix

### Inspired By

- Based on <https://gitlab.com/hmajid2301/nixicle>
- Snowfall config: <https://github.com/jakehamilton/config?tab=readme-ov-file>
- More snowfall config: <https://github.dev/khaneliman/khanelinix/blob/f4f4149dd8a0fda1c01fa7b14894b2bcf5653572/flake.nix>
- My original structure and nixlang code: <https://github.com/Misterio77/nix-config>
- Waybar & scripts: <https://github.dev/yurihikari/garuda-sway-config>
- Neovim UI: <https://github.com/NvChad/nvchad>
- README: <https://github.com/notohh/snowflake/tree/master>
- README table: <https://github.com/wimpysworld/nix-config>
