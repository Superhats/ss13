#!/bin/sh
xterm -title "Server Console" -e "love server --quit-on-disconnect" &
xterm -title "Client Console" -e "love client --connect 127.0.0.1:6788"
