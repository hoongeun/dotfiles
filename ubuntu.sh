# !/bin/sh

sudo add-apt-repository ppa:kelleyk/emacs
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
sudo apt-get update
sudo apt install -y git ripgrep emacs27 openssh curl fish bat tmux i3 flameshot conky build-essential
cd
git clone https://github.com/hoongeun/dotfiles

# termite
cd ~/dotfiles/downloads
sudo apt install -y git g++ libgtk-3-dev gtk-doc-tools gnutls-bin valac intltool libpcre2-dev libglib3.0-cil-dev libgnutls28-dev libgirepository1.0-dev libxml2-utils gperf
git clone https://github.com/thestinger/vte-ng.git
echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH"
cd vte-ng
./autogen.sh
make && sudo make install
cd ~/dotfiles/downloads
git clone --recursive https://github.com/thestinger/termite.git
cd termite
make
sudo make install
sudo ldconfig
sudo mkdir -p /lib/terminfo/x
sudo ln -s /usr/local/share/terminfo/x/xterm-termite /lib/terminfo/x/xterm-termite
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/termite 60

# doom
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install
~/.emacs.d/bin/doom sync

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
curl -o vscodium.tar.gz https://github.com/VSCodium/vscodium/releases/download/1.52.1/VSCodium-linux-arm64-1.52.1.tar.gz
tar -xzf vscodium.tar.gz

# overwrite
cp -rf ~/dotfiles/home/.* ~/
sudo cp -rf ~/dotfiles/etc/* /etc/
sudo cp -rf ~/dotfiles/usr/* /usr/
sudo fc-cache -f -v
rm -rf ~/dotfiles
sudo reboot
