call plug#begin('~/.local/share/nvim/plugged')

" > Interface
" ------------------------------------------------------------------------------
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }

" > General enhancements
" ------------------------------------------------------------------------------
Plug 'godlygeek/tabular'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'qpkorr/vim-bufkill'
" Plug 'ryanoasis/vim-devicons'
Plug 'lambdalisue/fern.vim'
Plug 'simnalamburt/vim-mundo'
Plug 'sirver/UltiSnips'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'vimwiki/vimwiki'
Plug 'w0rp/ale'

" > Syntax
" ------------------------------------------------------------------------------
Plug 'lmeijvogel/vim-yaml-helper', { 'for': 'yaml' }
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-rails'
Plug 'xuhdev/vim-latex-live-preview', { 'for': ['tex', 'plaintex'] }
Plug 'chrisbra/Colorizer'

call plug#end()
