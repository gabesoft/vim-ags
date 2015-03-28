if exists('g:ags_loaded') || &cp || v:version < 700 | finish | endif

let g:ags_loaded = 1

if !exists('g:ags_agexe')      | let g:ags_agexe = 'ag'      | endif
if !exists('g:ags_agmaxcount') | let g:ags_agmaxcount = 2000 | endif
if !exists('g:ags_agcontext')  | let g:ags_agcontext = 3     | endif

if !exists('g:ags_edit_skip_if_file_changed')
    let g:ags_edit_skip_if_file_changed = 0
endif

if !exists('g:ags_edit_show_line_numbers')
    let g:ags_edit_show_line_numbers = 0
endif

if !exists('g:ags_agargs')
    " Predefined search arguments
    " arg : [ value, short-name, default ]
    let g:ags_agargs = {
                \ '--break'             : [ '', '' ],
                \ '--color'             : [ '', '' ],
                \ '--color-line-number' : [ '"1;30"', '' ],
                \ '--color-match'       : [ '"32;40"', '' ],
                \ '--color-path'        : [ '"1;31"', '' ],
                \ '--column'            : [ '', '' ],
                \ '--context'           : [ 'g:ags_agcontext', '-C', '3' ],
                \ '--filename'          : [ '', '' ],
                \ '--group'             : [ '', '' ],
                \ '--heading'           : [ '', '-H' ],
                \ '--max-count'         : [ 'g:ags_agmaxcount', '-m', '2000' ],
                \ '--numbers'           : [ '', '' ]
                \ }
endif

command! -nargs=* -complete=file Ags    call ags#search(<q-args>, '')
command! -nargs=* -complete=file AgsAdd call ags#search(<q-args>, 'add')
command! -nargs=0 AgsLast               call ags#search(<q-args>, 'last')
command! -nargs=0 AgsEditSearchResults  call ags#edit#show()
command! -nargs=0 AgsQuit               call ags#quit()
command! -nargs=0 AgsShowLastCommand    call ags#run#getLastCmd()
