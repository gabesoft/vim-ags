" The search results buffer name (view mode)
let s:agsv = 'search-results.agsv'

" The search results buffer name (edit mode)
let s:agse = 'search-results.agse'

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

" TODO: rewrite s:open to take (name, cmd, destWin)

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

    if !s:lastWin
        let s:lastWin = winnr('#')
    endif

    if lastWin && s:lastWin && s:lastWin != bufwinnr(s:agsv) && s:lastWin <= winnr('$')
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

    if a:name != s:agsv
        let s:lastWin = winnr()
    endif
endfunction

" Closes the buffer with {name}
"
function! s:close(name)
    if bufexists(a:name)
        let nr = bufnr(a:name)
        if nr > -1
            execute 'silent bw ' . nr
        endif
    endif
endfunction

function! ags#buf#openBuffer(name, cmd, sameWin, lastWin)
    call s:open(a:name, a:cmd, a:sameWin, a:lastWin)
endfunction

" Opens the view search results buffer
"
function! ags#buf#openViewResultsBuffer()
    call s:open(s:agsv, 'bottom', 0, 0)
endfunction

" TODO: open agse in the agsv window and quit agsv
function! ags#buf#openEditResultsBuffer()
    call s:open(s:agse, 'bottom', 0, 0)
    call s:close(s:agsv)
endfunction

" TODO: refactor readViewResultsBuffer & readEditResultsBuffer

" Returns all lines from the view search results buffer
"
function! ags#buf#readViewResultsBuffer()
    let name = s:agsv
    if bufexists(name)
        let nr = bufnr(name)
        return getbufline(nr, 0, '$')
    else
        return []
    endif
endfunction

" Returns all lines from the edit search results buffer
"
function! ags#buf#readEditResultsBuffer()
    let name = s:agse
    if bufexists(name)
        let nr = bufnr(name)
        return getbufline(nr, 0, '$')
    else
        return []
    endif
endfunction

" Closes the view search results buffer
"
function! ags#buf#closeViewResultsBuffer()
    call s:close(s:agsv)
endfunction

" Replaces all lines in buffer with the specified lines
" and places the cursor at the first line
"
function! ags#buf#replaceLines(lines)
    exec '%delete'
    if len(a:lines) > 0
        call append(0, a:lines)
        exec 'normal dd'
        exec 'normal gg'
    endif
endfunction
