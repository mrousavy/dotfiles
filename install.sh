#!/bin/bash

# SCRIPT TO INSTALL MY IMPORTANT DOTFILES AND PLUGINS TO USER DIR

which sudo &>/dev/null
[ $? -eq 0 ] && echo "sudo found. Starting install.sh..." || (echo "sudo is not installed! Please install sudo." && read && exit 1)

#### APT ####

read -p "Do you want to install required packages via apt? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Update sources
    sudo apt update
    sudo apt upgrade

    # Install Reqired packages
    sudo apt install curl wmctrl git build-essential cmake python3 python3-dev python3-pip zsh
fi

#### ZSH ####

read -p "Do you want to install Zsh themes, scripts and plugins? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Installing Oh-my-zsh, please exit Zsh after install. Press Enter to continue..."
    read
    echo "Preparing.."

    # Install Oh-My-Zsh
    TEST_CURRENT_SHELL="zsh"   # Prevent zsh launch
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # Zsh-Autosuggestions
    git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

    # Zsh-Syntax Highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    # Zsh-Bullet Train theme
    mkdir ~/.oh-my-zsh/custom/themes
    curl https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -o ~/.oh-my-zsh/custom/themes/bullet-train.zsh-theme

    # Copy over custom scripts
    cp .oh-my-zsh/custom/greet.sh ~/.oh-my-zsh/custom/greet.sh
    cp .oh-my-zsh/custom/keys.sh ~/.oh-my-zsh/custom/keys.sh

    # Backup old .zshrc
    mv ~/.zshrc ~/.zshrc_backup
    # Copy over .zshrc
    cp .zshrc ~/.zshrc
    # Update for now (only required if using zsh)
    source ~/.zshrc

    # Backup old .vimrc
    mv ~/.vimrc ~/.vimrc_backup
    # Copy over .vimrc
    cp .vimrc ~/.vimrc

    echo "Zsh install done. You might want to check out Powerline fonts so your terminal doesn't look bugged: https://github.com/powerline/fonts"
fi

#### VIM PLUGINS ####

read -p "Do you want to install Vim configuration, plugins and themes? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Pathogen Vim
    mkdir -p ~/.vim/autoload ~/.vim/bundle
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    # NERDTree
    git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree

    # YouCompleteMe
    read -p "Do you want to install YouCompleteMe for Vim? (Requires Vim 8.0 with Python support, check with vim --version) [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        cd ~/.vim/bundle
        git clone https://github.com/Valloric/YouCompleteMe.git
        cd YouCompleteMe
        git submodule update --init --recursive
        ./install.py --clang-completer
    fi

    # SurroundMe
    cd ~/.vim/bundle
    git clone git://github.com/tpope/vim-surround.git

    # FugitiveVim (Git)
    cd ~/.vim/bundle
    git clone https://github.com/tpope/vim-fugitive.git

    # Vim Powerline Theme
    #cd ~/.vim/bundle
    #git clone https://github.com/lokaltog/vim-powerline
    git clone https://github.com/itchyny/lightline.vim ~/.vim/bundle/lightline.vim
fi


#### KDE ####

read -p "Do you want to install KDE, Konsole and KWin configurations and scripts? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Copy over custom scripts
    cp run-focus /usr/local/bin/run-focus && chmod a+x /usr/local/bin/run-focus

    # Copy over Konsole settings [KDE]
    cp .local/share/konsole/zsh.profile ~/.local/share/konsole/zsh.profile
    cp .config/konsolerc ~/.config/konsolerc

    # Copy over KDE
    cp .kde/share/config/kdeglobals ~/.kde/share/config/kdeglobals

    # Copy over KWin settings [KDE]
    cp .config/kwinrc ~/.config/kwinrc
fi
