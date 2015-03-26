setlocal buftype=acwrite
setlocal bufhidden=hide
setlocal nolist
setlocal noswapfile
setlocal conceallevel=3
setlocal concealcursor=nvic

nnoremap <buffer> i :call ags#edit#moveCursorFromNrLine(1)<CR>
nnoremap <buffer> I :call ags#edit#moveCursorToLineStart(1, 1)<CR>

" TODO: remap a as well
