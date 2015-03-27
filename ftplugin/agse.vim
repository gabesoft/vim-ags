setlocal buftype=acwrite
setlocal bufhidden=hide
setlocal nolist
setlocal noswapfile
setlocal conceallevel=3
setlocal concealcursor=nvic

command! -buffer AgsEditMoveCursorToStartBefore call ags#edit#moveCursorToStartIfOut(0)
command! -buffer AgsEditMoveCursorToStartAfter  call ags#edit#moveCursorToStartIfOut(1)
command! -buffer AgsEditMoveCursorToStart       call ags#edit#moveCursorToStart()

nnoremap <buffer> i :silent AgsEditMoveCursorToStartBefore<CR>
nnoremap <buffer> a :silent AgsEditMoveCursorToStartAfter<CR>
nnoremap <buffer> I :silent AgsEditMoveCursorToStart<CR>
