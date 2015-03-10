syntax region agsvFilePath matchgroup=agsvFilePathSyn start='\[1;31m' end='\[0m\[K' concealends
syntax region agsvLineNum matchgroup=agsvLineNumSyn keepend start='\[1;30m' end='\[0m\[K\-' oneline concealends
syntax region agsvLineNumMatch matchgroup=agsvLineNumMatchSyn keepend start='\[1;30m' end='\[0m\[K:\d\{-1,}:' oneline concealends
syntax region agsvResultPattern matchgroup=agsvResultPatternSyn start='\[32;40m' end='\[0m\[K' concealends
syntax region lCursor matchgroup=agsvResultPatternOnSyn keepend start='\[32;40m\[#m' end='\[#m\[0m\[K' concealends

highlight default agsvFilePath ctermfg=lightgreen guifg=lightgreen cterm=bold gui=bold
highlight default agsvLineNum ctermfg=lightmagenta guifg=lightmagenta
highlight default agsvLineNumMatch ctermfg=magenta guifg=magenta cterm=bold gui=bold
highlight default agsvResultPattern ctermfg=lightred ctermbg=darkgreen guifg=lightred guibg=darkgreen
highlight default agsvResultPatternOn ctermfg=darkgrey ctermbg=red guifg=darkgrey guibg=red

