@echo off
start "" "C:\Program Files\LOVE\love" server --quit-on-disconnect
start "" "C:\Program Files\LOVE\love" client --connect 127.0.0.1:6788
