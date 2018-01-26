#!/bin/bash

COLUMNS=$(tput cols)
echo
echo
text="Good morning, $(whoami)."
printf "%*s\n" $(((${#text}+$COLUMNS)/2)) "$text"

