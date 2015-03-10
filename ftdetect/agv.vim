if has("autocmd")
    autocmd BufNewFile,BufRead *.agv set filetype=agv
    "autocmd CursorMoved *.agv call ag#ClearResultsOn()
    autocmd BufLeave,BufWinLeave *.agv call ag#ClearResultsOn()
    autocmd BufEnter,BufWinEnter *.agv call ag#HighlightResult()
endif
