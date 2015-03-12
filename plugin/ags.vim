" requires ag version >= 0.29.1

"if exists('g:loaded_ags') || &cp || v:version < 700 | finish | endif
"let g:loaded_ags = 1

if !exists('g:ags_agexe')      | let g:ags_agexe = '/usr/local/bin/ag' | endif
if !exists('g:ags_agmaxcount') | let g:ags_agmaxcount = 200            | endif
if !exists('g:ags_agcontext')  | let g:ags_agcontext = 3               | endif

command! -nargs=* -complete=file Ags call ags#Search(<q-args>, 0)
command! -nargs=* -complete=file AgsAdd call ags#Search(<q-args>, 1)
