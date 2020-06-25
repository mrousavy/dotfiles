#!/bin/sh

# Copy .configs to git dotconfig
cp ~/.config/kwinrc .config/
cp ~/.zshrc ./
cp ~/.vimrc ./
cp ~/.oh-my-zsh/custom/greet.sh .oh-my-zsh/custom/
cp ~/.oh-my-zsh/custom/keys.sh .oh-my-zsh/custom/
cp ~/.oh-my-zsh/themes/mrousavy.zsh-theme .oh-my-zsh/themes/
cp ~/.local/share/konsole/zsh.profile .local/share/konsole/
cp ~/.gitignore ./.gitignore-custom

