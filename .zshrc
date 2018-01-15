# ZSH DIRECTORY
export ZSH=~/.oh-my-zsh

# DEFAULT EDITOR
export VISUAL=vim
export EDITOR="$VISUAL"

# THEME
ZSH_THEME="bullet-train"
BULLETTRAIN_PROMPT_CHAR="→"
#BULLETTRAIN_CUSTOM_MSG="λ"
BULLETTRAIN_PROMPT_ORDER=(
  time
  status
  #custom
  context
  dir
  #screen
  #virtualenv
  git
  cmd_exec_time
)

# IN-CASESENSITIVE COMMAND SEARCHING
CASE_SENSITIVE="false"

# AUTO COMMAND CORRECTION
ENABLE_CORRECTION="true"

# HISTORY
SAVEHIST=100
HISTSIZE=50

# COMPLETION LOADING INDICATOR
# [DISABLED, BECAUSE THIS CAUSES BULLETTRAIN TO DISAPPEAR]
#COMPLETION_WAITING_DOTS="true"

# LOADED PLUGINS
plugins=(
  git
  fast-syntax-highlighting
  zsh-autosuggestions
)

# RUN EXTRA FILES
source $ZSH/oh-my-zsh.sh
source $ZSH/custom/keys.sh

# SOME ALIASES
alias pipes="~/Documents/pipes.sh"
alias python=python3

# CUSTOM X CLIPBOARD
# copy
xccopy() {
    all=""
    for var in "$@"
    do
        all=($all $var)
    done
    echo $all | xclip -selection c
}
alias copy="xccopy"
# paste
xcpaste() {
    echo $(xclip -selection c -o)
}
alias paste="xcpaste"

# CUSTOM CD (CD & LS)
c() {
	cd $1;
	ls;
}
alias cd="c"

# CUSTOM MKDIR (MKDIR & CD)
mkcd() {
	mkdir $1;
	cd $1;
}
alias mkdir="mkcd"

# DOCKER ALWAYS RUN WITH SUDO
alias docker="sudo docker"

# GOOGLE FUNCTION
function google() { 
    all=""
    for var in "$@"
    do
        all=($all $var)
    done
	xdg-open "http://www.google.com/search?q=$all" &; 
}

# FUZZY HISTORY CMD SEARCHING [ARR-UP]
if [[ "${terminfo[kcuu1]}" != "" ]]; then
	autoload -U up-line-or-beginning-search
	zle -N up-line-or-beginning-search
	bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# FUZZY HISTORY CMD SEARCHING [ARR-UP]
if [[ "${terminfo[kcud1]}" != "" ]]; then
	autoload -U down-line-or-beginning-search
	zle -N down-line-or-beginning-search
	bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# GREETING
source $ZSH/custom/greet.sh

