let g:mundo_width = 80
let g:mundo_preview_height = 25
" let g:mundo_preview_bottom = 1
" let g:mundo_verbose_graph = 0
let g:mundo_mappings = {
  \ '<CR>': 'preview',
  \ 'o': 'preview',
  \ 't': 'move_older',
  \ 's': 'move_newer',
  \ '<down>': 'move_older',
  \ '<up>': 'move_newer',
  \ 'T': 'move_older_write',
  \ 'S': 'move_newer_write',
  \ 'gg': 'move_top',
  \ 'G': 'move_bottom',
  \ 'P': 'play_to',
  \ 'i': 'toggle_inline',
  \ '/': 'search',
  \ 'n': 'next_match',
  \ 'N': 'previous_match',
  \ 'p': 'diff_current_buffer',
  \ 'd': 'diff',
  \ '?': 'toggle_help',
  \ 'q': 'quit',
  \ '<2-LeftMouse>': 'mouse_click' }
