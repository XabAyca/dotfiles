local opt = vim.opt -- raccourci pour un peu plus de concision

-- numéros de ligne
opt.relativenumber = true -- affichage des numéros de ligne relatives à la position actuelle du curseur
opt.number = true -- affiche le numéro absolu de la ligne active lorsque que relativenumber est activé

-- tabs & indentation
opt.tabstop = 2 -- 2 espaces pour les tabulations
opt.shiftwidth = 2 -- 2 espaces pour la taille des indentations
opt.expandtab = true -- change les tabulations en espaces (don't feed the troll please ;) )
opt.autoindent = true -- on garde l'indentation actuelle à la prochaine ligne

-- recherche
opt.ignorecase = true -- ignore la casse quand on recherche
opt.smartcase = true -- sauf quand on fait une recherche avec des majuscules, on rebascule en sensible à la casse
opt.hlsearch = true -- surlignage de toutes les occurences de la recherche en cours

-- ligne du curseur
opt.cursorline = true -- surlignage de la ligne active

-- apparence

-- termguicolors est nécessaire pour que les thèmes modernes fonctionnent
opt.termguicolors = true
opt.background = "dark" -- dark ou light en fonction de votre préférence
opt.signcolumn = "yes" -- affiche une colonne en plus à gauche pour afficher les signes (évite de décaler le texte)

-- retour
opt.backspace = "indent,eol,start" -- on autorise l'utilisation de retour quand on indente, à la fin de ligne ou au début

-- presse papier
opt.clipboard = "unnamedplus" -- on utilise le presse papier du système par défaut

-- split des fenêtres
opt.splitright = true -- le split vertical d'une fenêtre s'affiche à droite
opt.splitbelow = true -- le split horizontal d'une fenêtre s'affiche en bas

opt.swapfile = false -- on supprime le pénible fichier de swap

opt.undofile = true -- on autorise l'undo à l'infini (même quand on revient sur un fichier qu'on avait fermé)

opt.iskeyword:append("-") -- on traite les mots avec des - comme un seul mot

-- affichage des caractères spéciaux
opt.list = true
opt.listchars:append({ space = "•", nbsp = "␣", trail = "•", precedes = "«", extends = "»", tab = "> " })

-- change la police
opt.guifont = "MesloLGS NF Regular"

-- Ajouter une dernière ligne à la fin des fichiers
opt.eol = true -- Ajouter une nouvelle ligne à la fin des fichiers si elle n'existe pas
opt.fixeol = true -- Forcer la présence d'un caractère de fin de ligne sur la dernière ligne

-- Changer la couleur de fond de la colonne des signes
vim.cmd([[highlight SignColumn guibg=NONE]])  -- Rendre la colonne des signes transparente

-- Configurer la colonne des signes pour permettre jusqu'à 3 signes côte à côte
opt.signcolumn = "auto:2"

-- Ajoute un highlight rapide lors du yank
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
