#!/bin/sh
#tmux new-session -s COPS -n 'COPS-APP' -d 'cd /home/rams/work/scmiddleware-app; /home/rams/nvim-app/nvim-linux64/bin/./nvim'
tmux new-session -s COPS -n 'COPS-DOCKER' -d 'cd ~/work/php/cgs.azure.git/; sh docker.sh'
tmux new-window -t COPS:2 -n 'COPS-PHP' 'cd ~/work/php/cgs.azure.git; nvim .'
tmux new-window -t COPS:3 -n 'COPS-ANGULAR' 'cd ~/work/angular/copsmobile15; nvim .'
tmux new-window -t COPS:4 -n 'COPS-NPM' 'cd ~/work/angular/copsmobile15; sh serve.sh'
tmux a

