#!/bin/bash

file=$(mktemp).dump
tmux capture-pane -pS -20000 >$file
tmux new-window -n "tmp/scrollback" "$EDITOR '+ normal G $' $file"
