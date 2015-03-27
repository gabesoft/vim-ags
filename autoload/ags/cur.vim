let s:CUR = {}

function! s:getCursorCol()
    return getpos('.')[2]
endfunction

function! s:setCursorCol(col)
    let pos = getpos('.')
    let pos[2] = a:col
    call setpos('.', pos)
endfunction

function! s:incCursorCol(offset)
    call s:setCursorCol(s:getCursorCol() + a:offset)
endfunction

function! s:CUR.New(offset, lineNumberPat)
    let curObj = copy(self)
    let curObj.offset = a:offset
    let curObj.lineNumberPat = a:lineNumberPat
    return curObj
endfunction

function! s:CUR.isLineNumber()
    let line = getline('.')
    let mlen = len(matchstr(line, self.lineNumberPat))
    return mlen == self.offset
endfunction

function! s:CUR.isOutside()
    return s:getCursorCol() < self.offset + 1
endfunction

function! s:CUR.moveToStart()
    if self.isLineNumber()
        let line   = getline('.')
        let lpat   = '^.\{' . string(self.offset) . '}'
        let line   = substitute(line, lpat, '', '')
        let spaces = len(matchstr(line,  '^\s\{}'))

        call s:setCursorCol(self.offset + spaces + 1)
    else
        exec 'normal ^'
    endif
    exec 'startinsert'
endfunction

function! s:CUR.moveToStartIfOutside(offset)
    if self.isOutside() && self.isLineNumber()
        call s:setCursorCol(self.offset + 1)
    else
        call s:incCursorCol(a:offset)
    endif
    exec 'startinsert'
endfunction

" Creates a cursor object
"
function! ags#cur#make(offset, lineNumberPat)
    return s:CUR.New(a:offset, a:lineNumberPat)
endfunction
