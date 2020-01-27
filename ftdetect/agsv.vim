augroup agsResultsWindowView
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter *.agsv set filetype=agsv
  autocmd BufEnter,BufWinEnter *.agsv call ags#navigateResultsOnLine()
  autocmd TextYankPost *.agsv call ags#cleanYankedText()
augroup END
