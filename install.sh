#!/bin/bash

# SCRIPT TO INSTALL MY IMPORTANT DOTFILES AND PLUGINS TO USER DIR (RUN WITH SUDO)

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root (use 'su root' or 'sudo')" 1>&2
	exit 1
fi

# Update sources
apt update
apt upgrade

# Install Reqired packages
apt install wmctrl git build-essential cmake python3 python3-dev python-dev #zsh

#### ZSH ####

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Zsh-Autosuggestions
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions

# Zsh-Syntax Highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/custom/plugins/zsh-syntax-highlighting

# Zsh-Bullet Train theme
curl https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -o $ZSH/custom/themes/bullet-train.zsh-theme

# Backup old .zshrc
mv ~/.zshrc ~/.zshrc_backup
# Copy over .zshrc
cp .zshrc ~/.zshrc
# Update for now
source ~/.zshrc

# Backup old .vimrc
mv ~/.vimrc ~/.vimrc_backup
# Copy over .vimrc
cp .vimrc ~/.vimrc


#### VIM PLUGINS ####

# Pathogen Vim
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# NERDTree
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree

# YouCompleteMe
cd ~/.vim/bundle
git clone https://github.com/Valloric/YouCompleteMe.git
cd YouCompleteMe
git submodule update --init --recursive
./install.py --clang-completer --cs-completer

# SurroundMe
cd ~/.vim/bundle
git clone git://github.com/tpope/vim-surround.git

# FugitiveVim (Git)
cd ~/.vim/bundle
git clone https://github.com/tpope/vim-fugitive.git


#### KDE ####

# Copy over custom scripts
cp .oh-my-zsh/custom/greet.sh ~/.oh-my-zsh/custom/greet.sh
cp .oh-my-zsh/custom/keys.sh ~/.oh-my-zsh/custom/keys.sh
cp run-focus /usr/local/bin/run-focus && chmod a+x /usr/local/bin/run-focus

# Copy over Konsole settings [KDE]
cp .local/share/konsole/zsh.profile ~/.local/share/konsole/zsh.profile
cp .config/konsolerc ~/.config/konsolerc

# Copy over KWin settings [KDE]
cp .config/kwinrc ~/.config/kwinrc

