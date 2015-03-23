augroup agsResultsWindowView
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter *.agsv set filetype=agsv
  autocmd BufLeave,BufWinLeave *.agsv call ags#clearHlResult()
  autocmd BufEnter,BufWinEnter *.agsv call ags#navigateResultsOnLine()
  autocmd CursorHold,CursorMoved,BufLeave,BufWinLeave *.agsv call ags#cleanYankedText()
augroup END
