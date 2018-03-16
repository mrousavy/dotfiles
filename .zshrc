# ZSH DIRECTORY
export ZSH=~/.oh-my-zsh

# DEFAULT EDITOR
export VISUAL=vim
export EDITOR="$VISUAL"

# THEME
ZSH_THEME="bullet-train"
BULLETTRAIN_PROMPT_CHAR="→"
#BULLETTRAIN_CUSTOM_MSG="λ"
if [ -z ${MINIMAL_THEME+x} ]
then
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
else
    BULLETTRAIN_PROMPT_ORDER=(
      status
      dir
    )
fi
if ! [ -z ${LIGHT_THEME+x} ]
then
    BULLETTRAIN_TIME_BG="black"
    BULLETTRAIN_TIME_FG="white"
    BULLETTRAIN_CONTEXT_BG="white"
    BULLETTRAIN_CONTEXT_FG="black"
    BULLETTRAIN_DIR_BG="cyan"
    BULLETTRAIN_DIR_FG="white"
fi

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
alias pip=pip3
if ! hash code 2>/dev/null; then
    alias code=code-insiders
fi

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
    if [ $? -eq 0 ]; then
	    ls;
    fi
}
alias cd="c"

# CUSTOM MKDIR (MKDIR & CD)
mkcd() {
	mkdir $1;
	cd $1;
}
alias mkdir="mkcd"

pullall() {
    echo "Pulling all git subdirectories.."
    ls | xargs -P10 -I{} git -C {} pull
}

# DOCKER ALWAYS RUN WITH SUDO (disabled because autocompletion)
#alias docker="sudo docker"
#alias docker-compose="sudo docker-compose"

# SCREENKEY COMMAND
alias sk="killall screenkey &>/dev/null || screenkey"

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

# TODO: REMOVE, ONLY FOR SCHOOL
alias sew="xdg-open ~/School/SEW/"
alias insy="xdg-open ~/School/INSY/"
alias syt="xdg-open ~/School/SYT/"

