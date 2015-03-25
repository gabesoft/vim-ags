
" The position of the last highlighted search pattern
let s:hlpos = []

" Last copied value
let s:lastCopy = ''

" Regex pattern functions
let s:pat  = function('ags#pat#mkpat')
let s:gsub = function('ags#pat#gsub')
let s:sub  = function('ags#pat#sub')

" Run search
let s:run = function('ags#run#ag')

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
        if self.add
            call append('$', self.lines)
        else
            call ags#buf#replaceLines(self.lines)
        endif
    endfunction

    call ags#buf#openViewResultsBuffer()
    call s:execw(obj)
endfunction

" TODO: move to top and document
let s:editLines = []
let s:editData  = {}

function! s:readEditData(lines)
    let data = {}
    let file = ''
    let idx  = 0

    for line in a:lines
        if line =~ s:pat(':file:')
            let file = s:sub(line, '^:file:', '\1')
            let data[idx] = { 'file': file, 'row': 0 }
        elseif line =~ s:pat(':lineStart:')
            let row = matchstr(line, s:pat('^:lineStart:\s\{}\zs\d\{1,}\ze\s\{}[\@='))
            let data[idx] = { 'file': file, 'row': row }
        else
            let data[idx] = { 'file': file, 'row': 0 }
        endif
        let idx = idx + 1
    endfor

    return data
endfunction

function! s:processLinesForEdit(lines)
    let lines          = []

    let lineColPat     = s:pat('^:\lineStart:\([ 0-9]\{-1,}\):lineColEnd:')
    let linePat        = s:pat('^:\lineStart:\([ 0-9]\{-1,}\):lineEnd:')
    let resultDelimPat = s:pat(':resultStart::hlDelim:\(.\{-1,}\):hlDelim::end:')
    let resultPat      = s:pat(':resultStart:\(.\{-1,}\):end:')

    for line in a:lines
        let line = substitute(line, lineColPat, '\1 ', '')
        let line = substitute(line, linePat, '\1 ', '')
        let line = substitute(line, resultDelimPat, '\1', 'g')
        let line = substitute(line, resultPat, '\1', 'g')
        call add(lines, line)
    endfor

    return lines
endfunction

function! ags#makeEditable()
    let lines      = ags#buf#readViewResultsBuffer()
    let s:editData = s:readEditData(lines)

    let lines       = s:processLinesForEdit(lines)
    let s:editLines = lines

    call ags#buf#openEditResultsBuffer()
    call ags#buf#replaceLines(lines)
    exec 'setlocal nomodified'
    call s:clearUndo()
    exec 'setlocal nomodified'
endfunction

" TODO: rename all echox methods to logx and move to own file
"       then replace all echom call with logx
function! s:echoe(msg)
    echohl Error
    echom a:msg
    echohl None
endfunction

function! s:echoi(msg)
    echohl MoreMsg
    echom a:msg
    echohl None
endfunction

function! ags#writeChanges()
    let olines = s:editLines
    let elines = ags#buf#readEditResultsBuffer()
    let changes = {}

    if len(olines) != len(elines)
        call s:echoe('Original number of lines has changed. Write cancelled.')
        return
    endif

    let idx = 0
    while idx < len(olines)
        let eline = elines[idx]
        let oline = olines[idx]

        if eline !=# oline
            let key = s:editData[idx].file
            if !has_key(changes, key)
                let changes[key] = []
            endif

            let value = {
                        \ 'line'     : s:editData[idx].row,
                        \ 'data'     : s:sub(eline, '^\s\{}\d\{}\s\{2}', ''),
                        \ 'origData' : eline,
                        \ 'origLine' : idx
                        \ }

            call add(changes[key], value)
        endif

        let idx = idx + 1
    endwhile

    let fileCount = 0
    let lineCount = 0

    for [file, change] in items(changes)
        let lines     = readfile(file, 'b')
        let currCount = 0

        for ch in change
            if ch.line > 0
                let lines[ch.line - 1] = ch.data
                let currCount = currCount + 1
            endif
            let s:editLines[ch.origLine] = ch.origData
        endfor

        if currCount > 0
            let fileCount = fileCount + 1
            let lineCount = lineCount + currCount
            execute 'silent doautocmd FileWritePre ' . file
            call writefile(lines, file, 'b')
            execute 'silent doautocmd FileWritePost ' . file
        endif
    endfor

    call s:echoi(lineCount . ' lines changed in ' . fileCount . ' files')

    let nr = bufwinnr('search-results.agse')
    exec nr . 'wincmd w'
    exec 'setlocal nomodified'

    " TODO: after a successful replace update s:editLines to contain the saved
    " changes
endfunction

function! s:clearUndo()
    let prev = &undolevels
    set undolevels=-1
    exe "normal a \<Bs>\<Esc>"
    let &undolevels = prev
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

" Performs a search with the specified {args}. If {add} is true
" the results will be added to the search results window; otherwise,
" they will replace any previous results.
"
function! ags#search(args, add)
    let args  = empty(a:args) ? expand('<cword>') : a:args
    let data  = s:run(args)
    let lines = s:processSearchData(data)
    if empty(lines)
        echom "No matches for " . string(a:args)
    else
        call s:show(lines, a:add)
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
