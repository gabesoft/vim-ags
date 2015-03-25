syntax match agseLineNum /^\s\{}\d\{1,}\s\{1}/
syntax match agseLineNumMatch /^\s\{}\d\{1,}\s\{1}/

syntax region agseFilePath
            \ oneline
            \ concealends
            \ matchgroup=agsvFilePathSyn
            \ keepend
            \ start=/\[1;31m/
            \ end=/\[0m\[K/

highlight default link agseFilePath DiffAdd
highlight default link agseLineNum DiffText
highlight default link agseLineNumMatch DiffText
