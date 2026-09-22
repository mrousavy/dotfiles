# Prefer Homebrew's Vim and tools on Apple silicon or Intel Macs.
if [[ -z ${HOMEBREW_PREFIX:-} ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    export HOMEBREW_PREFIX=/opt/homebrew
  elif [[ -x /usr/local/bin/brew ]]; then
    export HOMEBREW_PREFIX=/usr/local
  fi
fi
if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  typeset -U path
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)
fi

autoload -Uz add-zsh-hook

# List all files/folders (ls) after a cd
list_after_cd() {
  ls
}
add-zsh-hook chpwd list_after_cd

# Shortcut .. to cd ..
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Remove ignored Git files (including build outputs); this is destructive.
# Optionally set HOLYCLEAN_SOUND in ~/.zshrc.local to play a local audio file.
holyclean() {
  if [[ -n ${HOLYCLEAN_SOUND:-} && -r $HOLYCLEAN_SOUND ]]; then
    afplay "$HOLYCLEAN_SOUND" &>/dev/null &!
  fi
  git clean -dfX
}

# Theme
PROMPT=$'%f%{\e[2m%}%1~%{\e[22m%} › '
RPROMPT=''

# Centered greeting for new interactive terminals.
if [[ -o interactive && -t 1 ]]; then
  () {
    emulate -L zsh
    setopt multibyte
    local period emoji greeting
    local -i hour=10#${(%):-%D{%H}}
    local -i padding width

    if (( hour >= 5 && hour < 12 )); then
      period=morning emoji=🌅
    elif (( hour >= 12 && hour < 17 )); then
      period=afternoon emoji=🌞
    elif (( hour >= 17 && hour < 22 )); then
      period=evening emoji=🌇
    else
      period=night emoji=🌙
    fi

    greeting="Good ${period}, ${USERNAME}. ${emoji}"
    width=${(m)#greeting}
    padding=$(( (COLUMNS - width) / 2 ))
    (( padding < 0 )) && padding=0
    printf '\n%*s%s\n\n' "$padding" '' "$greeting"
  }
fi

# Bold only the editable command line, not command output.
zle_highlight=("${(@)zle_highlight:#default:*}" 'default:bold')

# Case-insensitive Tab completion.
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Highlight the selected completion; navigate with Tab or arrow keys.
zmodload zsh/complist
zstyle ':completion:*' menu select
# Reverse foreground/background for a visible selection in light and dark modes.
zstyle ':completion:*' list-colors 'ma=7'

# Keep machine-specific settings and secrets out of the repository.
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# Suggest commands from history; Right Arrow accepts the suggestion.
if [[ -r ${HOMEBREW_PREFIX:-}/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Load syntax highlighting after other plugins and line-editor bindings.
if [[ -r ${HOMEBREW_PREFIX:-}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Preserve bold command input alongside syntax colors.
() {
  local style
  for style in ${(k)ZSH_HIGHLIGHT_STYLES}; do
    case ${ZSH_HIGHLIGHT_STYLES[$style]} in
      none) ZSH_HIGHLIGHT_STYLES[$style]=bold ;;
      '') ;; # Empty styles inherit their parent style.
      *bold*) ;;
      *) ZSH_HIGHLIGHT_STYLES[$style]+=,bold ;;
    esac
  done
}
