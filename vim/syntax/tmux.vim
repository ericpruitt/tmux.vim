" Language: tmux(1) configuration file
" Version: 3.3-rc (git-964deae4)
" URL: https://github.com/ericpruitt/tmux.vim/
" Maintainer: Eric Pruitt <eric.pruitt@gmail.com>
" License: 2-Clause BSD (http://opensource.org/licenses/BSD-2-Clause)

if exists("b:current_syntax")
    finish
endif

" Explicitly change compatibility options to Vim's defaults because this file
" uses line continuations.
let s:original_cpo = &cpo
set cpo&vim

let b:current_syntax = "tmux"
syntax iskeyword @,48-57,_,192-255,-
syntax case match

syn keyword tmuxAction  none any current other
syn keyword tmuxBoolean off on

syn keyword tmuxTodo FIXME NOTE TODO XXX contained

syn match tmuxColour            /\<colour[0-9]\+/      display
syn match tmuxKey               /\(C-\|M-\|\^\)\+\S\+/ display
syn match tmuxNumber            /\<\d\+\>/             display
syn match tmuxFlags             /\s-\a\+/              display
syn match tmuxVariable          /[A-Za-z_]\w*=/        display
syn match tmuxVariableExpansion /\${\=[A-Za-z_]\w*}\=/ display
syn match tmuxControl           /%\(if\|elif\|else\|endif\)/
syn match tmuxEscape            /\\\(u\x\{4\}\|U\x\{8\}\|\o\{3\}\|[\\ernt$]\)/ display

syn region tmuxComment start=/#/ skip=/\\\@<!\\$/ end=/$/ contains=tmuxTodo,@Spell

syn region tmuxString start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=tmuxFormatString,tmuxEscape,tmuxVariableExpansion,@Spell
syn region tmuxUninterpolatedString start=+'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end='$' contains=tmuxFormatString,@Spell

" TODO: Figure out how escaping works inside of #(...) and #{...} blocks.
syn region tmuxFormatString start=/#[#DFhHIPSTW]/ end=// contained keepend
syn region tmuxFormatString start=/#{/ skip=/#{.\{-}}/ end=/}/ keepend
syn region tmuxFormatString start=/#(/ skip=/#(.\{-})/ end=/)/ contained keepend

hi def link tmuxFormatString      Identifier
hi def link tmuxAction            Boolean
hi def link tmuxBoolean           Boolean
hi def link tmuxCommands          Keyword
hi def link tmuxControl           Keyword
hi def link tmuxComment           Comment
hi def link tmuxEscape            Special
hi def link tmuxEscapeUnquoted    Special
hi def link tmuxKey               Special
hi def link tmuxNumber            Number
hi def link tmuxFlags             Identifier
hi def link tmuxOptions           Function
hi def link tmuxString            String
hi def link tmuxTodo              Todo
hi def link tmuxUninterpolatedString
\                                 String
hi def link tmuxVariable          Identifier
hi def link tmuxVariableExpansion Identifier

" Make the foreground of colourXXX keywords match the color they represent
" when g:tmux_syntax_colors is unset or set to a non-zero value.
" Darker colors have their background set to white.
if get(g:, "tmux_syntax_colors", 1)
    for s:i in range(0, 255)
        let s:bg = (!s:i || s:i == 16 || (s:i > 231 && s:i < 235)) ? 15 : "none"
        exec "syn match tmuxColour" . s:i . " /\\<colour" . s:i . "\\>/ display"
\         " | highlight tmuxColour" . s:i . " ctermfg=" . s:i . " ctermbg=" . s:bg
    endfor
endif

syn keyword tmuxOptions
\ activity-action aggressive-resize allow-passthrough allow-rename
\ alternate-screen assume-paste-time automatic-rename
\ automatic-rename-format backspace base-index bell-action buffer-limit
\ clock-mode-colour clock-mode-style command-alias copy-command
\ copy-mode-current-match-style copy-mode-mark-style copy-mode-match-style
\ cursor-colour cursor-style default-command default-shell default-size
\ default-terminal destroy-unattached detach-on-destroy
\ display-panes-active-colour display-panes-colour display-panes-time
\ display-time editor escape-time exit-empty exit-unattached extended-keys
\ fill-character focus-events history-file history-limit key-table
\ lock-after-time lock-command main-pane-height main-pane-width
\ message-command-style message-limit message-style mode-keys mode-style
\ monitor-activity monitor-bell monitor-silence mouse other-pane-height
\ other-pane-width pane-active-border-style pane-base-index
\ pane-border-format pane-border-indicators pane-border-lines
\ pane-border-status pane-border-style pane-colours popup-border-lines
\ popup-border-style popup-style prefix prefix2 prompt-history-limit
\ remain-on-exit remain-on-exit-format renumber-windows repeat-time
\ scroll-on-clear set-clipboard set-titles set-titles-string silence-action
\ status status-bg status-fg status-format status-interval status-justify
\ status-keys status-left status-left-length status-left-style
\ status-position status-right status-right-length status-right-style
\ status-style synchronize-panes terminal-features terminal-overrides
\ update-environment user-keys visual-activity visual-bell visual-silence
\ window-active-style window-size window-status-activity-style
\ window-status-bell-style window-status-current-format
\ window-status-current-style window-status-format window-status-last-style
\ window-status-separator window-status-style window-style word-separators
\ wrap-search

syn keyword tmuxCommands
\ attach attach-session bind bind-key break-pane breakp capture-pane
\ capturep choose-buffer choose-client choose-session choose-tree
\ choose-window clear-history clear-prompt-history clearhist clearphist
\ clock-mode command-prompt confirm confirm-before copy-mode customize-mode
\ delete-buffer deleteb detach detach-client display display-menu
\ display-message display-panes display-popup displayp find-window findw has
\ has-session if if-shell info join-pane joinp kill-pane kill-server
\ kill-session kill-window killp killw last last-pane last-window lastp
\ link-window linkw list-buffers list-clients list-commands list-keys
\ list-panes list-sessions list-windows load-buffer loadb lock lock-client
\ lock-server lock-session lockc locks ls lsb lsc lscm lsk lsp lsw menu
\ move-pane move-window movep movew new new-session new-window neww next
\ next-layout next-window nextl paste-buffer pasteb pipe-pane pipep popup
\ prev previous-layout previous-window prevl refresh refresh-client rename
\ rename-session rename-window renamew resize-pane resize-window resizep
\ resizew respawn-pane respawn-window respawnp respawnw rotate-window
\ rotatew run run-shell save-buffer saveb select-layout select-pane
\ select-window selectl selectp selectw send send-keys send-prefix
\ server-info set set-buffer set-environment set-hook set-option
\ set-window-option setb setenv setw show show-buffer show-environment
\ show-hooks show-messages show-options show-prompt-history
\ show-window-options showb showenv showmsgs showphist showw source
\ source-file split-pane split-window splitp splitw start start-server
\ suspend-client suspendc swap-pane swap-window swapp swapw switch-client
\ switchc unbind unbind-key unlink-window unlinkw wait wait-for

let &cpo = s:original_cpo
unlet! s:original_cpo s:bg s:i
