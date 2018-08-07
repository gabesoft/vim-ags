if exists('g:ags_loaded') || &cp || v:version < 700 | finish | endif

let g:ags_loaded = 1

let g:ags_agexe                     = get(g:, 'ags_agexe', 'ag')
let g:ags_agmaxcount                = get(g:, 'ags_agmaxcount', 2000)
let g:ags_agcontext                 = get(g:, 'ags_agcontext', 3)
let g:ags_stats_max_ln              = get(g:, 'ags_stats_max_ln', 5000)
let g:ags_edit_skip_if_file_changed = get(g:, 'ags_edit_skip_if_file_changed', 0)
let g:ags_edit_show_line_numbers    = get(g:, 'ags_edit_show_line_numbers', 0)
let g:ags_no_stats                  = get(g:, 'ags_no_stats', 0)
let g:ags_winheight                 = get(g:, 'ags_winheight', '')
let g:ags_winplace                  = get(g:, 'ags_winplace', 'bottom')
let g:ags_enable_async              = get(g:, 'ags_enable_async', 1)
let g:ags_results_per_tab           = get(g:, 'ags_results_per_tab', 0)

if !exists('g:ags_agargs')
    " Predefined search arguments
    " arg : [ value, short-name ]
    let g:ags_agargs = {
                \ '--break'             : [ '', '' ],
                \ '--color'             : [ '', '' ],
                \ '--color-line-number' : [ '"1;30"', '' ],
                \ '--color-match'       : [ '"32;40"', '' ],
                \ '--color-path'        : [ '"1;31"', '' ],
                \ '--column'            : [ '', '' ],
                \ '--context'           : [ 'g:ags_agcontext', '-C' ],
                \ '--filename'          : [ '', '' ],
                \ '--group'             : [ '', '' ],
                \ '--heading'           : [ '', '-H' ],
                \ '--max-count'         : [ 'g:ags_agmaxcount', '-m' ],
                \ '--numbers'           : [ '', '' ]
                \ }
endif

command! -nargs=* -complete=file Ags    call ags#search(<q-args>, '')
command! -nargs=* -complete=file AgsAdd call ags#search(<q-args>, 'add')
command! -nargs=0 AgsLast               call ags#search(<q-args>, 'last')
command! -nargs=0 AgsEditSearchResults  call ags#edit#show()
command! -nargs=0 AgsQuit               call ags#quit()
command! -nargs=0 AgsShowLastCommand    call ags#run#getLastCmd()
