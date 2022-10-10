colorscheme base16
hi Visual cterm=reverse
call Base16hi("SpellBad", g:base16_gui00, g:base16_gui08, g:base16_cterm00, g:base16_cterm08, "", "")
call Base16hi("VimwikiHeader1", g:base16_gui08, "", g:base16_cterm08, "", "", "")
call Base16hi("VimwikiHeader2", g:base16_gui09, "", g:base16_cterm09, "", "", "")
call Base16hi("VimwikiHeader3", g:base16_gui0A, "", g:base16_cterm0A, "", "", "")
call Base16hi("VimwikiHeader4", g:base16_gui0B, "", g:base16_cterm0B, "", "", "")
call Base16hi("VimwikiHeader5", g:base16_gui0C, "", g:base16_cterm0C, "", "", "")
call Base16hi("VimwikiHeader6", g:base16_gui0D, "", g:base16_cterm0D, "", "", "")
call Base16hi("htmlH1", g:base16_gui08, "", g:base16_cterm08, "", "", "")
call Base16hi("htmlH2", g:base16_gui09, "", g:base16_cterm09, "", "", "")
call Base16hi("htmlH3", g:base16_gui0A, "", g:base16_cterm0A, "", "", "")
call Base16hi("htmlH4", g:base16_gui0B, "", g:base16_cterm0B, "", "", "")
call Base16hi("htmlH5", g:base16_gui0C, "", g:base16_cterm0C, "", "", "")
call Base16hi("htmlH6", g:base16_gui0D, "", g:base16_cterm0D, "", "", "")

let g:lightline = { 'colorscheme': 'base16' }

" Gruvbox
" set background=dark
set termguicolors
" " let g:gruvbox_contrast_dark='hard'
" " let g:gruvbox_sign_column='bg0'
" let g:gruvbox_number_column='bg1'
" " let g:gruvbox_italic=1
" let g:gruvbox_invert_selection=0
" colorscheme gruvbox

" Make trailing spaces very visible
highlight ExtraWhitespace ctermfg=235 ctermbg=172 guifg=#282828 guibg=#d79921
let extraWhiteSpaceBlacklist = ['Mundo']
match ExtraWhiteSpace /\s\+$/
autocmd BufWinEnter * if index(extraWhiteSpaceBlacklist, &ft) < 0 | match ExtraWhiteSpace /\s\+$/
autocmd InsertEnter * if index(extraWhiteSpaceBlacklist, &ft) < 0 | match ExtraWhiteSpace /\s\+\%#\@<!$/
autocmd InsertLeave * if index(extraWhiteSpaceBlacklist, &ft) < 0 | match ExtraWhiteSpace /\s\+$/
autocmd BufWinLeave * call clearmatches()
