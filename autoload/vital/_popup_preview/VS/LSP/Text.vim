" ___vital___
" NOTE: lines between '" ___vital___' is generated by :Vitalize.
" Do not modify the code nor insert new lines before '" ___vital___'
function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction
execute join(['function! vital#_popup_preview#VS#LSP#Text#import() abort', printf("return map({'normalize_eol': '', 'split_by_eol': ''}, \"vital#_popup_preview#function('<SNR>%s_' . v:key)\")", s:_SID()), 'endfunction'], "\n")
delfunction s:_SID
" ___vital___
"
" normalize_eol
"
function! s:normalize_eol(text) abort
  return substitute(a:text, "\r\n\\|\r", "\n", 'g')
endfunction

"
" split_by_eol
"
function! s:split_by_eol(text) abort
  return split(a:text, "\r\n\\|\r\\|\n", v:true)
endfunction
