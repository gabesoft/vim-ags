setlocal buftype=nofile
setlocal conceallevel=3
setlocal concealcursor=nvic

command! -buffer AgNextResult call ag#NavigateResults('W')
command! -buffer AgPrevResult call ag#NavigateResults('bW')

command! -buffer AgNextFile call ag#NavigateResultsFiles('W')
command! -buffer AgPrevFile call ag#NavigateResultsFiles('bW')

command! -buffer AgFilePath echom ag#FilePath(line('.'))
command! -buffer AgUsage call ag#Usage()

command! -buffer AgOpenFileAbove call ag#OpenFile(line('.'), 'a')
command! -buffer AgOpenFileBelow call ag#OpenFile(line('.'), 'b')
command! -buffer AgOpenFileLeft call ag#OpenFile(line('.'), 'l')
command! -buffer AgOpenFileRight call ag#OpenFile(line('.'), 'r')
command! -buffer AgOpenFileSame call ag#OpenFile(line('.'), 's')

nnoremap <buffer> r :AgNextResult<CR>
nnoremap <buffer> R :AgPrevResult<CR>
nnoremap <buffer> p :AgNextFile<CR>
nnoremap <buffer> P :AgPrevFile<CR>
nnoremap <buffer> a :AgFilePath<CR>
nnoremap <buffer> u :AgUsage<CR>

nnoremap <buffer> oa : AgOpenFileAbove<CR>
nnoremap <buffer> ob : AgOpenFileBelow<CR>
nnoremap <buffer> ol : AgOpenFileLeft<CR>
nnoremap <buffer> or : AgOpenFileRight<CR>
nnoremap <buffer> os : AgOpenFileSame<CR>

" window commands
" - open in new window (same for view but the focus stays in the results
"   window
"       - horizontal above
"       - horizontal below
"       - vertical right
"       - vertical left
" - open in the results window (replace)
" - open in new window but reuse a previously opened window
