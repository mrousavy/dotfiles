export ZSH="/Users/mrousavy/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

export VISUAL=vim
export EDITOR="$VISUAL"
ZSH_THEME="mrousavy"

# IN-CASESENSITIVE COMMAND SEARCHING
CASE_SENSITIVE="false"

# AUTO COMMAND CORRECTION
ENABLE_CORRECTION="true"

# HISTORY
SAVEHIST=100
HISTSIZE=50

# LOADED PLUGINS
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

# RUN EXTRA FILES
source $ZSH/oh-my-zsh.sh
source $ZSH/custom/keys.sh

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

# UGLY GIT DRIVE BY COMMIT
alias gitdriveby='git add --all; git commit -m "$(curl -s http://whatthecommit.com/index.txt )"; git push'


# CD UP SCRIPT
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../../"
alias .....="cd ../../../.."

# GOOGLE FUNCTION
function google() {
    all=""
    for var in "$@"
    do
        all=($all $var)
    done
	open "http://www.google.com/search?q=$all" &;
}

# MOV TO GIF FUNCTION
function togif() {
    local fps="${2:-15}"
    local width="${3:-400}"
    echo "Creating color palette..."
    ffmpeg -i $1 -vframes 1 -vf scale="$width":-1 /tmp/snippet.jpg
    ffmpeg -i /tmp/snippet.jpg -vf palettegen /tmp/palette.png
    echo "Converting $1 with $fps fps at $width px..."
    ffmpeg -i $1 -i /tmp/palette.png -filter_complex "fps="$fps",scale=w="$width":h=-1:flags=lanczos[x];[x][1:v]paletteuse" $1.gif
    echo "Optimizing GIF..."
    gifsicle -O3 $1.gif -o $1.gif
    rm /tmp/snippet.jpg
    rm /tmp/palette.png
}

# FUZZY HISTORY CMD SEARCHING [ARR-UP]
if [[ "${terminfo[kcuu1]}" != "" ]]; then
	autoload -U up-line-or-beginning-search
	zle -N up-line-or-beginning-search
	bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# FUZZY HISTORY CMD SEARCHING [ARR-DOWN]
if [[ "${terminfo[kcud1]}" != "" ]]; then
	autoload -U down-line-or-beginning-search
	zle -N down-line-or-beginning-search
	bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# GREETING
source $ZSH/custom/greet.sh
function clean() {
    clear
    source $ZSH/custom/greet.sh
}

# PATH
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/flutter/bin

alias git-rm-untracked="git add . && git commit -m 'Remove ignored files 1/2' && git rm -r --cached . && git add . && git commit -am 'Remove ignored files 2/2'"

alias code="code-insiders"
