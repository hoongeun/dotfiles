# !/bin/sh

sudo apt update
sudo apt install -y git curl fish tmux i3 flameshot conky build-essential ranger caca-utils highlight atool w3m poppler-utils mediainfo 
cd
git clone https://github.com/hoongeun/dotfiles

# polybar
sudo apt-get install -y \
  cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
  libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev \
  libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
  xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev \
  libiw-dev libcurl4-openssl-dev libpulse-dev \
  libxcb-composite0-dev xcb libxcb-ewmh2
cd ~/dotfiles/downloads
git clone https://github.com/jaagr/polybar.git
cd polybar
git tag # see what version do you need
git checkout 3.5.3
./build.sh

# termite
cd ~/dotfiles/downloads
sudo apt install -y git g++ libgtk-3-dev gtk-doc-tools gnutls-bin valac intltool libpcre2-dev libglib3.0-cil-dev libgnutls28-dev libgirepository1.0-dev libxml2-utils gperf
git clone https://github.com/thestinger/vte-ng.git
echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH"
cd vte-ng
./autogen.sh
make -j && sudo make install
cd ~/dotfiles/downloads
git clone --recursive https://github.com/thestinger/termite.git
cd termite
make -j
sudo make install
sudo ldconfig
sudo mkdir -p /lib/terminfo/x
sudo ln -s /usr/local/share/terminfo/x/xterm-termite /lib/terminfo/x/xterm-termite
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/termite 60

# emcas27
cd ~/dotfiles/downloads
sudo apt install -y texinfo libxpm-dev libjpeg-dev libgif-dev libtiff-dev libgnutls28-dev
git clone https://git.savannah.gnu.org/git/emacs.git
git checkout emacs-27
./autogen.sh
./configure
make -j
sudo make install

# ripgrep
cd ~/dotfiles/downloads
curl -o ripgrep.deb -s https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
sudo dpkg -i ripgrep.deb

# fd
curl -o fd.deb -s https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_amd64.deb
sudo dpkg -i fd.deb

# doom                        
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install
cp -rf ~/dotfiles/home/.doom.d ~/
~/.emacs.d/bin/doom sync

## ripgrep
curl -os 

# starship
curl -fsSL https://starship.rs/install.sh | bash
echo "eval \"\$(starship init bash)\"" >> ~/.bashrc
echo "starship init fish | source" >> ~/.config/fish/config.fish
chsh -s /usr/local/bin/fish

# workspace
mkdir -p ~/workspace/git
mkdir -p ~/workspace/local

# nodejs
curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
bash n lts
npm install -g yarn
yarn global add guser 

# go
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.15.5
gvm use go1.15.5 --default

# python
sudo apt install -y build-essential python-dev libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libffi-dev
cd ~/dotfiles/downloads/
curl -sSL -o python.tgz https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tgz
tar -xvf python.tgz
cd Python-3.9.1
./configure
make -j
sudo make install
curl https://bootstrap.pypa.io/get-pip.py | python3
rm -rf /workspace/local/Python-3.9.1*

# bat
cd ~/dotfiles/downloads
curl -o bat.deb https://github.com/sharkdp/bat/releases/download/v0.17.1/bat_0.17.1_arm64.deb
sudo dpkg -i bat.deb

# git
git config --global user.name "Hoongeun Cho"
git config --global usre.email "me@hoongeun.com"

# docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# typora
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt update
sudo apt install typora

# tmux
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

# albert
curl -sSL https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add -
echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
sudo -sSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_20.04/Release.key -O "/etc/apt/trusted.gpg.d/home:manuelschneid3r.asc"
sudo apt update
sudo apt install albert

# chrome
curl -sSL -O-https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add-
sudo sh -c 'echo "deb [arch = amd64] http://dl.google.com/linux/chrome/deb/ stable main">> /etc/apt/sources.list.d/google-chrome.list '
sudo apt update
sudo apt install google-chrome-stable

# vscodium
cd ~/dotfiles/downloads
curl -o vscodium.deb https://github.com/VSCodium/vscodium/releases/download/1.52.1/codium_1.52.1-1608165473_amd64.deb
sudo dpkg -i vscodium.deb

# overwrite
cp -rf ~/dotfiles/home/.* ~/
sudo cp -rf ~/dotfiles/etc/* /etc/
sudo cp -rf ~/dotfiles/usr/* /usr/
sudo fc-cache -f -v
rm -rf ~/dotfiles
sudo reboot
