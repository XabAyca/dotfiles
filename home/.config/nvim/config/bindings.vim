" Mappe <Leader> et <LocalLeader>
let mapleader = ","
let maplocalleader = ";"

" Mouvements de pages
noremap s gk
noremap t gj
" noremap C 20h
noremap <C-t> 10j
noremap <C-s> 10k
" noremap R 20l
noremap ' `
" nnoremap <C-t> <C-W><C-J>
" nnoremap <C-s> <C-W><C-K>
" nnoremap <C-r> <C-W><C-L>
" nnoremap <C-c> <C-W><C-H>

" Always apply 'very magic'
" nnoremap /  /\v
" nnoremap ?  ?\v
" cnoremap %s %s/\v//g<Left><Left><Left>
" cnoremap %g %g/\v//g<Left><Left><Left>

" Make Y behave like D or C
nnoremap Y y$

" Bindings
nmap ’ :Buffers<CR>
nmap - :Fern %:h<CR>
nmap <Space> za
nmap <Leader><Space> :noh<CR>
nmap <Leader><Tab> :b#<CR>
nmap <Leader>a :!echo -n % \| pbcopy<CR><CR>
nmap <Leader>b :setlocal wrap!<CR>:setlocal wrap?<CR>
nmap <Leader>f :Rg<Space>
nmap <Leader>gb :Git blame<CR>
nmap <Leader>h :call GoToTag()<CR>
nmap <Leader>j :Rg <C-R>=expand("<cword>")<CR><CR>
nmap <Leader>k :Fern . -drawer -toggle<CR>
nmap <Leader>l :Fern . -drawer -toggle -reveal=%<CR>
nmap <Leader>n :noh<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>s :setlocal spell!<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>u :MundoToggle<CR>
nmap <Leader>z :setlocal foldenable!<CR>:setlocal foldenable?<CR>

" vim-surround
let g:surround_no_mappings=1
nmap ds  <Plug>Dsurround
nmap ls  <Plug>Csurround
nmap lS  <Plug>CSurround
nmap ys  <Plug>Ysurround
nmap yS  <Plug>YSurround
nmap yss <Plug>Yssurround
nmap ySs <Plug>YSsurround
nmap ySS <Plug>YSsurround
" xmap <Leader>s    <Plug>Vsurround
xmap S   <Plug>VSurround
xmap gS  <Plug>VgSurround

" Add «» surroundings
let g:surround_171 = "« \r »"
let g:surround_187 = "« \r »"

" Fix my common mistakes
command! Q q
command! W w
command! Wq wq
