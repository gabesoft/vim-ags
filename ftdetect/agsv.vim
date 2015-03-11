if has("autocmd")
    autocmd BufNewFile,BufRead *.agsv set filetype=agsv
    autocmd BufLeave,BufWinLeave *.agsv call ags#ClearHlResult()
    autocmd BufEnter,BufWinEnter *.agsv call ags#NavigateResultsOnLine()
endif
