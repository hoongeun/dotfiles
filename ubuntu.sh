#!/bin/sh
{
set -eu

if ! grep -qx 'ID=ubuntu' /etc/os-release || ! grep -qx 'VERSION_ID="26.04"' /etc/os-release; then
    echo "Ubuntu 26.04 is required." >&2
    exit 1
fi

DOTFILES="$HOME/workspace/git/dotfiles"
BREW_BIN=/home/linuxbrew/.linuxbrew/bin/brew
TEMP_DIR="$(mktemp -d)"
cleanup() {
    rm -f "$TEMP_DIR/homebrew.sh" "$TEMP_DIR/vicinae.sh" "$TEMP_DIR/brave.sh" "$TEMP_DIR/plug.vim" "$TEMP_DIR/hyprpm.toml" \
        "$TEMP_DIR/yeomil.zip" "$TEMP_DIR/yeomil-Regular.ttf" "$TEMP_DIR/yeomil-Bold.ttf" "$TEMP_DIR/yeomil-Light.ttf"
    rmdir "$TEMP_DIR"
}
trap cleanup EXIT

sudo apt-get update
sudo apt-get install -y git curl jq fish build-essential procps file unzip pciutils ubuntu-drivers-common

# Installs any recommended hardware drivers (GPU, Wi-Fi, ...); no-op when none are missing.
sudo ubuntu-drivers install
HAS_NVIDIA=false
if lspci | grep -iE '(VGA|3D|Display).*NVIDIA' >/dev/null; then
    HAS_NVIDIA=true
fi
mkdir -p "$HOME/workspace/git" "$HOME/workspace/local"
if [ ! -d "$DOTFILES/.git" ]; then
    git clone https://github.com/hoongeun/dotfiles.git "$DOTFILES"
fi

if [ ! -x "$BREW_BIN" ]; then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$TEMP_DIR/homebrew.sh"
    env -i HOME="$HOME" USER="$USER" PATH="$PATH" NONINTERACTIVE=1 bash "$TEMP_DIR/homebrew.sh"
fi
eval "$("$BREW_BIN" shellenv)"
export PATH="$HOME/.local/bin:$HOME/.asdf/shims:$PATH"

brew install nushell starship bat fzf ripgrep fd gh git-delta git-lfs gdu tree node \
    neovim helix zellij yazi lazygit lazydocker leaf-markdown-viewer asdf k9s kubernetes-cli \
    hashicorp/tap/terraform
if ! command -v zed >/dev/null 2>&1; then
    brew install --cask zed
fi

sudo apt-get install -y hyprland hyprland-dev hypridle hyprlock waybar dunst swaybg \
    ghostty network-manager-gnome policykit-1-gnome ibus ibus-hangul wl-clipboard xclip \
    grim slurp brightnessctl nautilus zenity fonts-noto-cjk libpango1.0-dev libgles-dev \
    clangd clang-format cmake cpio pkg-config ninja-build

# Ubuntu's hyprpm uses packaged headers but does not initialize their ABI state.
HYPRPM_STATE="/var/cache/hyprpm/$(id -un)/state.toml"
if [ -f /usr/share/pkgconfig/hyprland.pc ] && [ ! -f "$HYPRPM_STATE" ]; then
    HYPRLAND_ABI="$(Hyprland --version-json | jq -er '.abiHash | select(type == "string" and length > 0)')"
    case "$HYPRLAND_ABI" in *[!A-Za-z0-9_.-]*) exit 1 ;; esac
    printf '[state]\nhash = "%s"\ndont_warn_install = false\n' "$HYPRLAND_ABI" > "$TEMP_DIR/hyprpm.toml"
    sudo install -d -m 755 "$(dirname "$HYPRPM_STATE")"
    sudo install -m 644 "$TEMP_DIR/hyprpm.toml" "$HYPRPM_STATE"
fi

mkdir -p "$HOME/.local/bin"
curl -fsSL https://vicinae.com/install.sh -o "$TEMP_DIR/vicinae.sh"
env -i HOME="$HOME" USER="$USER" PATH="$PATH" TERM=xterm PREFIX="$HOME/.local" bash "$TEMP_DIR/vicinae.sh" --prefix "$HOME/.local"
curl -fsSL https://dl.brave.com/install.sh -o "$TEMP_DIR/brave.sh"
env -i HOME="$HOME" USER="$USER" PATH="$PATH" sh "$TEMP_DIR/brave.sh"

mkdir -p "$HOME/workspace/git" "$HOME/workspace/local" "$HOME/.config"
cp -r "$DOTFILES/home/.config/." "$HOME/.config/"
if [ "$HAS_NVIDIA" = true ]; then
    cat > "$HOME/.config/hypr/gpu.conf" <<'EOF'
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
cursor {
    no_hardware_cursors = true
}
EOF
fi
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o "$TEMP_DIR/plug.vim"
    install -Dm644 "$TEMP_DIR/plug.vim" "$HOME/.local/share/nvim/site/autoload/plug.vim"
fi
nvim --headless '+PlugInstall --sync' '+qa'
sudo mkdir -p /usr/local/share/fonts
sudo cp -r "$DOTFILES/usr/local/share/fonts/." /usr/local/share/fonts/
curl -fsSL https://github.com/taevel02/yeomil-mono/releases/download/v1.1.2/YeomilMono-NerdFont-TTF.zip -o "$TEMP_DIR/yeomil.zip"
mkdir -p "$HOME/.local/share/fonts"
for weight in Regular Bold Light; do
    unzip -p "$TEMP_DIR/yeomil.zip" "YeomilMonoNerdFont-$weight.ttf" > "$TEMP_DIR/yeomil-$weight.ttf"
    install -m 644 "$TEMP_DIR/yeomil-$weight.ttf" "$HOME/.local/share/fonts/YeomilMonoNerdFont-$weight.ttf"
done
sudo fc-cache -f
fc-cache -f

echo "Installation complete. Matching ~/.config files were overwritten."
echo "Hyprland will install hy3 on its first login."
if [ -f /var/run/reboot-required ]; then
    echo "Reboot required (e.g. new drivers) before starting Hyprland."
fi
}
