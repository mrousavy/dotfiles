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

# Keep the prompt compact; the palette below follows macOS appearance.
PROMPT='%1~ › '
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

# A minimal Apple-inspired palette: blue accents, gray secondary text,
# soft green strings, and red errors. Command input stays bold.
_dotfiles_refresh_theme() {
  emulate -L zsh
  local appearance=${1:-$(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null)}
  [[ $appearance == Dark ]] || appearance=Light
  [[ ${_dotfiles_theme_appearance:-} == $appearance ]] && return 0
  typeset -g _dotfiles_theme_appearance=$appearance

  local blue gray green red style
  if [[ $appearance == Dark ]]; then
    blue='#64A8FF' gray='#9A9AA0' green='#8EC99A' red='#FF8585'
  else
    blue='#0067D9' gray='#6E6E73' green='#357642' red='#C23B3B'
  fi

  # Keep the folder secondary, with a single blue prompt accent.
  PROMPT="%F{$gray}%1~%f %F{$blue}›%f "
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$gray"

  # Blue folders in completion menus; reverse colors mark the selected item.
  local blue_ansi="38;2;$((16#${blue[2,3]}));$((16#${blue[4,5]}));$((16#${blue[6,7]}))"
  zstyle ':completion:*' list-colors "di=$blue_ansi" 'ma=7'

  if (( $+parameters[ZSH_HIGHLIGHT_STYLES] )); then
    # Use neutral text as the base so unrelated syntax doesn't become a rainbow.
    for style in ${(k)ZSH_HIGHLIGHT_STYLES}; do
      [[ -n ${ZSH_HIGHLIGHT_STYLES[$style]} ]] && ZSH_HIGHLIGHT_STYLES[$style]='fg=default,bold'
    done
    for style in arg0 alias suffix-alias global-alias builtin function command \
                 hashed-command precommand autodirectory reserved-word globbing \
                 history-expansion command-substitution-delimiter \
                 process-substitution-delimiter back-quoted-argument-delimiter; do
      ZSH_HIGHLIGHT_STYLES[$style]="fg=$blue,bold"
    done
    for style in single-quoted-argument double-quoted-argument dollar-quoted-argument; do
      ZSH_HIGHLIGHT_STYLES[$style]="fg=$green,bold"
    done
    ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$red,bold"
    ZSH_HIGHLIGHT_STYLES[comment]="fg=$gray,bold"
    ZSH_HIGHLIGHT_STYLES[path]='fg=default,bold,underline'
  fi
}

# Refresh before each prompt; update styles only when appearance changes.
# Re-sourcing this file also reapplies the palette immediately.
unset _dotfiles_theme_appearance
_dotfiles_refresh_theme
add-zsh-hook precmd _dotfiles_refresh_theme
