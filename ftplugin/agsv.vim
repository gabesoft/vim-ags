setlocal buftype=nofile
setlocal conceallevel=3
setlocal concealcursor=nvic

command! -buffer AgsNextResult call ags#navigateResults('W')
command! -buffer AgsPrevResult call ags#navigateResults('bW')
command! -buffer AgsNextFile   call ags#navigateResultsFiles('W')
command! -buffer AgsPrevFile   call ags#navigateResultsFiles('bW')

command! -buffer AgsFilePathShow echom ags#filePath(line('.'))
command! -buffer AgsFilePathCopy echom ags#copyFilePath(line('.'), 1)

command! -buffer AgsOpenFileAbove        call ags#openFile(line('.'), 'a', 0)
command! -buffer AgsOpenFileBelow        call ags#openFile(line('.'), 'b', 0)
command! -buffer AgsOpenFileLeft         call ags#openFile(line('.'), 'l', 0)
command! -buffer AgsOpenFileRight        call ags#openFile(line('.'), 'r', 0)
command! -buffer AgsOpenFileSame         call ags#openFile(line('.'), 's', 0)
command! -buffer AgsOpenFileReuse        call ags#openFile(line('.'), 'u', 0)
command! -buffer AgsOpenFileReuseAndQuit call ags#openFile(line('.'), 'u', 0) | call ags#quit()

command! -buffer AgsViewFileAbove call ags#openFile(line('.'), 'a', 1)
command! -buffer AgsViewFileBelow call ags#openFile(line('.'), 'b', 1)
command! -buffer AgsViewFileLeft  call ags#openFile(line('.'), 'l', 1)
command! -buffer AgsViewFileRight call ags#openFile(line('.'), 'r', 1)
command! -buffer AgsViewFileSame  call ags#openFile(line('.'), 's', 1)
command! -buffer AgsViewFileReuse call ags#openFile(line('.'), 'u', 1)

command! -buffer AgsUsage call ags#usage()

nnoremap <buffer> r :AgsNextResult<CR>
nnoremap <buffer> R :AgsPrevResult<CR>
nnoremap <buffer> p :AgsNextFile<CR>
nnoremap <buffer> P :AgsPrevFile<CR>
nnoremap <buffer> a :AgsFilePathShow<CR>
nnoremap <buffer> c :AgsFilePathCopy<CR>
nnoremap <buffer> E :AgsEditSearchResults<CR>
nnoremap <buffer> u :AgsUsage<CR>
nnoremap <buffer> q :AgsQuit<CR>

nnoremap <buffer> oa   : AgsOpenFileAbove<CR>
nnoremap <buffer> ob   : AgsOpenFileBelow<CR>
nnoremap <buffer> ol   : AgsOpenFileLeft<CR>
nnoremap <buffer> or   : AgsOpenFileRight<CR>
nnoremap <buffer> os   : AgsOpenFileSame<CR>
nnoremap <buffer> ou   : AgsOpenFileReuse<CR>
nnoremap <buffer> <CR> : AgsOpenFileReuse<CR>

nnoremap <buffer> xu : AgsOpenFileReuseAndQuit<CR>

nnoremap <buffer> OA   : AgsViewFileAbove<CR>
nnoremap <buffer> OB   : AgsViewFileBelow<CR>
nnoremap <buffer> OL   : AgsViewFileLeft<CR>
nnoremap <buffer> OR   : AgsViewFileRight<CR>
nnoremap <buffer> OS   : AgsOpenFileSame<CR>
nnoremap <buffer> OU   : AgsViewFileReuse<CR>
