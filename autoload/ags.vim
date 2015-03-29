
" The position of the last highlighted search pattern
let s:hlpos = []

" Last copied value
let s:lastCopy = ''

" Regex pattern functions
let s:pat  = function('ags#pat#mkpat')
let s:gsub = function('ags#pat#gsub')
let s:sub  = function('ags#pat#sub')

" Search results usage
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
            \ ' c - copy the file path for current results',
            \ ' E - enter edit mode',
            \ ' q - close the search results window',
            \ ' u - usage',
            \ ' ',
            \ ' Open Window Commands',
            \ '    - to maintain the focus in the search results window use',
            \ '      the uppercase variant of the mappings below',
            \ ' oa - open file above the results window',
            \ ' ob - open file below the results window',
            \ ' ol - open file to the left of the results window',
            \ ' or - open file to the right of the results window',
            \ ' os - open file in the results window',
            \ ' ou - open file in a previously opened window (alias Enter)',
            \ ' xu - open file in a previously opened window and close the search results',
            \ ' ',
            \ ]

" Window position flags
let s:wflags = { 't' : 'above', 'a' : 'above', 'b' : 'below', 'r' : 'right', 'l' : 'left' }

" Executes a write command
"
function! s:execw(...)
    exec 'setlocal modifiable'
    for cmd in a:000
        if type(cmd) == type({})
            call cmd.run()
        else
            exec cmd
        endif
    endfor
    exec 'setlocal nomodifiable'
endfunction

" Displays the search results from {lines} in the
" search results window
"
function! s:show(lines, ...)
    let obj = { 'add': a:0 && a:1, 'lines': a:lines }

    function obj.run()
        if self.add && line('$') > 1
            call append('$', self.lines)
        else
            call ags#buf#replaceLines(self.lines)
        endif
    endfunction

    call ags#buf#openViewResultsBuffer()
    call s:execw(obj)
endfunction

" Prepares the search {data} for display
"
function! s:processSearchData(data)
    let data    = substitute(a:data, '\e', '', 'g')
    let lines   = split(data, '\n')
    let lmaxlen = 0
    let lineNo  = s:pat('^:lineStart:\(\d\{1,}\)')

    for line in lines
        let lmatch  = matchstr(line, lineNo)
        let lmaxlen = max([ strlen(lmatch), lmaxlen ])
    endfor

    let results = []
    for line in lines
        let llen = strlen(matchstr(line, lineNo))
        let wlen = lmaxlen - llen

        " right justify line numbers and add a space after
        let line = s:sub(line, lineNo, ':lineStart:' . repeat(' ', wlen) . '\1 ')

        call add(results, line)
    endfor

    return results
endfunction

" Returns the cursor position when opening a file
" from the {lineNo} in the search results window
"
function! s:resultPosition(lineNo)
    let line = getline(a:lineNo)
    let col  = 0

    if line =~ s:pat(':file:')
        let line = getline(a:lineNo + 1)
    endif

    if strlen(line) == 0 || line =~ '^--$'
        let line = getline(a:lineNo - 1)
    endif

    if line =~ s:pat('^:lineStart:\s\{}\d\{1,}\s\{}:lineColEnd:')
        let col = matchstr(line, ':\zs\d\{1,}:\@=')
    endif

    let row = matchstr(line, s:pat('^:lineStart:\s\{}\zs\d\{1,}\ze\s\{}[\@='))

    return [0, row, col, 0]
endfunction

" Performs a search with the specified {args} and according to {cmd}.
"
" {cmd|add}  the new results will be added to previous results in the search window
" {cmd|last} ignores {args} and runs the last search
"
function! ags#search(args, cmd)
    let last = a:cmd ==# 'last'
    let add  = a:cmd ==# 'add'

    if last && !ags#run#hasLastCmd()
        call ags#log#warn("There is no previous search")
        return
    elseif last
        let data = ags#run#runLastCmd()
    else
        let args  = empty(a:args) ? expand('<cword>') : a:args
        let data  = ags#run#ag(args)
    endif

    let lines = s:processSearchData(data)
    if empty(lines)
        call ags#log#warn("No matches for " . string(a:args))
    elseif len(lines) == 1
        call ags#log#warn(lines[0])
    else
        call s:show(lines, add)
    endif
endfunction

" Returns the file path for the search results
" relative to {lineNo}
"
function! ags#filePath(lineNo)
    let nr = a:lineNo

    while nr >= 0 && getline(nr) !~ s:pat(':file:')
        let nr = nr - 1
    endw

    return s:sub(getline(nr), '^:file:', '\1')
endfunction

" Sets the {text} into the copy registers
"
function! s:copyText(text)
    if &clipboard =~ '\<unnamed\>'
        let @* = a:text
        let @@ = a:text
    elseif &clipboard =~ '\<unnamedplus\>' && has('\<unnamedplus\>')
        let @+ = a:text
        let @@ = a:text
    endif
endfunction

" Copies to clipboard the file path for the search results
" relative to {lineNo}
"
function! ags#copyFilePath(lineNo, fullPath)
    let file = ags#filePath(a:lineNo)
    let file = a:fullPath ? fnamemodify(file, ':p') : file
    call s:copyText(file)
    return 'Copied ' . file
endfunction

" Removes any delimiters from the yanked text
"
function! ags#cleanYankedText()
    if empty(@0) || @0 == s:lastCopy | return | endif

    let s:lastCopy = @0

    let text = @0
    let text = s:gsub(text,  ':file:', '\1')
    let text = s:gsub(text, ':\lineStart:\([ 0-9]\{-1,}\):lineColEnd:', '\1')
    let text = s:gsub(text, ':\lineStart:\([ 0-9]\{-1,}\):lineEnd:', '\1')
    let text = s:gsub(text, ':resultStart::hlDelim:\(.\{-1,}\):hlDelim::end:', '\1')
    let text = s:gsub(text, ':resultStart:\(.\{-1,}\):end:', '\1')

    call s:copyText(text)
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
" {preview} set to true to keep focus in the search results window
"
function! ags#openFile(lineNo, flags, preview)
    let path  = fnameescape(ags#filePath(a:lineNo))
    let pos   = s:resultPosition(a:lineNo)
    let flags = has_key(s:wflags, a:flags) ? s:wflags[a:flags] : 'above'
    let wpos  = a:flags == 's'
    let reuse = a:flags == 'u'

    if filereadable(path)
        call ags#buf#openBuffer(path, flags, wpos, reuse)
        call setpos('.', pos)

        if a:preview
            exec 'normal zz'
            exec 'wincmd p'
        endif
    endif
endfunction

" Clears the highlighted result pattern if any
"
function! ags#clearHlResult()
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
function! ags#navigateResultsOnLine()
    let line = getline('.')
    let result = s:pat(':resultStart:.\{-}:end:')
    if line =~ result
        let [bufnum, lnum, col, off] = getpos('.')
        call setpos('.', [bufnum, lnum, 0, off])
        call ags#navigateResults()
    endif
endfunction

" Navigates the search results patterns
"
" {flags} search flags (b, B, w, W)
"
function! ags#navigateResults(...)
    call ags#clearHlResult()

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
function! ags#navigateResultsFiles(...)
    call ags#clearHlResult()
    let flags = a:0 > 0 ? a:1 : 'w'
    let file = s:pat(':file:')
    call search(file, flags)
    exec 'normal zt'
endfunction

function! ags#quit()
    call ags#buf#closeResultsBuffer()
endfunction

function! ags#usage()
    for u in s:usage | echom u | endfor
endfunction
