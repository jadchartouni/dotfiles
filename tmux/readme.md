# Tmux

Tmux configuration and cheat sheet

## Setup

`git clone https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm`

## Custom key bindings

| Description         | Command / key binding |
| ------------------- | --------------------- |
| Prefix              | `Ctrl + a`            |
| Reload ~tmux.conf   | `Ctrl + a` `r`        |
| Split vertically    | `Ctrl + a` `\|`       |
| Split horizontally  | `Ctrl + a` `-`        |
| Resize window down  | `Ctrl + a` `j`        |
| Resize window up    | `Ctrl + a` `k`        |
| Resize window right | `Ctrl + a` `l`        |
| Resize window left  | `Ctrl + a` `h`        |
| Maximze window      | `Ctrl + a` `m`        |

## Miscellaneous

| Description                      | Command / key binding |
| -------------------------------- | --------------------- |
| Enter command mode               | `Ctrl + a` `:`        |
| Set option for all windows       | `:setw -g OPTION`     |
| Set option for all sessions      | `:set -g OPTION`      |
| Enable mouse mode                | `:set mouse on`       |
| List key bindings                | `tmux list-keys`      |
| ...                              | `:list-keys`          |
| ...                              | `Ctrl + a` `?`        |
| Show every session, window, pane | `tmux info`           |

## Session management

| Description                                | Command / key binding                    |
| ------------------------------------------ | ---------------------------------------- |
| Start a new session                        | `tmux`                                   |
| ...                                        | `tmux new`                               |
| ...                                        | `tmux new-session`                       |
| Start a new session with a name            | `tmux new-session -s [session-name]`     |
| Kill / delete a session                    | `tmux kill-ses -t [session-name]`        |
| ...                                        | `tmux kill-session -t [session-name]`    |
| Kill / delete all sessions but the current | `tmux kill-session -a`                   |
| Kill / delete all sessions but one         | `tmux kill-session -a -t [session-name]` |
| List all sessions                          | `tmux ls`                                |
| ...                                        | `tmux list-sessions`                     |
| ...                                        | `Ctrl + a` `s`                           |
| Attach to the last session                 | `tmux a`                                 |
| ...                                        | `tmux at`                                |
| ...                                        | `tmux attach`                            |
| ...                                        | `tmux attach-session`                    |
| Attach to a specific session               | `tmux a -t [session-name]`               |
| ...                                        | `tmux at -t [session-name]`              |
| ...                                        | `tmux attach -t [session-name]`          |
| ...                                        | `tmux attach-session -t [session-name]`  |
| Session and window preview                 | `Ctrl + a` `w`                           |
| Move to the previous session               | `Ctrl + a` `(`                           |
| Move to the next session                   | `Ctrl + a` `)`                           |
| Detach others on the session               | `:attach -d`                             |

## Window management

| Description                            | Command / key binding                         |
| -------------------------------------- | --------------------------------------------- |
| Start a new session with a window name | `tmux new -s [session-name] -n [window-name]` |
| Create window                          | `Ctrl + a` `c`                                |
| Rename current window                  | `Ctrl + a` `,`                                |
| Close current window                   | `Ctrl + a` `&`                                |
| List windows                           | `Ctrl + a` `w`                                |
| Previous window                        | `Ctrl + a` `p`                                |
| Next window                            | `Ctrl + a` `n`                                |
| Switch/select window by number         | `Ctrl + a` `0...9`                            |
| Reorder windows (-s src -t dst)        | `:swap-window -s 2 -t 1`                      |
| Move window position to the left       | `:swap-window -t -1`                          |

## Pane management

| Description                  | Command / key binding     |
| ---------------------------- | ------------------------- |
| Toggle last active pane      | `Ctrl + a` `;`            |
| Split pane horizontally      | `Ctrl + a` `\|`           |
| Split pane vertically        | `Ctrl + a` `-`            |
| Move the current pane left   | `Ctrl + a` `{`            |
| Move the current pane right  | `Ctrl + a` `}`            |
| Switch pane left             | `Ctrl + h`                |
| Switch pane right            | `Ctrl + l`                |
| Switch pane down             | `Ctrl + j`                |
| Switch pane up               | `Ctrl + k`                |
| Toggle between pane layouts  | `Ctrl + a` `Space`        |
| Show pane numbers            | `Ctrl + a` `q`            |
| Switch to next pane          | `Ctrl + a` `o`            |
| Switch/select pane by number | `Ctrl + a` `0...9`        |
| Toggle pane zoom             | `Ctrl + a` `z`            |
| Convert pane into a window   | `Ctrl + a` `!`            |
| Resize pane width left       | `Ctrl + a` `h`            |
| Resize pane width right      | `Ctrl + a` `l`            |
| Resize pane height down      | `Ctrl + a` `j`            |
| Resize pane height up        | `Ctrl + a` `k`            |
| Toggle synchronize-panes     | `:setw synchronize-panes` |
| Close current pane           | `Ctrl + a` `x`            |

## Copy mode

In copy mode, all vi movement keys will work.

| Description                                | Command / key binding     |
| ------------------------------------------ | ------------------------- |
| Enter copy mode                            | `Ctrl + a` `[`            |
| Quit copy mode                             | `q`                       |
| Start selection                            | `Space`                   |
| Clear selection                            | `ESC`                     |
| Copy selection                             | `Enter`                   |
| Paste selection of buffer_0                | `Ctrl + a` `]`            |
| Display buffer_0 contents                  | `:show-buffer`            |
| Capture visible contents of pane to buffer | `:capture-pane`           |
| List buffers                               | `:list-buffers`           |
| Show all buffers and paste selected        | `:choose-buffer`          |
| Save buffer contents to file               | `:save-buffer [filename]` |
| Delete buffer (-b buffer)                  | `:delete-buffer -b 1`     |
