" Search data map, used for determining the file and line number where a search
" result line belongs
let s:dataMap = {}

" Last edited search results, used to determine which lines have changed
let s:editLines = []

" Line number offset
" The actual file line starts after the line number offset
let s:offset = 0

" Cursor operations
let s:cur = {}

" Regex pattern functions
let s:pat  = function('ags#pat#mkpat')
let s:gsub = function('ags#pat#gsub')
let s:sub  = function('ags#pat#sub')

" Clears undo history
"
function! s:clearUndoHistory()
    let prev = &undolevels
    set undolevels=-1
    exe "normal a \<Bs>\<Esc>"
    let &undolevels = prev
endfunction

" Prepares the search {lines} for display in editable mode
"
function! s:processLinesForEdit(lines)
    if empty(a:lines) | return [] | endif

    let lines = []

    let lineColPat     = s:pat('^:\lineStart:\([ 0-9]\{-1,}\):lineColEnd:')
    let linePat        = s:pat('^:\lineStart:\([ 0-9]\{-1,}\):lineEnd:')
    let resultDelimPat = s:pat(':resultStart::hlDelim:\(.\{-1,}\):hlDelim::end:')
    let resultPat      = s:pat(':resultStart:\(.\{-1,}\):end:')
    let lineSubst      = g:ags_edit_show_line_numbers ? '\1' : ''

    for line in a:lines
        let line = substitute(line, lineColPat, lineSubst, '')
        let line = substitute(line, linePat, lineSubst, '')
        let line = substitute(line, resultDelimPat, '\1', 'g')
        let line = substitute(line, resultPat, '\1', 'g')
        call add(lines, line)
    endfor

    return lines
endfunction

function! s:calculateOffset(lines)
    return len(a:lines) < 2 ? 0 : strlen(matchstr(a:lines[1], '^\s\{}\d\{}\s'))
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

" Gets the changed lines from the search results window
"
" Returns a dictionary of the form { file: lineInfo }
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
        let nrpat = '^.\{' . string(s:offset) . '}'

        if eline !=# oline
            let file = s:dataMap[idx].file

            if !has_key(changes, file)
                let changes[file] = []
            endif

            call add(changes[file], {
                        \ 'fileLine'     : s:dataMap[idx].row,
                        \ 'fileData'     : substitute(eline, nrpat, '',  ''),
                        \ 'fileDataPrev' : substitute(oline, nrpat, '',  ''),
                        \ 'editLine'     : idx,
                        \ 'editData'     : eline
                        \ })
        endif

        let idx = idx + 1
    endwhile

    return [ 0,  changes ]
endfunction

" Writes the search results window changes to their corresponding files
"
function! ags#edit#write()
    let olines           = s:editLines
    let elines           = ags#buf#readEditResultsBuffer()
    let [ err, changes ] = s:changes()
    let fileCount        = 0
    let lineCount        = 0
    let skipFileCount    = 0
    let skipLineCount    = 0

    if err
        call ags#log#error('Original number of lines has changed. Write cancelled.')
        return
    endif

    for [file, change] in items(changes)
        let lines   = readfile(file, 'b')
        let cnt     = 0
        let skipCnt = 0
        let skip    = g:ags_edit_skip_if_file_changed

        for ch in change
            if ch.fileLine > 0
                if skip && lines[ch.fileLine - 1] !=# ch.fileDataPrev
                    let skipCnt = skipCnt + 1

                    let eline = getline(ch.editLine + 1)
                    let npat  = '^.\{' . string(s:offset) . '}'
                    let enum  = matchstr(eline,  npat)
                    let nline = enum . lines[ch.fileLine - 1]

                    let s:editLines[ch.editLine] = nline
                    call setline(ch.editLine + 1, nline)
                else
                    let lines[ch.fileLine - 1] = ch.fileData
                    let cnt = cnt + 1
                    let s:editLines[ch.editLine] = ch.editData
                endif
            endif
        endfor

        if skipCnt > 0
            let skipFileCount = skipFileCount + 1
            let skipLineCount = skipLineCount + skipCnt
        endif

        if cnt > 0
            let fileCount = fileCount + 1
            let lineCount = lineCount + cnt
            let path      = fnameescape(file)

            if filewritable(path)
                execute 'silent doautocmd FileWritePre ' . path
                call writefile(lines, path, 'b')
                execute 'silent doautocmd FileWritePost ' . path
            endif
        endif
    endfor

    if lineCount == 0
        call ags#log#info('All files up to date')
    elseif skipLineCount == 0
        call ags#log#info('Updated ' . lineCount . ' lines in ' . fileCount . ' files')
    else
        call ags#log#info(
                    \ 'Updated ' .
                    \ lineCount . ' lines in ' . fileCount . ' files. ' .
                    \ 'Skipped ' .
                    \ skipLineCount . ' lines in ' . skipFileCount . ' files.')
    endif

    call ags#buf#focusResultsWindow()
    exec 'setlocal nomodified'
endfunction

" Makes the search results window editable
"
function! ags#edit#show()
    if ags#buf#openEditResultsBufferIfExists() | return | endif

    let lines     = ags#buf#readViewResultsBuffer()
    let s:dataMap = s:makeDataMap(lines)

    let lines       = s:processLinesForEdit(lines)
    let s:editLines = lines
    let s:offset    = s:calculateOffset(lines)
    let s:cur       = ags#cur#make(s:offset, '^\s\{}\d\{}\s')

    if empty(lines)
        call ags#log#warn('There are no search results to edit')
        return
    endif

    call ags#buf#openEditResultsBuffer()
    call ags#buf#replaceLines(lines)
    call s:clearUndoHistory()
    exec 'setlocal nomodified'
    exec 'normal 2Gw'
endfunction

" Moves the cursor to the start of the file line
"
function! ags#edit#moveCursorToStart()
    call s:cur.moveToStart()
endfunction

" Moves the cursor to the start of the file line if it is outside of the
" editable file line
"
function! ags#edit#moveCursorToStartIfOut(offset)
    call s:cur.moveToStartIfOutside(a:offset)
endfunction
