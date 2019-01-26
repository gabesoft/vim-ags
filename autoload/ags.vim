
" The position of the last highlighted search pattern
let s:hlpos = []

" Last copied value
let s:lastCopy = ''

" Search results statistics
let s:stats = {}

" Results accumulated during an async request
let s:lines = []

" Last line of search results saved during an async request
let s:lastLine = ''

" Flag that indicates whether to add to the search results
" window after a search
let s:add = 0

" Regex patterns cache
let s:patt = {
            \ 'lineNo'           : '^[1;30m\(\d\{1,}\)',
            \ 'lineNoCapture'    : '\[1;30m\([ 0-9]\{-1,}\)\[0m\[K-',
            \ 'lineColNoCapture' : '\[1;30m\([ 0-9]\{-1,}\)\[0m\[K:\d\{-1,}:',
            \ 'file'             : '^[1;31m.\{-}[0m[K$',
            \ 'fileCapture'      : '[1;31m\(.\{-}\)[0m[K',
            \ 'result'           : '[32;40m.\{-}[0m[K',
            \ 'resultCapture'    : '\[32;40m\(.\{-}\)\[0m\[K',
            \ 'resultReplace'    : '[32;40m\1[0m[K'
            \ }

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

    call ags#buf#setLastWinnr(winnr())
    call ags#buf#openViewResultsBuffer()
    call s:execw(obj)
    call s:printStats(0, 0, 1)
endfunction

function! s:isNewLine(data)
    let data    = substitute(a:data, '\e', '', 'g')
    let data    = substitute(data, '["\(\d\{-};\d\{-}\)"m', '[\1m', 'g')
    return data =~ s:patt.lineNo || data =~ s:patt.file
endfunction

" Prepares the search {data} for display
"
function! s:processSearchData(data)
    let data    = substitute(a:data, '\e', '', 'g')
    let data    = substitute(data, '["\(\d\{-};\d\{-}\)"m', '[\1m', 'g')
    let lines   = split(data, '\n')
    let lmaxlen = 9

    if !s:asyncEnabled()
        for line in lines
            let lmatch  = matchstr(line, s:patt.lineNo)
            let lmaxlen = max([ strlen(lmatch), lmaxlen ])
        endfor
    endif

    let results = []
    for line in lines
        let llen = strlen(matchstr(line, s:patt.lineNo))
        let wlen = lmaxlen - llen

        " right justify line numbers and add a space after
        let line = substitute(line, s:patt.lineNo, '[1;30m' . repeat(' ', wlen) . '\1 ', '')

        call add(results, line)
    endfor

    return results
endfunction

" Gathers statistics about the search results from {lines}
"
function! s:gatherStatistics(lines)
    if len(a:lines) > g:ags_stats_max_ln | return {} | endif

    let stats      = {}
    let totalCount = 0
    let fileCount  = 0
    let index      = 0
    let llines     = len(a:lines)
    let curFile    = ''

    while index < llines
        let line      = a:lines[index]
        let currCount = 0

        if line =~ s:patt.file
            let fileCount = fileCount + 1
            let curFile = substitute(line, s:patt.fileCapture, '\1', '')
        elseif line =~ s:patt.result
            let occurences = ags#pat#matchCount(line, s:patt.result, 0)
            let totalCount = totalCount + occurences
            let currCount  = currCount + occurences
        endif

        let index = index + 1
        let stats[index] = {
                    \ 'file'     : fileCount,
                    \ 'filePath' : curFile,
                    \ 'result'   : totalCount,
                    \ 'matches'  : currCount
                    \ }
    endw

    return { 'data': stats, 'files': fileCount, 'results': totalCount }
endfunction

" Returns the cursor position when opening a file
" from the {lineNo} in the search results window
"
function! s:resultPosition(lineNo)
    let line = getline(a:lineNo)
    let col  = 0

    if line =~ s:patt.file
        let line = getline(a:lineNo + 1)
    endif

    if strlen(line) == 0 || line =~ '^--$'
        let line = getline(a:lineNo - 1)
    endif

    if line =~ '^[1;30m\s\{}\d\{1,}\s\{}[0m[K:\d\{-1,}:'
        let col = matchstr(line, ':\zs\d\{1,}:\@=')
    endif

    let row = matchstr(line, '^[1;30m\s\{}\zs\d\{1,}\ze\s\{}[\@=')

    return [0, row, col, 0]
endfunction

" Gets results statistics for the current cursor position
"
function! s:getCurrentStats()
    if empty(s:stats) | return {} | endif
    if !has_key(s:stats.data, line('.')) | return {} | endif

    let lnum     = line('.')
    let file     = s:stats.data[lnum].file
    let filePath = s:stats.data[lnum].filePath
    let fileName = strlen(filePath) ? fnamemodify(filePath, ':t') : filePath
    let lmatches = s:stats.data[lnum].matches
    let fileMsg  = 'File(' . file . '/' . s:stats.files . ')'

    if lmatches <= 1
        let result = s:stats.data[lnum].result
    else
        let line      = getline('.')
        let remaining = ags#pat#matchCount(getline('.'),  s:patt.result, col('.') - 1)
        let result    = s:stats.data[lnum].result - remaining + 1
    endif

    let resultMsg = 'Result(' . result . '/' . s:stats.results . ')'

    return { 'file': fileMsg, 'result': resultMsg, 'fileName': fileName }
endfunction

" Prints search results statistics
"
" {r} - print result info
" {f} - print file info
" {t} - print totals info
function! s:printStats(r, f, t)
    if g:ags_no_stats | return | endif

    let msg = s:getCurrentStats()

    if empty(msg) | return | endif

    if a:r
        echohl None
        redraw | echon msg.result . ' '
    endif

    if !a:r
        redraw
    endif

    if a:f
        echohl MoreMsg
        echon msg.file
    endif

    if a:t
        echohl Underlined
        redraw | echom s:stats.results . ' results found in ' . s:stats.files . ' files'
    endif

    echohl None
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

" Returns true if async operations are available and enabled
"
function! s:asyncEnabled()
    return g:ags_enable_async && has('nvim')
endfunction

" Returns the next lines to be displayed given the {data} received
" during an stdout event
"
function! s:getAsyncLines(data)
    let first   = ''
    let last    = ''
    let lines   = []
    let hasLast = strlen(s:lastLine) > 0

    if len(a:data) == 1
        if hasLast
            let last = a:data[0]
        else
            let first = a:data[0]
        endif
    elseif len(a:data) > 1
        let first = a:data[0]
        let last = a:data[-1]
        let lines = a:data[1:-2]
    endif

    if s:isNewLine(first)
        let lines = [first] + lines
        if hasLast
            let lines = [s:lastLine] + lines
        endif
    else
        let lines = [s:lastLine . first] + lines
    endif

    let s:lastLine = last

    return lines
endfunction

" Displays an error when an async search fails
"
function! s:onSearchError(job_id, data, event)
    call ags#log#warn(string(a:data))
    call ags#run#agAsyncUpdateJobId(a:job_id)
endfunction

" Populates the search results window during an async search
"
function! s:onSearchOut(job_id, data, event)
    let lines = s:getAsyncLines(a:data)
    let data  = join(lines, "\n")
    let start = empty(s:lines)

    call s:showSearchResults(data)

    if start
        call ags#log#info('Search started')
        call ags#run#agAsyncUpdateJobId(a:job_id)
        redraw
    else
        if ags#run#agAsyncWasKilled() == 0
            call ags#log#info('Searching...')
        else
            call ags#log#info('Search aborted')
        endif
        call ags#run#agAsyncUpdateJobId(a:job_id)
    end

    let s:add = 1
endfunction

" Prints a message when an async search is done
"
function! s:onSearchDone(job_id, data, event)
    call ags#run#agAsyncUpdateJobId(0)
    call s:showSearchResults(s:lastLine)
    if ags#run#agAsyncWasKilled() == 0
        call ags#log#info('Search complete')
    endif
    call s:afterSearchDone()
endfunction

" Displays the search {data} in the results window
"
function! s:showSearchResults(data)
    let lines   = s:processSearchData(a:data)
    let args    = ags#run#getLastArgs()
    let s:lines = s:lines + lines

    if !s:asyncEnabled() && len(lines) == 1
        call ags#log#warn(lines[0])
    elseif len(lines) > 1
        call s:show(lines, s:add)
    endif
endfunction

" Collects statistics after a search is done
"
function! s:afterSearchDone()
    if empty(s:lines)
        let args = ags#run#getLastArgs()
        call ags#log#warn('No matches for ' . string(args))
    else
        let s:stats = s:gatherStatistics(s:lines)
    endif
endfunction

" Returns a string that could be used in the status line to indicate
" the current cursor position within the search results
"
function! ags#get_status_string()
    let msg = s:getCurrentStats()
    return empty(msg) ? '' : msg.result . ' ' . msg.file . ' ' . msg.fileName
endfunction

" Performs a search with the specified {args} and according to {cmd}.
"
" {cmd|add}  the new results will be added to previous results in the search window
" {cmd|last} ignores {args} and runs the last search
"
function! ags#search(args, cmd)
    let last    = a:cmd ==# 'last'
    let s:add   = a:cmd ==# 'add'
    let args    = ''
    let s:lines = []

    if last && !ags#run#hasLastCmd()
        call ags#log#warn("There is no previous search")
        return
    elseif last
        let args = ags#run#getLastArgs()
    else
        let args  = empty(a:args) ? expand('<cword>') : a:args
    endif

    if s:asyncEnabled()
        call ags#run#agAsync(args,
                    \ function('s:onSearchOut'),
                    \ function('s:onSearchDone'),
                    \ function('s:onSearchError'))
    else
        let data = ags#run#ag(args)
        call s:showSearchResults(data)
        call s:afterSearchDone()
    endif
endfunction

" Returns the file path for the search results
" relative to {lineNo}
"
function! ags#filePath(lineNo)
    let nr = a:lineNo

    while nr >= 0 && getline(nr) !~ s:patt.file
        let nr = nr - 1
    endw

    return substitute(getline(nr), s:patt.fileCapture, '\1', '')
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
    let text = substitute(text, s:patt.fileCapture, '\1', 'g')
    let text = substitute(text, s:patt.lineColNoCapture, '', 'g')
    let text = substitute(text, s:patt.lineNoCapture, '', 'g')
    let text = substitute(text, s:patt.resultCapture, '\1', 'g')

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
    let path  = ags#filePath(a:lineNo)
    let pos   = s:resultPosition(a:lineNo)
    let flags = has_key(s:wflags, a:flags) ? s:wflags[a:flags] : 'above'
    let wpos  = a:flags == 's'
    let reuse = a:flags == 'u'

    if filereadable(path)
        call ags#buf#openBuffer(fnameescape(path), flags, wpos, reuse)
        call setpos('.', pos)

        if a:preview
            exec 'normal zz'
            exec 'wincmd p'
        endif
    endif
endfunction

" Navigates the next result pattern on the same line
"
function! ags#navigateResultsOnLine()
    let line = getline('.')
    let result = s:patt.result
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
    let flags = a:0 > 0 ? a:1 : 'w'

    call search(s:patt.result, flags)
    call matchadd('agsvResultPatternOn', '\%#' . s:patt.result, 999)
    call s:printStats(1, 1, 0)
endfunction

" Navigates the search results file paths
"
" {flags} search flags (b, B, w, W)
function! ags#navigateResultsFiles(...)
    let flags = a:0 > 0 ? a:1 : 'w'
    call search(s:patt.file, flags)
    exec 'normal zt'
    call s:printStats(0, 1, 0)
endfunction

function! ags#quit()
    call ags#buf#closeResultsBuffer()
    call ags#run#agAsyncStop()
endfunction

function! ags#usage()
    for u in s:usage | echom u | endfor
endfunction
