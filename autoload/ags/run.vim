" Default ag executable path
let s:exe  = 'ag'

" Last command
let s:last = ''

" Last args
let s:lastArgs = ''

let s:id = ''
let s:job_killed = 0

function! s:remove(args, name)
    return substitute(a:args, '\s\{}' . a:name . '\(=\S\{}\)\?', '', 'g')
endfunction

function! s:exists(args, name)
    return a:args =~ '\s\{1,}' . a:name . '\(=\|\s\)'
endfunction

function! s:cmd(args)
    let cmd  = has_key(g:, 'ags_agexe') ? g:ags_agexe . ' ' : s:exe
    let args = a:args

    for [ key, arg ] in items(g:ags_agargs)
        let value  = arg[0]
        let short  = arg[1]
        let exists = s:exists(args, key) || (strlen(short) > 0 && s:exists(args, short))

        if exists
            continue
        endif

        if value =~ '^g:'
            let value = substitute(value, '^g:', '', '')
            let value = get(g:, value, 0)
        endif

        let op   = strlen(value) == 0 ? '' : '='
        let cmd .= ' ' . key . op . value
    endfor

    let cmd    = cmd . ' ' . args
    let s:last = cmd

    return cmd
endfunction

" Runs an ag search with the given {args}
"
function! ags#run#ag(args)
    let s:lastArgs = a:args
    return system(s:cmd(a:args))
endfunction

" Runs an ag search with the givent {args} async.
" The functions {onOut}, {onExit}, and, {onError} will be used to
" communicate with the async process
"
function! ags#run#agAsync(args, onOut, onExit, onError)
    let s:lastArgs = a:args
    let pat = '"\([^"]\+\)"\|\([^ ]\+\)'
    let idx = 0
    let cmd = s:cmd(a:args)
    let len = strlen(cmd)
    let lst = []

    while match(cmd, pat, idx) > -1 && idx < len
        let mat = matchlist(cmd, pat, idx)
        let cur = mat[1]

        if strlen(cur) == 0
            let cur = mat[0]
        endif

        let idx = match(cmd, pat, idx) + strlen(mat[0])
        call add(lst,  cur)
    endwhile

    if s:id
        silent! call jobstop(s:id)
    endif

    let s:job_killed = 0
    let s:id = jobstart(lst, {
                \ 'on_stderr': a:onError,
                \ 'on_stdout': a:onOut,
                \ 'on_exit': a:onExit
                \ })
endfunction

function! ags#run#agAsyncWasKilled()
    if s:job_killed == 1
        return 1
    endif
endfunction

function! ags#run#agAsyncUpdateJobId(job_id)
    let s:id = a:job_id
endfunction

function! ags#run#agAsyncStop()
    if s:id != 0
        let s:job_killed = 1
        call jobstop(s:id)
    endif
endfunction

" Runs the last ag search
"
function! ags#run#runLastCmd()
    return ags#run#ag(s:lastArgs)
endfunction

" Returns true if an ag search has been performed
"
function! ags#run#hasLastCmd()
    return !empty(s:lastArgs)
endfunction

" Return the arguments of the last command
"
function! ags#run#getLastArgs()
    return s:lastArgs
endfunction

" Displays the last ag command executed
"
function! ags#run#getLastCmd()
    echom s:last
endfunction
