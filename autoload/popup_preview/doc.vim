let s:FloatingWindow = vital#popup_preview#import('VS.Vim.Window.FloatingWindow')
let s:Window = vital#popup_preview#import('VS.Vim.Window')

let s:win = s:FloatingWindow.new()
call s:win.set_var('&wrap', 1)
call s:win.set_var('&conceallevel', 2)
call s:win.set_var('&breakindent', 1)
call s:win.set_var('&linebreak', 1)
call s:win.set_var("&foldenable", 0)

function! s:ensure_buffer() abort
  if bufexists(s:win.get_bufnr())
    return
  endif

  " Create new buffer
  let bufname = 'denops-popup-preview:'
  let bufnr = bufadd(bufname)
  call setbufvar(bufnr, '&buftype', 'nofile')
  call setbufvar(bufnr, '&buflisted', 0)
  call setbufvar(bufnr, '&swapfile', 0)

  call bufload(bufnr)
  noautocmd keepalt keepjumps call s:win.set_bufnr(bufnr)
endfunction

function! popup_preview#doc#close_floating(...) abort
  try
    call s:win.close()
  catch /E523:\|E5555:/
    " Ignore "Not allowed here"
    return -1
  endtry
  if !has('nvim')
    redraw
  endif
endfunction

function! popup_preview#doc#get_winid() abort
  return s:win.get_winid()
endfunction

function! popup_preview#doc#set_buffer(opts) abort
  call s:ensure_buffer()
  let bufnr = s:win.get_bufnr()
  call setbufline(bufnr, 1, a:opts.lines)
  call setbufvar(bufnr, '&modified', 0)
  call setbufvar(bufnr, '&bufhidden', 'hide')
  return bufnr
endfunction

" floatOpt: FloatOption
" width: number
" cmds: string[]
" height: number
function! popup_preview#doc#show_floating(opts) abort
  if getcmdwintype() !=# '' || !popup_preview#pum#visible()
    call s:win.close()
    return -1
  endif
  let opts = a:opts
  let win_opts = opts.floatOpt
  let win_opts.width = opts.width
  let win_opts.height = opts.height

  try
    call popup_preview#doc#set_buffer(opts)

    noautocmd keepalt keepjumps call s:win.open(win_opts)
    if has_key(opts, 'cmds') && len(opts.cmds)
      call s:Window.do(s:win.get_winid(), { -> execute(join(opts.cmds, "\n"), 'silent') })
    endif

    if has('nvim')
      call s:win.set_var('&winhighlight', 'NormalFloat:PopupPreviewDocument,FloatBorder:PopupPreviewBorder')
      if opts.winblend
        call s:win.set_var('&winblend', opts.winblend)
      endif
    endif
    if !has('nvim')
      redraw
    endif
  catch /E523:/
    " Ignore "Not allowed here"
    return -1
  endtry
  return s:win.get_winid()
endfunction

function! popup_preview#doc#scroll(count) abort
  let ctx = {}
  function! ctx.callback(count) abort
    let info = s:win.info()
    if info is v:null
      return
    endif
    call s:Window.scroll(s:win.get_winid(), info.topline+a:count)
  endfunction
  call timer_start(0, { -> l:ctx.callback(a:count) })
  return "\<Ignore>"
endfunction
