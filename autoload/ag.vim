let s:bufname   = 'search-results.agv'
let s:lastPosOn = []
let s:lastWin   = ''

" TODO: put these in a dict or maybe make an object
let s:patEn          = '[0m[K'
let s:patEnEsc       = '\[0m\[K'
let s:patColNo       = ':\d\{-1,}:'
let s:patStFile      = '[1;31m'
let s:patStFileEsc   = '\[1;31m'
let s:patStLineNo    = '[1;30m'
let s:patStLineNoEsc = '\[1;30m'
let s:patEnLineNo    = s:patEn . '-'
let s:patEnLineNoEsc = s:patEnEsc . '-'
let s:patEnColNo     = s:patEn . s:patColNo
let s:patStRes       = '[32;40m'
let s:patStResEsc    = '\[32;40m'
let s:patOnDelim     = '[#m'
let s:patOnDelimEsc  = '\[#m'
let s:patFile        = '^' . s:patStFile . '.\{-1,}' . s:patEn

let s:defaults  = {
            \ 'heading'           : '',
            \ 'filename'          : '',
            \ 'break'             : '',
            \ 'color'             : '',
            \ 'group'             : '',
            \ 'numbers'           : '',
            \ 'column'            : '',
            \ 'context'           : '=3',
            \ 'color-line-number' : '="1;30"',
            \ 'color-match'       : '="32;40"',
            \ 'color-path'        : '="1;31"'
            \ }

let s:usage = [
            \ ' Search Results Key Bindings',
            \ ' ---------------------------',
            \ ' p - navigate file paths forward',
            \ ' P - navigate files paths backwards',
            \ ' r - navigate results forward',
            \ ' R - navigate results backwards',
            \ ' a - display the file path for current results',
            \ ' u - usage',
            \ ' ---------------------------'
            \ ]

let s:cmd = {
            \ 'top'       : 'to',
            \ 'bottom'    : 'bo',
            \ 'above'     : 'abo',
            \ 'below'     : 'bel',
            \ 'far-left'  : 'vert to',
            \ 'far-right' : 'vert bo',
            \ 'left'      : 'vert abo',
            \ 'right'     : 'vert bel'
            \ }

let s:flags = { 't' : 'above', 'a' : 'above', 'b' : 'below', 'r' : 'right', 'l' : 'left' }

function! ag#Usage()
    for l:u in s:usage | echom l:u | endfor
endfunction

" TODO optimize this for large results
function! ag#Run(pattern, args, path)
    let l:cmd = '/usr/local/bin/ag'

    for [ key, value ] in items(s:defaults)
        let l:cmd .= ' --' . key . value
    endfor

    let l:cmd .= ' ' . a:args
    let l:cmd .= ' ' . a:pattern
    let l:cmd .= ' ' . a:path

    return system(l:cmd)
endfunction

" Opens a window
"
" @param name - the buffer name or file path
" @param cmd - one of the commands from s:cmd
" @param sameWin - true to open in the current window
" @param preview - true to keep focus with the current window
function! s:open(name, cmd, ...)
    let sameWin = a:0 && a:1
    let preview = a:0 > 1 && a:2
    let cmd     = s:cmd[a:cmd]

    let bufcmd = sameWin ? 'buffer ' : cmd . ' sbuffer '
    let wincmd = sameWin ? 'edit ' : cmd . ' new '

    echom cmd . ' ' . bufcmd . ' ' . wincmd

    if bufexists(a:name)
        let nr = bufwinnr(a:name)
        if nr == -1
            execute bufcmd . bufnr(a:name)
        else
            execute nr . 'wincmd w'
        endif
    else
        execute wincmd . a:name
    endif

    if preview
        execute 'wincmd p'
    endif
endfunction

function! s:openResultsBuffer()
    call s:open(s:bufname, 'bottom')
endfunction

"function! ag#OpenBuffer(name)
    "if bufexists(a:name)
        "let l:bfnr = bufwinnr(a:name)
        "if l:bfnr == -1
            ""execute 'sbuffer ' . bufnr(a:name)

            "" ABSOLUTE
            ""exe 'bo sbuffer ' . bufnr(a:name)
            ""exe 'to sbuffer ' . bufnr(a:name)
            "" rest same as abelow

            "" SAME WINDOW
            ""exe 'buffer ' . bufnr(a:name)
        "else
            "execute l:bfnr . 'wincmd w'
        "endif
    "else
        "execute 'new ' . a:name

        "" ABSOLUTE
        ""exe 'bo new ' . a:name         " bottom
        ""exe 'to new ' . a:name         " top
        ""exe 'vert bo new ' . a:name    " right
        ""exe 'vert to new ' . a:name    " left

        "" RELATIVE (observe splitbelow and splitright)
        ""exe 'bel new ' . a:name        " below
        ""exe 'abo new ' . a:name        " above
        ""exe 'vert bel new ' . a:name   " right
        ""exe 'vert abo new ' . a:name   " left

        "" SAME WINDOW
        ""exe 'edit ' . a:name
    "endif
"endfunction

"function! ag#ReplaceBuffer(nameNew, nameOld)
"if !bufexists(a:nameOld)
"call ag#OpenBuffer(a:nameNew)
"return
"endif

"let l:oldBfnr = bufwinnr(a:nameOld)
"if l:oldBfnr == -1
"call ag#OpenBuffer(a:nameNew)
"endif

"" TODO: left here
"endfunction

function! ag#ModifyOn()
    execute 'setlocal modifiable'
endfunction

function! ag#ModifyOff()
    execute 'setlocal nomodifiable'
endfunction

function! ag#Execute(...)
    call ag#ModifyOn()
    for l:cmd in a:000 | execute l:cmd | endfor
    call ag#ModifyOff()
endfunction

function! ShowResults(lines)
    call s:openResultsBuffer()
    call ag#ModifyOn()
    execute '%delete'
    call append(0, a:lines)
    call ag#ModifyOff()
    execute 'normal gg'
endfunction

function! ag#Process(data)
    let l:data       = substitute(a:data, '\e', '', 'g')
    let l:lines      = split(l:data, '\n')
    let l:maxw       = 0
    let l:lineNumPat = '^' . s:patStLineNo . '\(\d\{1,}\)'

    for l:line in l:lines
        let l:str  = matchstr(l:line, l:lineNumPat)
        let l:maxw = max([ strlen(l:str), l:maxw ])
    endfor

    let l:result = []
    for l:line in l:lines
        let l:len   = strlen(matchstr(l:line, l:lineNumPat))
        let l:wslen = l:maxw - l:len
        let l:line  = substitute(l:line, l:lineNumPat, s:patStLineNo . repeat(' ', l:wslen) . '\1', '')
        let l:line  = substitute(l:line, '^\(.\{-}' . s:patEnLineNo . '\)\(.\{1,}$\)\@=', '\1 ', '')
        let l:line  = substitute(l:line, '^\(.\{-}' . s:patEnColNo . '\)', '\1 ', '')
        call add(l:result, l:line)
    endfor

    return l:result
endfunction

function! ag#Search(pattern, args, path)
    let l:data = ag#Run(a:pattern, a:args, a:path)
    let l:lines = ag#Process(l:data)
    call ShowResults(l:lines)
endfunction

function! ag#FilePath(lineNo)
    let l:no = a:lineNo

    while l:no >= 0 && getline(l:no) !~ s:patFile
        let l:no = l:no - 1
    endw

    return substitute(getline(l:no), '^' . s:patStFile . '\(.\{-}\)' . s:patEn, '\1', '')
endfunction

function! ag#ResultPosition(lineNo)
    let l:line         = getline(a:lineNo)
    let l:cursorColumn = 0
    let l:cursorLine   = 0

    if l:line =~ s:patFile
        let l:line = getline(a:lineNo + 1)
    endif

    if strlen(l:line) == 0 || l:line =~ '--'
        let l:line = getline(a:lineNo - 1)
    endif

    if l:line =~ '^' . s:patStLineNo . '\s\{}\d\{1,}' . s:patEnColNo
        let l:cursorColumn = matchstr(l:line, ':\zs\d\{1,}:\@=')
    endif

    let l:cursorLine = matchstr(l:line, '^' . s:patStLineNo . '\s\{}\zs\d\{1,}[\@=')

    return { 'line': l:cursorLine, 'column': l:cursorColumn }
endfunction

function! ag#OpenFile(lineNo, flags)
    let path  = fnameescape(ag#FilePath(a:lineNo))
    let cpos  = ag#ResultPosition(a:lineNo)
    let flags = has_key(s:flags, a:flags) ? s:flags[a:flags] : 'above'
    let wpos  = a:flags == 's'

    if filereadable(path)
        call s:open(path, flags, wpos)
        "call ag#OpenBuffer(fnameescape(l:path))
        execute 'normal ' . cpos.line . 'G' . cpos.column . '|'
    endif
endfunction

"function! ag#ViewFile(lineNo)
"call ag#OpenFile(a:lineNo)
"call ag#OpenBuffer(s:bufname)
"endfunction

function! ag#ClearResultsOn()
    if empty(s:lastPosOn) | return | endif

    let l:lineNo    = s:lastPosOn[1]
    let s:lastPosOn = []

    let l:pos  = getpos('.')
    let l:src  = s:patStResEsc . s:patOnDelimEsc . '\(.\{-}\)' . s:patOnDelimEsc . s:patEnEsc
    let l:repl = s:patStRes . '\1' . s:patEn
    let l:cmd  = 'silent ' . l:lineNo . 's/\m' . l:src . '/' . l:repl . '/ge'

    call ag#Execute(l:cmd)
    call setpos('.', l:pos)
endfunction

function! ag#NavigateResults(...)
    call ag#ClearResultsOn()

    let l:flags = a:0 > 0 ? a:1 : 'w'
    call search(s:patStRes . '.\{-}' . s:patEn, l:flags)
    execute 'normal zz'

    let l:pos = getpos('.')
    let l:lineNo = line('.')
    let l:columnNo = col('.')

    let l:line = getline('.')
    let l:src  = s:patStResEsc . '\(.\{-}\)' . s:patEnEsc
    let l:repl = s:patStRes . s:patOnDelim . '\1' . s:patOnDelim . s:patEn
    let l:cmd  = 'silent ' . l:lineNo . 's/\m\%' . l:columnNo . 'c' . l:src . '/' . l:repl . '/e'

    call ag#Execute(l:cmd)
    call setpos('.', l:pos)

    let s:lastPosOn = l:pos
endfunction

function! ag#HighlightResult()
    let l:line = getline('.')
    let l:result = s:patStRes . '.\{-}' . s:patEn
    if l:line =~ l:result
        let [bufnum, lnum, col, off] = getpos('.')
        call setpos('.', [bufnum, lnum, 0, off])
        call ag#NavigateResults()
    endif
endfunction

function! ag#NavigateResultsFiles(...)
    call ag#ClearResultsOn()
    let l:flags = a:0 > 0 ? a:1 : 'w'
    call search(s:patFile, l:flags)
    execute 'normal zt'
endfunction
