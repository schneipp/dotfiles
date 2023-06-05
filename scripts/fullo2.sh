#!/bin/sh
#tmux new-session -s FULLO2 -n 'FULLO2-APP' -d 'cd /home/rams/work/scmiddleware-app; /home/rams/nvim-app/nvim-linux64/bin/./nvim'
tmux new-session -s FULLO2 -n 'FULLO2-CARGO' -d 'cd ~/work/rust/fullo-rust/actix-api; cargo watch -x run'
tmux new-window -t FULLO2:2 -n 'FULLO2-NPM' 'cd ~/work/rust/fullo-rust/fullo-app; npm run startro'
tmux new-window -t FULLO2:3 -n 'FULLO2-ACTIX' 'cd ~/work/rust/fullo-rust/actix-api; lvim .'
tmux new-window -t FULLO2:4 -n 'FULLO2-ANGULAR' 'cd ~/work/rust/fullo-rust/fullo-app; lvim .'
tmux a
