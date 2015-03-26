" Logs a {message} highlighted with {hl}
"
function! s:log(message, hl)
    exec 'echohl ' . a:hl
    echom a:message
    echohl None
endfunction

" Logs an error with {message}
"
function! ags#log#error(message)
    call s:log(a:message, 'Error')
endfunction

" Log an info {message}
"
function! ags#log#info(message)
    call s:log(a:message, 'MoreMsg')
endfunction

" Log a warning {message}
function! ags#log#warn(message)
    call s:log(a:message, 'WarningMsg')
endfunction
