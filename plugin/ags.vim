" ag version 0.29.1
" TODO: parameterize everything
"       clean up code
"       write doc
"       maybe add param to add to results instead of replace

command! -nargs=* -complete=file Ags call ags#Search(<q-args>)
