-- On définit notre touche leader sur espace
vim.g.mapleader = " "

-- Raccourci pour la fonction set
local keymap = vim.keymap.set

-- on utilise ;; pour sortir du monde insertion
keymap("i", ";;", "<ESC>", { desc = "Sortir du mode insertion avec ;;" })

-- Sortir du mode terminal avec Esc ou ;;
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = "Sortir du mode terminal avec Esc" })
keymap("t", ";;", [[<C-\><C-n>]], { desc = "Sortir du mode terminal avec ;;" })

-- on efface le surlignage de la recherche
keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Effacer le surlignage de la recherche" })

-- I déplace le texte sélectionné vers le haut en mode visuel (activé avec v)
keymap("v", "<C-i>", ":m .-2<CR>==", { desc = "Déplace le texte sélectionné vers le haut en mode visuel" })
-- K déplace le texte sélectionné vers le bas en mode visuel (activé avec v)
keymap("v", "<C-k>", ":m .+1<CR>==", { desc = "Déplace le texte sélectionné vers le bas en mode visuel" })

-- I déplace le texte sélectionné vers le haut en mode visuel bloc (activé avec V)
keymap("x", "<C-i>", ":move '<-2<CR>gv-gv", { desc = "Déplace le texte sélectionné vers le haut en mode visuel bloc" })
-- K déplace le texte sélectionné vers le bas en mode visuel (activé avec V)
keymap("x", "<C-k>", ":move '>+1<CR>gv-gv", { desc = "Déplace le texte sélectionné vers le bas en mode visuel bloc" })

-- Navigation (<C-hjkl>) et resize (<M-hjkl>) entre fenêtres nvim ET panes tmux
-- (gérés par le plugin smart-splits.nvim, voir lua/plugins/smart-splits.lua)

-- Navigation entre les buffers
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Buffer suivant" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Buffer précédent" })

-- Zoom toggle : ouvre le buffer dans un nouvel onglet ou revient en arrière
local function toggle_zoom()
  if vim.t.zoomed then
    vim.cmd("tabclose")
  else
    vim.cmd("tab split")
    vim.t.zoomed = true
  end
end

keymap("n", "<leader>z", toggle_zoom, { desc = "Basculer le zoom de la fenêtre courante" })

