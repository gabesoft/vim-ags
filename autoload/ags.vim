" search results buffer name
let s:bufname = 'search-results.agsv'

" the position of the last highlighted search pattern
let s:hlpos = []

" last window where a file from search results was opened
let s:lastWin = 0

" regex pattern functions
let s:pat  = function('ags#pat#mkpat')
let s:subg = function('ags#pat#subg')
let s:sub  = function('ags#pat#sub')

" ag executable
let s:exe = '/usr/local/bin/ag'

" default arguments
let s:args = {
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
            \ ' ',
            \ ' Results Window Commands',
            \ ' p - navigate file paths forward',
            \ ' P - navigate files paths backwards',
            \ ' r - navigate results forward',
            \ ' R - navigate results backwards',
            \ ' a - display the file path for current results',
            \ ' u - usage',
            \ ' ',
            \ ' Open Window Commands',
            \ ' oa - open file above the results window',
            \ ' ob - open file below the results window',
            \ ' ol - open file to the left of the results window',
            \ ' or - open file to the right of the results window',
            \ ' os - open file in the results window',
            \ ' ou - open file in a previously opened window (alias Enter)',
            \ ' ',
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

" window position flags
let s:wflags = { 't' : 'above', 'a' : 'above', 'b' : 'below', 'r' : 'right', 'l' : 'left' }

function! s:run(args)
    let cmd  = s:exe . ' '
    let args = a:args

    for [ key, value ] in items(s:args)
        let cmd .= ' --' . key . value
        let args = substitute(args, '\s\{}--' . key . '\(=\S\{}\)\?', '', 'g')
    endfor

    return system(cmd . ' ' . args)
endfunction

" Opens a window
"
" {name}    the buffer name or file path
" {cmd}     one of the commands from s:cmd
" {sameWin} true to open in the current window
" {preview} true to keep focus with the current window
" {lastWin} true to reuse last window opened
function! s:open(name, cmd, ...)
    let sameWin = a:0 && a:1
    let preview = a:0 > 1 && a:2
    let lastWin = a:0 > 2 && a:3
    let cmd     = s:cmd[a:cmd]

    if lastWin && s:lastWin
        execute s:lastWin . 'wincmd w'
        let sameWin = 1
    elseif lastWin
        let cmd = s:cmd.above
        let sameWin = 0
    endif

    let bufcmd = sameWin ? 'buffer ' : cmd . ' sbuffer '
    let wincmd = sameWin ? 'edit ' : cmd . ' new '

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

    if a:name != s:bufname
        let s:lastWin = winnr()
    endif

    if preview
        execute 'wincmd p'
    endif
endfunction

function! s:close(name)
    if bufexists(a:name)
        let nr = bufnr(a:name)
        if nr > -1
            execute 'bw ' . nr
        endif
    endif
endfunction

function! s:openResultsBuffer()
    call s:open(s:bufname, 'bottom')
endfunction

function! s:modifyOn()
    execute 'setlocal modifiable'
endfunction

function! s:modifyOff()
    execute 'setlocal nomodifiable'
endfunction

" Executes a write command
"
function! s:execw(...)
    call s:modifyOn()
    for l:cmd in a:000 | execute l:cmd | endfor
    call s:modifyOff()
endfunction

function! s:showResults(lines)
    let append = a:0 && a:1
    call s:openResultsBuffer()
    call s:modifyOn()

    if !append
        execute '%delete'
    endif

    call append(0, a:lines)
    call s:modifyOff()

    if !append
        execute 'normal gg'
    endif
endfunction

" Prepares the search data for display
"
" {data} raw search results
function! s:process(data)
    let data    = substitute(a:data, '\e', '', 'g')
    let lines   = split(data, '\n')
    let lmaxlen = 0
    let lineNo  = s:pat('^:lineStart:\(\d\{1,}\)')

    for l in lines
        let lmatch  = matchstr(l, lineNo)
        let lmaxlen = max([ strlen(lmatch), lmaxlen ])
    endfor

    let result = []
    for line in lines
        let llen = strlen(matchstr(line, lineNo))
        let wlen = lmaxlen - llen

        " right justify line numbers
        let line = s:sub(line, lineNo, ':lineStart:' . repeat(' ', wlen) . '\1')

        " add a space between line number and start of text
        let line = s:sub(line, '^\(.\{-}:lineEnd:\)\(.\{1,}$\)\@=', '\1 ')

        " add a space between line and column number and start of text
        let line = s:sub(line, '^\(.\{-}:lineColEnd:\)', '\1 ')

        call add(l:result, l:line)
    endfor

    return l:result
endfunction

function! s:resultPosition(lineNo)
    let line = getline(a:lineNo)
    let col  = 0
    let row  = 0

    if line =~ s:pat(':file:')
        let line = getline(a:lineNo + 1)
    endif

    if strlen(line) == 0 || line =~ '^--$'
        let line = getline(a:lineNo - 1)
    endif

    if line =~ s:pat('^:lineStart:\s\{}\d\{1,}:lineColEnd:')
        let col = matchstr(line, ':\zs\d\{1,}:\@=')
    endif

    let row = matchstr(line, s:pat('^:lineStart:\s\{}\zs\d\{1,}[\@='))

    return [0, row, col, 0]
endfunction

function! ags#Search(args)
    let args  = empty(a:args) ? expand('<cword>') : a:args
    let data  = s:run(args)
    let lines = s:process(data)
    call s:showResults(lines)
endfunction

function! ags#FilePath(lineNo)
    let nr = a:lineNo

    while nr >= 0 && getline(nr) !~ s:pat(':file:')
        let nr = nr - 1
    endw

    return s:sub(getline(nr), '^:file:', '\1')
endfunction

" Opens a results file
"
" {lineNo}  the line number in the search results buffer
" {flags}   window location flags
" {flags|s} opens the file in the search results window
" {flags|a} opens the file above the search results window
" {flags|b} opens the file below the search results window
" {flags|r} opens the file to the right of the search results window
" {flags|l} opens the file to the left of the search results window
" {flags|u} opens the file to in a previously opened window
function! ags#OpenFile(lineNo, flags)
    let path  = fnameescape(ags#FilePath(a:lineNo))
    let cpos  = s:resultPosition(a:lineNo)
    let flags = has_key(s:wflags, a:flags) ? s:wflags[a:flags] : 'above'
    let wpos  = a:flags == 's'
    let reuse = a:flags == 'u'

    if filereadable(path)
        call s:open(path, flags, wpos, 0, reuse)
        call setpos('.', cpos)
    endif
endfunction

" Clears the highlighted result pattern if any
"
function! ags#ClearHlResult()
    if empty(s:hlpos) | return | endif

    let lineNo  = s:hlpos[1]
    let lastNo  = line('$')
    let s:hlpos = []

    if lineNo < 0 || lineNo > lastNo | return | endif

    let pos  = getpos('.')
    let expr = s:pat(':\resultStart::\hlDelim:\(.\{-}\):\hlDelim::\end:')
    let repl = s:pat(':resultStart:\1:end:')
    let cmd  = 'silent ' . lineNo . 's/\m' . expr . '/' . repl . '/ge'

    call s:execw(cmd)
    call setpos('.', pos)
endfunction

" Navigates the next result pattern on the same line
"
function! ags#NavigateResultsOnLine()
    let line = getline('.')
    let result = s:pat(':resultStart:.\{-}:end:')
    if line =~ result
        let [bufnum, lnum, col, off] = getpos('.')
        call setpos('.', [bufnum, lnum, 0, off])
        call ags#NavigateResults()
    endif
endfunction

" Navigates the search results patterns
"
" {flags} search flags (b, B, w, W)
function! ags#NavigateResults(...)
    call ags#ClearHlResult()

    let flags = a:0 > 0 ? a:1 : 'w'
    call search(s:pat(':resultStart:.\{-}:end:'), flags)

    let pos  = getpos('.')
    let line = getline('.')
    let row  = pos[1]
    let col  = pos[2]

    let expr = s:pat(':\resultStart:\(.\{-}\):\end:')
    let repl = s:pat(':resultStart::hlDelim:\1:hlDelim::end:')
    let cmd  = 'silent ' . row . 's/\m\%' . col . 'c' . expr . '/' . repl . '/e'

    call s:execw(cmd)
    call setpos('.', pos)

    let s:hlpos = pos
endfunction

" Navigates the search results file paths
"
" {flags} search flags (b, B, w, W)
function! ags#NavigateResultsFiles(...)
    call ags#ClearHlResult()
    let flags = a:0 > 0 ? a:1 : 'w'
    let file = s:pat(':file:')
    call search(file, l:flags)
    execute 'normal zt'
endfunction

function! ags#Quit()
    call s:close(s:bufname)
endfunction

function! ags#Usage()
    for l:u in s:usage | echom l:u | endfor
endfunction
