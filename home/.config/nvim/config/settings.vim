" > Essentials
" ------------------------------------------------------------------------------
set nocompatible
filetype plugin indent on
syntax on

" > Miscelaneous
" ------------------------------------------------------------------------------
set backspace=indent,eol,start " Apply standard <BS>
set clipboard=unnamed          " Use OSX clipboard
set encoding=utf-8             " UTF-8 by default
set ttimeoutlen=0              " Avoid delay on escape
" set formatoptions-=ro        " Ne pas auto-commenter au passage de ligne
set hidden                     " Enable modified buffers to be hidden
set nowrap                     " Don't wrap long lines
set linebreak                  " Casse les longues lignes par mot, pas par caractère
set list                       " Show whitespace as special chars - see listchars
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:· " Unicode characters for various things
set mouse=a                    " Enable mouse for all modes
set showmatch                  " Highlight corresponding bracket
set noshowmode                 " Hide current mode at the bottom of the window
set lazyredraw                 " Améliore les performences de Vim
set shortmess=tI               " Pas de message d'ouverture de Vim
set laststatus=2               " Always show the status bar
set scrolloff=5                " Keep cursor away from this many chars top/bot
set sidescrolloff=10           " Keep cursor away from this many chars left/right
set updatetime=100             " 4000ms par défaut

" > Cursor and lines numbering
" ------------------------------------------------------------------------------
set number
set norelativenumber
set splitbelow
set splitright

" > Indentation
" ------------------------------------------------------------------------------
set autoindent                 " Indentation automatique
set expandtab                  " Indente avec des espaces
set shiftround                 " Indentation intelligente
set tabstop=2                  " Largeur d'une <Tab>
set shiftwidth=2               " Définit le nombre d'espaces à compter lors d'un <Tab> ou <BS>
set softtabstop=2              " Largeur d'une indentation en mode 'normal'

" > Recherche
" ------------------------------------------------------------------------------
set hlsearch                   " met la recherche en surbrillance
set ignorecase                 " ignore la casse lors de la recherche
set incsearch                  " cherche au fur et à mesure de la frappe
set smartcase                  " casse intelligente lors de la recherche
set inccommand=nosplit         " ajoute la preview sur :substitute

" > Alertes
" ------------------------------------------------------------------------------
set noerrorbells               " Pas d'alerte en cas d'erreur
set visualbell t_vb=           " Pas de flash ni de bip du tout

" > Backups et Swaps
" ------------------------------------------------------------------------------
set backup                     " Active le backup des fichiers sauvegardés
set writebackup                " Active le backup pendant la sauvegarde
set noswapfile                 " Désactive les fichiers swap
set undofile                   " Active les fichers undo
set backupdir=~/.cache/vim/backups " Dossier pour les backups
"set directory=~/.cache/vim/swaps " Dossier pour les fichiers swap
set undodir=~/.cache/vim/undos " Dossier pour les undos
set tags^=.tags;               " Set tags file

" > Folding
" ------------------------------------------------------------------------------
set nofoldenable               " Folding désactivé par défaut
set foldmethod=marker          " Folding selon l'indentation
set foldlevelstart=99          " Démarrer sans indentation

" > Completion
" ------------------------------------------------------------------------------
set completeopt=longest,menuone,preview " Paramètres de la complétion
set complete+=kspell           " Ajoute le dictionnaire à la complétion lorsque spell est activé
set wildmenu                   " Enable command-line completion enhanced mode
set wildmode=full              " Command-line completion settings

" > Disable some language providers
" ------------------------------------------------------------------------------
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0
