"  _       _ _         _
" (_)_ __ (_) |___   _(_)_ __ ___
" | | '_ \| | __\ \ / / | '_ ` _ \
" | | | | | | |_ \ V /| | | | | | |
" |_|_| |_|_|\__(_)_/ |_|_| |_| |_|
"
"
" > Guillaume Boudon
" > https://github.com/guillaumeboudon/dotfiles


source ~/.config/nvim/config/plugins.vim
source ~/.config/nvim/config/settings.vim
source ~/.config/nvim/config/colors.vim
source ~/.config/nvim/config/functions.vim
source ~/.config/nvim/config/bepo.vim
source ~/.config/nvim/config/bindings.vim


" ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
" > Syntax
" ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡

" Ledger
let g:ledger_extra_options = "--pedantic --explicit --check_payees"
let g:ledger_default_commodity = "€"
let g:ledger_commodity_before = 0
let g:ledger_commodity_sep = " "
let g:ledger_date_format = "%Y-%m-%d"
" au BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger
autocmd FileType ledger noremap { ?^\d<CR>

" noremap blah1 :silent make | redraw! | cwindow
" noremap blah2 :call ledger#transaction_date_set(".", "primary")
" noremap blah3 :call ledger#transaction_state_toggle(line("."), " *?!")
" noremap blah4 :LedgerAlign

" let g:ledger_maxwidth = 120
" let g:ledger_fold_blanks = 1

function! LedgerAlignAll()
  let save_pos = getpos(".")
  :%LedgerAlign
  call setpos(".", save_pos)
endfunction
autocmd BufWritePre *.ledger call LedgerAlignAll()

function! LedgerSort()
  let save_pos = getpos(".")
  :%! ledger -f - print --sort 'date, amount' --prepend-width 2
  normal gg=G
  :%LedgerAlign
  call setpos(".", save_pos)
endfunction
command! LedgerSort call LedgerSort()

" CSS
" autocmd BufWritePre,FileWritePre *.css,*.scss :%!csscomb

augroup my_autocommands
" Reset all autocommands
autocmd!

autocmd BufNewFile,BufRead .gemrc    set ft=yaml

autocmd Filetype elm      setlocal tabstop=4 softtabstop=4 shiftwidth=4
autocmd Filetype todo     setlocal tabstop=4 softtabstop=4 shiftwidth=4
autocmd Filetype markdown setlocal tabstop=4 softtabstop=4 shiftwidth=4
autocmd Filetype ruby     setlocal colorcolumn=80,100

" Highlighting selection on yank
autocmd TextYankPost * silent! lua vim.highlight.on_yank()

augroup END

" ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
" > Grrrrrrrr, À classer !
" ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡

let g:tex_flavor = "latex"

function! GoToTag ()
  let l:cword = expand('<cword>')
  let l:matches = system("cat .git/tags | rg -w '^'" . l:cword . "'\t' | wc -l | awk '{print $1}'")
  if l:matches =~ "0"
    exe "Rg" l:cword
  elseif l:matches =~ "1"
    exe "tag" l:cword
  else
    exe "Tags" "'" . l:cword
  endif
endfunction

" Resize panes when window/terminal gets resize
autocmd VimResized * :wincmd =

" autocmd FileType qf setlocal wrap
" autocmd FileType qf wincmd J
" autocmd FileType qf nmap <buffer> q :q<cr>
" autocmd FileType qf setlocal number nolist

autocmd FileType markdown setlocal spelllang=fr,en
function! FzfSpellSink(word)
  exe 'normal! "_ciw'.a:word
endfunction
function! FzfSpell()
  let suggestions = spellsuggest(expand("<cword>"))
  return fzf#run({'source': suggestions, 'sink': function("FzfSpellSink"), 'down': 10 })
endfunction
nnoremap z= :call FzfSpell()<CR>


map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

silent! nohlsearch
