if has("autocmd")
    autocmd BufNewFile,BufRead *.agsv set filetype=agsv
    autocmd BufLeave,BufWinLeave *.agsv call ags#ClearResultsOn()
    autocmd BufEnter,BufWinEnter *.agsv call ags#HighlightResult()
endif
