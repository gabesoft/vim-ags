" Last edited search results, used to determine which lines have changed
let s:editLines = []

" Search data map, used for determining the file and line number where a search
" result line belongs
let s:dataMap  = {}

" Regex pattern functions
let s:pat  = function('ags#pat#mkpat')
let s:gsub = function('ags#pat#gsub')
let s:sub  = function('ags#pat#sub')

" Clears undo history
"
function! s:clearUndo()
    let prev = &undolevels
    set undolevels=-1
    exe "normal a \<Bs>\<Esc>"
    let &undolevels = prev
endfunction

" Gets the changed lines from the search results window
"
function! s:changes()
    let olines  = s:editLines
    let elines  = ags#buf#readEditResultsBuffer()
    let changes = {}
    let idx     = 0

    if len(olines) != len(elines) | return [ 1, changes ] | endif

    while idx < len(olines)
        let eline = elines[idx]
        let oline = olines[idx]

        if eline !=# oline
            let key = s:dataMap[idx].file

            if !has_key(changes, key)
                let changes[key] = []
            endif

            call add(changes[key], {
                        \ 'line'     : s:dataMap[idx].row,
                        \ 'data'     : substitute(eline, '^\s\{}\d\{}\s\{1}', '',  ''),
                        \ 'origData' : eline,
                        \ 'origLine' : idx
                        \ })
        endif

        let idx = idx + 1
    endwhile

    return [ 0,  changes ]
endfunction

" Prepares the search {lines} for display in editable mode
"
function! s:processLinesForEdit(lines)
    let lines          = []

    let lineColPat     = s:pat('^:\lineStart:\([ 0-9]\{-1,}\):lineColEnd:')
    let linePat        = s:pat('^:\lineStart:\([ 0-9]\{-1,}\):lineEnd:')
    let resultDelimPat = s:pat(':resultStart::hlDelim:\(.\{-1,}\):hlDelim::end:')
    let resultPat      = s:pat(':resultStart:\(.\{-1,}\):end:')

    for line in a:lines
        let line = substitute(line, lineColPat, '\1', '')
        let line = substitute(line, linePat, '\1', '')
        let line = substitute(line, resultDelimPat, '\1', 'g')
        let line = substitute(line, resultPat, '\1', 'g')
        call add(lines, line)
    endfor

    return lines
endfunction

" Makes a data hash map from {lines}
" returns a dictionary of the form searchLineNumber : [ filePath, fileLineNumer ]
"
function! s:makeDataMap(lines)
    let data    = {}
    let file    = ''
    let idx     = 0
    let linePat = s:pat('^:lineStart:\s\{}\zs\d\{1,}\ze\s\{}[\@=')
    let filePat = s:pat('^:file:')

    for line in a:lines
        if line =~ filePat

            let file      = substitute(line,  filePat, '\1', '')
            let data[idx] = { 'file': file, 'row': 0 }
        elseif line =~ linePat

            let row       = matchstr(line, linePat)
            let data[idx] = { 'file': file, 'row': row }
        else
            let data[idx] = { 'file': file, 'row': 0 }
        endif

        let idx = idx + 1
    endfor

    return data
endfunction

" Makes the search results window editable
"
function! ags#edit#show()
    let lines     = ags#buf#readViewResultsBuffer()
    let s:dataMap = s:makeDataMap(lines)

    let lines       = s:processLinesForEdit(lines)
    let s:editLines = lines

    if empty(lines)
        call ags#log#warn('There are no search results to edit')
        return
    endif

    call ags#buf#openEditResultsBuffer()
    call ags#buf#replaceLines(lines)
    call s:clearUndo()
    exec 'setlocal nomodified'
endfunction

" Writes the search results window changes to their corresponding files
"
function! ags#edit#write()
    let olines           = s:editLines
    let elines           = ags#buf#readEditResultsBuffer()
    let [ err, changes ] = s:changes()
    let fileCount        = 0
    let lineCount        = 0

    if err
        call ags#log#error('Original number of lines has changed. Write cancelled.')
        return
    endif

    for [file, change] in items(changes)
        let lines = readfile(file, 'b')
        let cnt   = 0
        let path  = fnameescape(file)

        for ch in change
            if ch.line > 0
                let lines[ch.line - 1] = ch.data
                let cnt = cnt + 1
            endif
            let s:editLines[ch.origLine] = ch.origData
        endfor

        if cnt > 0
            let fileCount = fileCount + 1
            let lineCount = lineCount + cnt

            if filewritable(path)
              execute 'silent doautocmd FileWritePre ' . path
              call writefile(lines, path, 'b')
              execute 'silent doautocmd FileWritePost ' . path
            endif
        endif
    endfor

    call ags#log#info('Updated ' . lineCount . ' lines in ' . fileCount . ' files')
    call ags#buf#focusResultsWindow()
    exec 'setlocal nomodified'
endfunction
