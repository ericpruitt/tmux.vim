" Language: tmux(1) configuration file
" Version: TMUX_VERSION
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
syn keyword tmuxBoolean off on yes no

syn keyword tmuxTodo FIXME NOTE TODO XXX contained

syn match tmuxColour            /\<colour[0-9]\+/      display
syn match tmuxKey               /\(C-\|M-\|\^\)\+\S\+/ display
syn match tmuxNumber            /\<\d\+\>/             display
syn match tmuxFlags             /\s-\a\+/              display
syn match tmuxVariable          /[A-Za-z_]\w*=/        display
syn match tmuxVariableExpansion /\${\=[A-Za-z_]\w*}\=/ display
syn match tmuxControl           /^\s*%\(if\|elif\|else\|endif\)/
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
