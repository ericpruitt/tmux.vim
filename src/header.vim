" Language: tmux(1) configuration file
" Version: TMUX_VERSION
" Maintainer: Eric Pruitt <eric.pruitt@gmail.com>
" License: 2-Clause BSD (http://opensource.org/licenses/BSD-2-Clause)

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
else
    let b:current_syntax = "tmux"
endif

setlocal iskeyword+=-
syntax case match

syn keyword tmuxAction  none any current other
syn keyword tmuxBoolean off on

syn keyword tmuxTodo FIXME NOTE TODO XXX contained

syn match tmuxColour            /\<colour[0-9]\+/      display
syn match tmuxKey               /\(C-\|M-\|\^\)\+\S\+/ display
syn match tmuxNumber            /\d\+/                 display
syn match tmuxFlags             /\s-\a\+/              display
syn match tmuxVariable          /\w\+=/                display
syn match tmuxVariableExpansion /\${\=\w\+}\=/         display

syn region tmuxComment start=/#/ skip=/\\\@<!\\$/ end=/$/ contains=tmuxTodo

syn region tmuxString start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=tmuxFormatString
syn region tmuxString start=+'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end='$' contains=tmuxFormatString

" TODO: Figure out how escaping works inside of #(...) and #{...} blocks.
syn region tmuxFormatString start=/#[#DFhHIPSTW]/ end=// contained keepend
syn region tmuxFormatString start=/#{/ skip=/#{.\{-}}/ end=/}/ contained keepend
syn region tmuxFormatString start=/#(/ skip=/#(.\{-})/ end=/)/ contained keepend

hi def link tmuxFormatString      Identifier
hi def link tmuxAction            Boolean
hi def link tmuxBoolean           Boolean
hi def link tmuxCommands          Keyword
hi def link tmuxComment           Comment
hi def link tmuxKey               Special
hi def link tmuxNumber            Number
hi def link tmuxFlags             Identifier
hi def link tmuxOptions           Function
hi def link tmuxString            String
hi def link tmuxTodo              Todo
hi def link tmuxVariable          Identifier
hi def link tmuxVariableExpansion Identifier

for i in range(0, 255)
    if i == 0 || i == 16 || i == 232 || i == 233 || i == 233 || i == 234
        exec "highlight tmuxColour" . i . " ctermfg=" . i . " ctermbg=15"
    else
        exec "highlight tmuxColour" . i . " ctermfg=" . i
    endif
    exec "syn match tmuxColour" . i . " /\\<colour" . i . "\\>/ display"
endfor
