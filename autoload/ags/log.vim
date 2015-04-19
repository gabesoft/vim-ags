" Logs a {message} highlighted with {hl}
"
function! s:log(message, hl)
    exec 'echohl ' . a:hl
    echom a:message
    echohl None
endfunction

" Writes a {message} highlighted with {hl}
"
function! s:write(message, hl)
    exec 'echohl ' . a:hl
    redraw | echo a:message
    echohl None
endfunction

" Logs an error with {message}
"
function! ags#log#error(message)
    call s:log(a:message, 'Error')
endfunction

" Logs an info {message}
"
function! ags#log#info(message)
    call s:log(a:message, 'MoreMsg')
endfunction

" Logs a warning {message}
"
function! ags#log#warn(message)
    call s:log(a:message, 'WarningMsg')
endfunction

" Logs a plain {message}
"
function! ags#log#plain(message)
    call s:log(a:message, 'None')
endfunction

" Writes an error with {message}
"
function! ags#log#errorw(message)
    call s:write(a:message, 'Error')
endfunction

" Writes an info {message}
"
function! ags#log#infow(message)
    call s:write(a:message, 'MoreMsg')
endfunction

" Writes a warning {message}
"
function! ags#log#warnw(message)
    call s:write(a:message, 'WarningMsg')
endfunction

" Writes a plain {message}
"
function! ags#log#plainw(message)
    call s:write(a:message, 'None')
endfunction
