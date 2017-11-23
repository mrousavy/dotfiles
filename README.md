## My personal minimalistic dotfiles
The install script will only work if you have **zsh** installed & initialized, and **KDE Konsole** installed.

### Install
First you'll need zsh and vim:
```sh
sudo apt update && sudo apt install zsh vim && zsh
```

Download and run the install script:
```sh
git clone http://github.com/mrousavy/dotfiles
cd dotfiles
sudo ./install.sh
```

### Screenshots
![Zsh Screenshot](https://github.com/mrousavy/dotfiles/raw/master/screenshot-zsh.png)

![Vim Screenshot](https://github.com/mrousavy/dotfiles/raw/master/screenshot-vim.png)

### Contents

* KDE Konsole profile and config
* Zsh configuration (`~/.zshrc`)
* Vim configuration (`~/.vimrc`)
* Oh-My-Zsh custom key-bindings (`~/.oh-my-zsh/custom/keys.sh`)
* Oh-My-Zsh custom greeting script (`~/.oh-my-zsh/custom/greet.sh`)
* Zsh-Theme (`~/.oh-my-zsh/themes`)

