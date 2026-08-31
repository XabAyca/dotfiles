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

-- J/K déplacent la sélection vers le bas/haut en visuel (cohérent avec hjkl)
keymap("x", "J", ":move '>+1<CR>gv=gv", { desc = "Déplace la sélection vers le bas" })
keymap("x", "K", ":move '<-2<CR>gv=gv", { desc = "Déplace la sélection vers le haut" })

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

