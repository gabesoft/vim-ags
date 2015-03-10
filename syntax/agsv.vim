syntax region agsvFilePath matchgroup=agsvFilePathSyn start='\[1;31m' end='\[0m\[K' concealends
syntax region agsvLineNum matchgroup=agsvLineNumSyn keepend start='\[1;30m' end='\[0m\[K\-' oneline concealends
syntax region agsvLineNumMatch matchgroup=agsvLineNumMatchSyn keepend start='\[1;30m' end='\[0m\[K:\d\{-1,}:' oneline concealends
syntax region agsvResultPattern matchgroup=agsvResultPatternSyn start='\[32;40m' end='\[0m\[K' concealends
syntax region agsvResultPatternOn matchgroup=agsvResultPatternOnSyn keepend start='\[32;40m\[#m' end='\[#m\[0m\[K' concealends

highlight default link agsvFilePath Constant
highlight default link agsvLineNum Identifier
highlight default link agsvLineNumMatch Underlined
highlight default link agsvResultPattern Title
highlight default link agsvResultPatternOn lCursor
