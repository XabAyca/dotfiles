let g:fern#default_hidden = 1
let g:fern#disable_default_mappings = 1
let g:fern#keepalt_on_edit = 1

let g:fern#mark_symbol                       = "●"
let g:fern#renderer#default#collapsed_symbol = "▷ "
let g:fern#renderer#default#expanded_symbol  = "▼ "
let g:fern#renderer#default#leading          = "  "
let g:fern#renderer#default#leaf_symbol      = ""
let g:fern#renderer#default#root_symbol      = "~ "

function! s:init_fern() abort
  nmap <buffer><expr>
      \ <Plug>(fern-my-open-or-expand-or-collapse)
      \ fern#smart#leaf(
      \   "\<Plug>(fern-action-open)",
      \   "\<Plug>(fern-action-expand)",
      \   "\<Plug>(fern-action-collapse)",
      \ )

  nmap <buffer><expr>
      \ <Plug>(fern-my-expand-or-open)
      \ fern#smart#leaf(
      \   "\<Plug>(fern-action-open)",
      \   "\<Plug>(fern-action-expand)"
      \ )

  nmap <buffer><nowait> <Return> <Plug>(fern-my-open-or-expand-or-collapse)
  nmap <buffer> . <Plug>(fern-action-hidden:toggle)
  nmap <buffer> c <Plug>(fern-action-collapse)
  nmap <buffer> D <Plug>(fern-action-remove)
  nmap <buffer> d <Plug>(fern-action-trash)
  nmap <buffer> m <Plug>(fern-action-move)
  nmap <buffer> n <Plug>(fern-action-new-path)
  nmap <buffer> r <Plug>(fern-my-expand-or-open)
  nmap <buffer> u <Plug>(fern-action-leave)
  nmap <buffer> y <Plug>(fern-action-copy)
endfunction

augroup fern_autocmds
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END
