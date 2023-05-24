#!/bin/sh
tmux new-window -t FULLORUST:2 -n 'FULLO2-NPM' 'cd ~/work/rust/fullo-rust/fullo-app;npm run startro'
tmux new-window -t FULLORUST:3 -n 'FULLO2-ACTIX' 'cd ~/work/rust/fullo-rust/actix-api; cargo watch -x run'
##tmux new-window -t FULLORUST:3 -n 'FULLO1-NPM' 'cd ~/work/angular/fullo-app; npm run startro'

tmux select-window -t FULLORUST:2
tmux -2 attach-session -t FULLORUST

