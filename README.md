# dotfiles

Personal development environment for Ubuntu 26.04.

## Packages

- Desktop: hyprland (hypridle, hyprlock), waybar, dunst
- Launcher: vicinae
- Terminal / shell: ghostty, nushell, starship, zellij
- Editors: helix, neovim, zed
- Tools: yazi, lazygit, leaf-markdown-viewer, k9s, kubectl, Terraform, bat, fzf, ripgrep
- Browser: brave
- Fonts: Yeomil Mono Nerd Font, D2Coding Nerd Font and Noto Sans CJK
- Package managers: brew, asdf
- Languages: Node.js via Homebrew; other versions managed separately with asdf

## Usage

Ubuntu Desktop may not include curl. Install it first:

```nu
sudo apt install -y curl
```

Then run:

```nu
curl -fsSL https://raw.githubusercontent.com/hoongeun/dotfiles/main/ubuntu.sh | sh
```

The script clones this repository to `~/workspace/git/dotfiles` if it is absent.
If it already exists, its current files are used without pulling or changing it.

The installer uses sudo, installs Homebrew and the packages above, and
overwrites matching files under `~/.config`. Review the configuration before
running it. Git identity and credentials are not installed.
It always runs `ubuntu-drivers install`, which installs Ubuntu's recommended
drivers for the detected hardware (e.g. NVIDIA) and does nothing when none are
missing. Reboot if the installer asks for it.
Zed is installed with Homebrew when it is not already available. On Ubuntu,
the official Vicinae installer downloads and extracts its AppImage.

On the first Hyprland login, hyprpm builds and enables the matching hy3 plugin.
IBus Hangul uses Shift+Space to switch input. Replace
`~/.config/hypr/wallpaper.jpg` to change the wallpaper.

Ghostty starts Nushell with the migrated aliases; `tf` runs Terraform and `yy`
returns to the directory selected in Yazi.

## Optional VM

The `Vagrantfile` uses the `vagrant-qemu` plugin and an Ubuntu 26.04 Desktop
qcow2 image with a `vagrant` user, SSH access, and sudo. Set
`UBUNTU_DESKTOP_IMAGE` and `VAGRANT_SSH_KEY` to the image and SSH key before
running `vagrant up --provider qemu`. Their default paths are under
`~/.local/share/vagrant/`. The provider creates an overlay; the checkout is
not shared or provisioned automatically. SSH is bound to localhost; set
`VAGRANT_VM_SSH_PORT` if port 50022 is in use.
