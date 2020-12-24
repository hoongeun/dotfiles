# !/bin/bash

startsudo() {
    sudo -v
    ( while true; do sudo -v; sleep 50; done; ) &
    SUDO_PID="$!"
    trap stopsudo SIGINT SIGTERM
}
stopsudo() {
    kill "$SUDO_PID"
    trap - SIGINT SIGTERM
    sudo -k
}

startsudo
sudo apt -qq update
sudo apt install -qqy git curl fish tmux i3 flameshot conky build-essential autoconf ranger caca-utils highlight atool w3m poppler-utils mediainfo bison
cd
git clone --depth 1 https://github.com/hoongeun/dotfiles

echo "===================================="
echo "[done]: ubuntu stuff"
echo "===================================="

# polybar
sudo apt install -qqy \
  cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
  libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev \
  libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
  xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev \
  libiw-dev libcurl4-openssl-dev libpulse-dev \
  libxcb-composite0-dev xcb libxcb-ewmh2
cd ~/dotfiles/downloads
git clone --depth 1 https://github.com/jaagr/polybar.git -b 3.5.3
cd polybar
./build.sh 2> /dev/null

echo "===================================="
echo "[done]: polybar"
echo "===================================="

# termite
cd ~/dotfiles/downloads
sudo apt install -qqy git g++ libgtk-3-dev gtk-doc-tools gnutls-bin valac intltool libpcre2-dev libglib3.0-cil-dev libgnutls28-dev libgirepository1.0-dev libxml2-utils gperf
git clone --depth 1 https://github.com/thestinger/vte-ng.git
echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH"
cd vte-ng
./autogen.sh 2> /dev/null && make -j 2> /dev/null && sudo make install 2> /dev/null
cd ~/dotfiles/downloads
git clone --depth 1 --recursive https://github.com/thestinger/termite.git
cd termite
make -j 2> /dev/null && sudo make install
sudo ldconfig
sudo mkdir -p /lib/terminfo/x
sudo ln -s /usr/local/share/terminfo/x/xterm-termite /lib/terminfo/x/xterm-termite
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/termite 60

echo "===================================="
echo "[done]: termite"
echo "===================================="
# emcas27
cd ~/dotfiles/downloads
sudo apt install -qqy texinfo libxaw7-dev libxpm-dev libjpeg-dev libgif-dev libtiff-dev libgnutls28-dev libncurses-dev
git clone --depth 1 https://git.savannah.gnu.org/git/emacs.git -b emacs-27
cd emacs
./autogen.sh 2> /dev/null && ./configure 2> /dev/null && make -j 2> /dev/null && sudo make install

echo "===================================="
echo "[done]: emacs"
echo "===================================="

# ripgrep
cd ~/dotfiles/downloads
curl -o ripgrep.deb -sL https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
sudo dpkg -i ripgrep.deb 2> /dev/null

# fd
curl -o fd.deb -sL https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_amd64.deb
sudo dpkg -i fd.deb 2> /dev/null

# doom
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install 2> /dev/null
cp -rf ~/dotfiles/home/.doom.d ~/
~/.emacs.d/bin/doom sync

echo "===================================="
echo "[done]: doom"
echo "===================================="


# starship
curl -fsSL https://starship.rs/install.sh | bash
echo "eval \"\$(starship init bash)\"" >> ~/.bashrc
echo "starship init fish | source" >> ~/.config/fish/config.fish
chsh -s /usr/local/bin/fish

echo "===================================="
echo "[done]: starship"
echo "===================================="

# workspace
mkdir -p ~/workspace/git
mkdir -p ~/workspace/local

echo "===================================="
echo "[done]: workspace"
echo "===================================="

# nodejs
## make cache folder (if missing) and take ownership
sudo mkdir -p /usr/local/n
sudo chown -R $(whoami) /usr/local/n
## take ownership of node install destination folders
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
bash n lts
npm install -g yarn && yarn global add guser

echo "===================================="
echo "[done]: nodejs"
echo "===================================="

# go
curl -sSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
. "$HOME/.gvm/scripts/gvm"
gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.15.5
gvm use go1.15.5 --default
echo "gvm use go1.15.5" >> ~/.bashrc

echo "===================================="
echo "[done]: go"
echo "===================================="

# python
sudo apt install -qqy python-dev libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libffi-dev
cd ~/dotfiles/downloads/
curl -sSL -o python.tgz https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tgz
tar -xzf python.tgz
cd Python-3.9.1
./configure 2> /dev/null
make -j 2> /dev/null
sudo make install 2> /dev/null
curl https://bootstrap.pypa.io/get-pip.py | python3
rm -rf /workspace/local/Python-3.9.1*

echo "===================================="
echo "[done]: python"
echo "===================================="

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none
. "$HOME/.cargo/env"

echo "===================================="
echo "[done]: rust"
echo "===================================="

# bat
cd ~/dotfiles/downloads
curl -o bat.deb -sSL https://github.com/sharkdp/bat/releases/download/v0.17.1/bat_0.17.1_amd64.deb
sudo dpkg -i bat.deb 2> /dev/nul

echo "===================================="
echo "[done]: bat"
echo "===================================="

# git
git config --global user.name "Hoongeun Cho"
git config --global usre.email "me@hoongeun.com"

echo "===================================="
echo "[done]: git"
echo "===================================="

# docker
curl -fsSL https://get.docker.com | sh 2> /dev/null

echo "===================================="
echo "[done]: docker"
echo "===================================="

# typora
curl -sSL https://typora.io/linux/public-key.asc | sudo apt-key add -
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt -qq update
sudo apt install -qqy typora

echo "===================================="
echo "[done]: typora"
echo "===================================="

# tmux
cd
git clone --depth 1 https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

echo "===================================="
echo "[done]: tmux"
echo "===================================="

# albert
curl -sSL https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add -
echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
sudo -sSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_20.04/Release.key -O "/etc/apt/trusted.gpg.d/home:manuelschneid3r.asc"
sudo apt -qq update
sudo apt install -qqy albert

echo "===================================="
echo "[done]: albert"
echo "===================================="

# chrome
cd ~/dotfiles/downloads
curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o chrome.deb
sudo dpkg -i chrome.deb 2> /dev/null

echo "===================================="
echo "[done]: google chrome"
echo "===================================="

# vscodium
cd ~/dotfiles/downloads
curl -o vscodium.deb -sSL https://github.com/VSCodium/vscodium/releases/download/1.52.1/codium_1.52.1-1608165473_amd64.deb
sudo dpkg -i vscodium.deb 2> /dev/null

echo "===================================="
echo "[done]: vscodium"
echo "===================================="

# overwrite
cp -rf ~/dotfiles/home/.* ~/
sudo cp -rf ~/dotfiles/etc/* /etc/
sudo cp -rf ~/dotfiles/usr/* /usr/
sudo fc-cache -f -v

echo "===================================="
echo "[done]: all done"
echo "===================================="

#done
rm -rf ~/dotfiles
sudostop
sudo reboot
