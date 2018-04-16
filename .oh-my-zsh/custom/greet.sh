#!/bin/bash
# Script to print greeting to user in the center of the console window

hour=$(date +"%H")

if [ $hour -ge 0 -a $hour -lt 12 ]
then
    text="Good Morning, $USER"
elif [ $hour -ge 12 -a $hour -lt 18 ]
then
    text="Good Afternoon, $USER"
else
    text="Good evening, $USER"
fi

COLUMNS=$(tput cols)
echo
echo
printf "%*s\n" $(((${#text}+$COLUMNS)/2)) "$text"

