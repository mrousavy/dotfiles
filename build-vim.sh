#!/bin/sh

# Apt repo
sudo apt update
sudo apt upgrade
sudo apt install -f
sudo apt install build-essential cmake

# Install required libs
sudo apt install libncurses5-dev libgnome2-dev libgnomeui-dev \
	    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
		    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
			    python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git

# Remove Vim
sudo apt remove vim vim-runtime gvim vim-tiny vim-common vim-gui-common vim-nox

# Clone Vim
cd ~
git clone https://github.com/vim/vim.git
cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-pythoninterp=yes \
            --with-python-config-dir=/usr/lib/python2.7/config \
            --enable-python3interp=yes \
            --with-python3-config-dir=/usr/lib/python3.5/config \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local
make VIMRUNTIMEDIR=/usr/local/share/vim/vim80

# Build Vim
cd ~/vim
sudo make install

# Build Vim (Alternative)
#sudo apt install checkinstall
#cd ~/vim
#sudo checkinstall

# Default editor
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
sudo update-alternatives --set editor /usr/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
sudo update-alternatives --set vi /usr/bin/vim

# Print output
vim --version

echo Done.
