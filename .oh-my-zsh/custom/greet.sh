#!/bin/bash
# Script to print greeting to user in the center of the console window

hour=$(date +"%H")

if [ $hour -ge 0 -a $hour -lt 12 ]
then
    text="good morning, $USER. 🌅"
elif [ $hour -ge 12 -a $hour -lt 18 ]
then
    text="good afternoon, $USER. ☀️"
else
    text="good evening, $USER. 🌙"
fi

COLUMNS=$(tput cols)
echo
printf "%*s\n" $(((${#text}+$COLUMNS)/2)) "$text"

