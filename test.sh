#!/bin/bash
vim -u <(cat << VIMRC
set nocompatible
set rtp+=vader.vim
set rtp+=.
set rtp+=after
VIMRC) mini-vimrc -c 'Vader! test/*'
