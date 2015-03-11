" Types of patters
"   - file path
"   - line number
"   - column number
"   - search result

let s:end         = '[0m[K'
let s:col         = ':\d\{-1,}:'
let s:endCol      = s:end . s:col
let s:fileStart   = '[1;31m'
let s:lineStart   = '[1;30m'
let s:lineEnd     = s:end . '-'
let s:resultStart = '[32;40m'
let s:onDelim     = '[#m'


"let s:patColNo       = ':\d\{-1,}:'
"let s:patStFile      = '[1;31m'
"let s:patStFileEsc   = '\[1;31m'
"let s:patStLineNo    = '[1;30m'
"let s:patStLineNoEsc = '\[1;30m'
"let s:patEnLineNo    = s:patEn . '-'
"let s:patEnLineNoEsc = s:patEnEsc . '-'
"let s:patEnColNo     = s:patEn . s:patColNo
"let s:patStRes       = '[32;40m'
"let s:patStResEsc    = '\[32;40m'
"let s:patOnDelim     = '[#m'
"let s:patOnDelimEsc  = '\[#m'
"let s:patFile        = '^' . s:patStFile . '.\{-1,}' . s:patEn

" [1;30m 13[0m[K:8: "let s:[32;40m[#mpat[#m[0m[KStFileEsc   = '\[1;31m'

function! s:esc(pat)
  return substitute(a:pat, '\[', '\\[', 'g')
endfunction

"let ags#pat#dict = {
      "\ 'end'    : s:end,
      "\ 'endEsc' : s:esc(s:end),
      "\ 'col'    : s:col
      "\}

function! ags#pat#mkpat(...)
  let pat = ''
  for p in a:000
    let s = has_key(s:, p) ? s:[p] : p
    let pat .= s
  endfor
  return pat
endfunction
