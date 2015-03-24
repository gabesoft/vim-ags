syntax region agsvFilePath
            \ oneline
            \ concealends
            \ matchgroup=agsvFilePathSyn
            \ keepend
            \ start=/\[1;31m/
            \ end=/\[0m\[K/
syntax region agsvLineNum
            \ oneline
            \ concealends
            \ matchgroup=agsvLineNumSyn
            \ keepend
            \ start=/\[1;30m/
            \ end=/\[0m\[K-/
syntax region agsvLineNumMatch
            \ oneline
            \ concealends
            \ matchgroup=agsvLineNumMatchSyn
            \ keepend
            \ start=/\[1;30m/
            \ end=/\[0m\[K:\d\{-1,}:/
syntax region agsvResultPattern
            \ oneline
            \ concealends
            \ matchgroup=agsvResultPatternSyn
            \ start='\[32;40m'
            \ end=/\[0m\[K/
syntax region agsvResultPatternOn
            \ oneline
            \ concealends
            \ matchgroup=agsvResultPatternOnSyn
            \ keepend
            \ start=/\[32;40m\[#m/
            \ end=/\[#m\[0m\[K/

highlight default link agsvFilePath Constant
highlight default link agsvLineNum Identifier
highlight default link agsvLineNumMatch Underlined
highlight default link agsvResultPattern Title
highlight default link agsvResultPatternOn lCursor
