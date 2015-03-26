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

" Opens a window for the buffer with {name} positioned according to {cmd}
"
" {name} the buffer name or file path
" {cmd}  the position command
"
function! s:openWin(name, cmd)
    let bufcmd = a:cmd == 'same' ? 'buffer ' : a:cmd . ' sbuffer '
    let wincmd = a:cmd == 'same' ? 'edit '   : a:cmd . ' new '

    if bufexists(a:name)
        let nr = bufwinnr(a:name)
        if nr == -1
            exec bufcmd . bufnr(a:name)
        else
            call s:focus(nr)
        endif
    else
        execute wincmd . a:name
    endif
endfunction

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

    if lastWin
        let searchWin = s:lastWin == bufwinnr(s:agsv) || s:lastWin == bufwinnr(s:agse)
        if !searchWin && s:lastWin <= winnr('$')
            call s:focus(s:lastWin)
            let sameWin = 1
        else
            let cmd = s:cmd.above
            let sameWin = 0
        endif
    endif

    call s:openWin(a:name, sameWin ? 'same' : cmd)

    if a:name != s:agsv && a:name != s:agse
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

" Gets the edit or view search results bufwinnr
"
function! s:getSearchResultsBufwinnr()
    let nr = bufwinnr(s:agsv)
    return nr == -1 ? bufwinnr(s:agse) : nr
endfunction

" Focuses the window with {nr}
"
" {nr} the window number
"
function! s:focus(nr)
    exec a:nr . 'wincmd w'
endfunction

" Opens the search results buffer
"
function! s:openResultsBuffer(name)
    let nr = s:getSearchResultsBufwinnr()
    if nr > 0 && nr <= winnr('$')
        call s:focus(nr)
        exec 'setlocal nomodified'
        call s:openWin(a:name, 'same')
    else
        call s:open(a:name, 'bottom', 0, 0)
    endif
endfunction

" Opens the view search results buffer and closes the edit search results
" buffer
"
function! ags#buf#openViewResultsBuffer()
    call s:openResultsBuffer(s:agsv)
    call s:close(s:agse)
endfunction

" Opens the edit search results buffer and closes the view search results
" buffer
"
function! ags#buf#openEditResultsBuffer()
    call s:openResultsBuffer(s:agse)
    call s:close(s:agsv)
endfunction

" Opens the edit results buffer if it exists and returns 1; otherwise, it returns 0
"
function! ags#buf#openEditResultsBufferIfExists()
    if bufwinnr(s:agse) != -1 || bufnr(s:agse) != -1
        call s:open(s:agse, 'bottom', 0, 0)
        return 1
    else
        return 0
    endif
endfunction

" Focuses the search results window
"
function! ags#buf#focusResultsWindow()
    let nr = s:getSearchResultsBufwinnr()
    call s:focus(nr)
endfunction

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

" Closes the search results buffer
"
function! ags#buf#closeResultsBuffer()
    let nr = s:getSearchResultsBufwinnr()
    if nr > 0 && nr <= winnr('$')
        call s:focus(nr)
        exec 'setlocal nomodified'
    endif
    call s:close(s:agsv)
    call s:close(s:agse)
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
