# GOTO HOME DIR
function goto_home() {
	BUFFER="cd ~/"
	zle end-of-line
	zle accept-line
}
zle -N goto_home
bindkey "^h" goto_home

# ADD SUDO
function add_sudo() {
	BUFFER="sudo "$BUFFER
	zle end-of-line
}
zle -N add_sudo
bindkey "^s" add_sudo

# EXPLORER HERE
function explorer_here() {
    open . &
}
zle -N explorer_here
bindkey "^e" explorer_here

