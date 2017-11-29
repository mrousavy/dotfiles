# ZSH DIRECTORY
export ZSH=/home/mrousavy/.oh-my-zsh

# THEME
ZSH_THEME="bullet-train"

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

# CUSTOM CD (CD & LS)
c() {
	cd $1;
	ls;
}
alias cd="c"

# GOOGLE FUNCTION
function google() { 
	chromium "http://www.google.com/search?q= $1" &; 
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

