# Vim configuration

Vim configuration that is mostly customized for servers and remote connections.

## Setup

1. Install Vundle

   `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`

2. Copy .vimrc

   `cat vimrc ~/.vimrc`

3. Copy colorscheme

   `mkdir ~/.vim/colors`

   `cp colors/moonfly ~/.vim/colors/`

4. Install Plugins

   `vim +PluginInstall +qall`

## Plugins

- Vundle - Plugin manager
- Vinegar - Directory browser
- NerdTree - File system explorer
- CtrlP - Fuzzy finder
- Lightline - Status line
- Tagbar - Tag browser
- Ag - Search and replace
- Greplace - Global search and replace

## Map leader

The leader is changed to `,`

## Key mappings

| Description                      | Key mapping       |
| -------------------------------- | ----------------- |
| Switch to split left             | `Ctrl + h`        |
| Switch to split right            | `Ctrl + l`        |
| Switch to split down             | `Ctrl + j`        |
| Switch to split up               | `Ctrl + k`        |
| Quick edit of ~/.vimrc           | `<leader>ev`      |
| Source ~/.vimrc                  | `<leader>s`       |
| Fast save of file                | `<leader>w`       |
| Deselect highlighted search      | `<leader><space>` |
| Easy escape                      | `jj`              |
| Change directory to current file | `<leader>cd`      |
| Go to previous buffer            | `:bp`             |
| Go to next buffer                | `:bn`             |

## CtrlP

| Description            | key mapping |
| ---------------------- | ----------- |
| Open CtrlP for files   | `<leader>t` |
| Open CtrlP for buffers | `<leader>r` |

## NerdTree

| Description     | key mapping |
| --------------- | ----------- |
| Toggle NerdTree | `<leader>1` |

## Tagbar

| Description   | key mapping |
| ------------- | ----------- |
| Toggle Tagbar | `<leader>2` |
