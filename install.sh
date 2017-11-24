#!/bin/bash

# SCRIPT TO INSTALL MY IMPORTANT DOTFILES AND PLUGINS TO USER DIR (RUN WITH SUDO)

# Update sources
#apt update
#apt upgrade

# Install Zsh
#apt install zsh

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

# Backup old .vimrc
mv ~/.vimrc ~/.vimrc_backup
# Copy over .vimrc
cp .vimrc ~/.vimrc

# Copy over custom scripts
cp .oh-my-zsh/custom/greet.sh ~/.oh-my-zsh/custom/greet.sh
cp .oh-my-zsh/custom/keys.sh ~/.oh-my-zsh/custom/keys.sh
cp run-focus /usr/local/bin/run-focus && chmod a+x /usr/local/bin/run-focus

# Copy over Konsole settings [KDE]
cp .local/share/konsole/zsh.profile ~/.local/share/konsole/zsh.profile
cp .config/konsolerc ~/.config/konsolerc

# Copy over KWin settings [KDE]
cp .config/kwinrc ~/.config/kwinrc

