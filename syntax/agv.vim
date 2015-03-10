syntax region agvFilePath matchgroup=agvFilePathSyn start='\[1;31m' end='\[0m\[K' concealends
syntax region agvLineNum matchgroup=agvLineNumSyn keepend start='\[1;30m' end='\[0m\[K\-' oneline concealends
syntax region agvLineNumMatch matchgroup=agvLineNumMatchSyn keepend start='\[1;30m' end='\[0m\[K:\d\{-1,}:' oneline concealends
syntax region agvResultPattern matchgroup=agvResultPatternSyn start='\[32;40m' end='\[0m\[K' concealends
syntax region lCursor matchgroup=agvResultPatternOnSyn keepend start='\[32;40m\[#m' end='\[#m\[0m\[K' concealends

highlight default agvFilePath ctermfg=lightgreen guifg=lightgreen cterm=bold gui=bold
highlight default agvLineNum ctermfg=lightmagenta guifg=lightmagenta
highlight default agvLineNumMatch ctermfg=magenta guifg=magenta cterm=bold gui=bold
highlight default agvResultPattern ctermfg=lightred ctermbg=darkgreen guifg=lightred guibg=darkgreen
highlight default agvResultPatternOn ctermfg=darkgrey ctermbg=red guifg=darkgrey guibg=red

