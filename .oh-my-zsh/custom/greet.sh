#!/bin/bash

text="Good morning, $(whoami)."
length=${#text}

half=$(tput cols)
half=$(($half / 2 - $length / 2))
i="0"
echo ""		# Make newline at start
echo ""		# Make newline at start


while [ $i -lt $half ]
do
	printf " "
	i=$[$i+1]
done

echo "$indent $text"
