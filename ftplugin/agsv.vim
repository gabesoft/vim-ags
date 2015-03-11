setlocal buftype=nofile
setlocal conceallevel=3
setlocal concealcursor=nvic
setlocal scrolloff=5

command! -buffer AgsNextResult call ags#NavigateResults('W')
command! -buffer AgsPrevResult call ags#NavigateResults('bW')

command! -buffer AgsNextFile call ags#NavigateResultsFiles('W')
command! -buffer AgsPrevFile call ags#NavigateResultsFiles('bW')

command! -buffer AgsFilePathShow echom ags#FilePath(line('.'))
command! -buffer AgsUsage call ags#Usage()

command! -buffer AgsOpenFileAbove call ags#OpenFile(line('.'), 'a', 0)
command! -buffer AgsOpenFileBelow call ags#OpenFile(line('.'), 'b', 0)
command! -buffer AgsOpenFileLeft call ags#OpenFile(line('.'), 'l', 0)
command! -buffer AgsOpenFileRight call ags#OpenFile(line('.'), 'r', 0)
command! -buffer AgsOpenFileSame call ags#OpenFile(line('.'), 's', 0)
command! -buffer AgsOpenFileReuse call ags#OpenFile(line('.'), 'u', 0)

command! -buffer AgsViewFileAbove call ags#OpenFile(line('.'), 'a', 1)
command! -buffer AgsViewFileBelow call ags#OpenFile(line('.'), 'b', 1)
command! -buffer AgsViewFileLeft call ags#OpenFile(line('.'), 'l', 1)
command! -buffer AgsViewFileRight call ags#OpenFile(line('.'), 'r', 1)
command! -buffer AgsViewFileSame call ags#OpenFile(line('.'), 's', 1)
command! -buffer AgsViewFileReuse call ags#OpenFile(line('.'), 'u', 1)

command! -buffer AgsQuit call ags#Quit()

nnoremap <buffer> r :AgsNextResult<CR>
nnoremap <buffer> R :AgsPrevResult<CR>
nnoremap <buffer> p :AgsNextFile<CR>
nnoremap <buffer> P :AgsPrevFile<CR>
nnoremap <buffer> a :AgsFilePathShow<CR>
nnoremap <buffer> u :AgsUsage<CR>
nnoremap <buffer> q :AgsQuit<CR>

nnoremap <buffer> oa      : AgsOpenFileAbove<CR>
nnoremap <buffer> ob      : AgsOpenFileBelow<CR>
nnoremap <buffer> ol      : AgsOpenFileLeft<CR>
nnoremap <buffer> or      : AgsOpenFileRight<CR>
nnoremap <buffer> os      : AgsOpenFileSame<CR>
nnoremap <buffer> ou      : AgsOpenFileReuse<CR>
nnoremap <buffer> <Enter> : AgsOpenFileReuse<CR>

" window commands
" - open in new window (same for view but the focus stays in the results
"   window
"       - horizontal above
"       - horizontal below
"       - vertical right
"       - vertical left
" - open in the results window (replace)
" - open in new window but reuse a previously opened window
