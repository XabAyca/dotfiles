let g:vimwiki_list = [{
  \   'path': '~/Dropbox/wiki',
  \   'syntax': 'markdown',
  \   'ext': 'md',
  \   'nested_syntaxes': {'ruby': 'ruby', 'shell': 'bash'},
  \ }]

let g:vimwiki_global_ext = 0

nmap <Leader>w<Space> <Plug>VimwikiToggleListItem
vmap <Leader>w<Space> <Plug>VimwikiToggleListItem
