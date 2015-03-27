setlocal buftype=acwrite
setlocal bufhidden=hide
setlocal nolist
setlocal noswapfile
setlocal conceallevel=3
setlocal concealcursor=nvic

if g:ags_edit_show_line_numbers
    command! -buffer AgsEditMoveCursorToStartBefore call ags#edit#moveCursorToStartIfOut(0)
    command! -buffer AgsEditMoveCursorToStartAfter  call ags#edit#moveCursorToStartIfOut(1)
    command! -buffer AgsEditMoveCursorToStart       call ags#edit#moveCursorToStart()

    nnoremap <buffer> i :AgsEditMoveCursorToStartBefore<CR>
    nnoremap <buffer> a :AgsEditMoveCursorToStartAfter<CR>
    nnoremap <buffer> I :AgsEditMoveCursorToStart<CR>
endif
