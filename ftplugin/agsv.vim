setlocal buftype=nofile
setlocal conceallevel=3
setlocal concealcursor=nvic
setlocal scrolloff=5

command! -buffer AgsNextResult call ags#NavigateResults('W')
command! -buffer AgsPrevResult call ags#NavigateResults('bW')

command! -buffer AgsNextFile call ags#NavigateResultsFiles('W')
command! -buffer AgsPrevFile call ags#NavigateResultsFiles('bW')

command! -buffer AgsFilePath echom ags#FilePath(line('.'))
command! -buffer AgsUsage call ags#Usage()

command! -buffer AgsOpenFileAbove call ags#OpenFile(line('.'), 'a')
command! -buffer AgsOpenFileBelow call ags#OpenFile(line('.'), 'b')
command! -buffer AgsOpenFileLeft call ags#OpenFile(line('.'), 'l')
command! -buffer AgsOpenFileRight call ags#OpenFile(line('.'), 'r')
command! -buffer AgsOpenFileSame call ags#OpenFile(line('.'), 's')
command! -buffer AgsOpenFileReuse call ags#OpenFile(line('.'), 'u')
command! -buffer AgsQuit call ags#Quit()

nnoremap <buffer> r :AgsNextResult<CR>
nnoremap <buffer> R :AgsPrevResult<CR>
nnoremap <buffer> p :AgsNextFile<CR>
nnoremap <buffer> P :AgsPrevFile<CR>
nnoremap <buffer> a :AgsFilePath<CR>
"nnoremap <buffer> a :AgsFilePathShow<CR>
"nnoremap <buffer> a :AgsFilePathCopy<CR>
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
