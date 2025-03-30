#!/bin/bash

#this quickly fetches the lastet nvim and stores it into ~/apps/nvim

#check if ~/apps/nvim exists
if [ -d ~/apps/nvim ]; then
  echo "nvim directory exists"
else
  echo "nvim directory does not exist, creating it"
  mkdir -p ~/apps/nvim
fi

#check os (fedora or debian)
if [ -f /etc/fedora-release ]; then
  echo "Fedora detected"
  #download nvim
  dnf install -y neovim #because fedora isnt an outdated fuck
fi
#check if it is debian based
if [ -f /etc/apt/sources.list ]; then
  echo "pretty sure it's debian"
  apt update
  apt install -y curl
  curl 'https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz' >/tmp/nvim.tar.gz
  #extract to ~/apps/nvim/
  tar -xzf /tmp/nvim.tar.gz ~/apps/nvim/
fi
