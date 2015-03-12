augroup agsResultsWindow
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter *.agsv set filetype=agsv
  autocmd BufLeave,BufWinLeave *.agsv call ags#ClearHlResult()
  autocmd BufEnter,BufWinEnter *.agsv call ags#NavigateResultsOnLine()
  autocmd CursorHold,CursorMoved,BufLeave,BufWinLeave *.agsv call ags#CleanYankedText()
augroup END
