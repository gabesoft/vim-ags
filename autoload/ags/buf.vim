" The search results buffer name
let s:bufname = 'search-results.agsv'

" The last window where a file from search results was opened
let s:lastWin = 0

" Open buffer commands
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

" Opens a window for the buffer with {name} positioned according to {cmd}
"
" {name}    the buffer name or file path
" {cmd}     one of the commands from s:cmd
" {sameWin} true to open in the current window
" {lastWin} true to reuse last window opened
"
function! s:open(name, cmd, sameWin, lastWin)
    let cmd     = s:cmd[a:cmd]
    let sameWin = a:sameWin
    let lastWin = a:lastWin

    if lastWin && s:lastWin && s:lastWin != bufwinnr(s:bufname)
        execute s:lastWin . 'wincmd w'
        let sameWin = 1
    elseif lastWin
        let cmd = s:cmd.above
        let sameWin = 0
    endif

    let bufcmd = sameWin ? 'buffer ' : cmd . ' sbuffer '
    let wincmd = sameWin ? 'edit '   : cmd . ' new '

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
endfunction

" Closes the buffer with {name}
"
function! s:close(name)
    if bufexists(a:name)
        let nr = bufnr(a:name)
        if nr > -1
            execute 'bw ' . nr
        endif
    endif
endfunction

function! ags#buf#OpenBuffer(name, cmd, sameWin, lastWin)
    call s:open(a:name, a:cmd, a:sameWin, a:lastWin)
endfunction

" Opens the search results buffer
"
function! ags#buf#OpenResultsBuffer()
    call s:open(s:bufname, 'bottom', 0, 0)
endfunction

" Closes the search results buffer
"
function! ags#buf#CloseResultsBuffer()
    call s:close(s:bufname)
endfunction
