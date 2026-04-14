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

-- Changement de fenêtre avec Ctrl + déplacement uniquement au lieu de Ctrl-w + déplacement
keymap("n", "<C-l>", "<C-w>l", { desc = "Déplace le curseur dans la fenêtre droite" })
keymap("n", "<C-h>", "<C-w>h", { desc = "Déplace le curseur dans la fenêtre de gauche" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Déplace le curseur dans la fenêtre du bas" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Déplace le curseur dans la fenêtre du haut" })

-- Redimensionnement des fenêtres avec Leader + hjkl (préfixer avec un nombre pour multiplier)
keymap("n", "<leader>k", ":resize +2<CR>", { desc = "Agrandir la fenêtre verticalement" })
keymap("n", "<leader>j", ":resize -2<CR>", { desc = "Réduire la fenêtre verticalement" })
keymap("n", "<leader>l", ":vertical resize +2<CR>", { desc = "Agrandir la fenêtre horizontalement" })
keymap("n", "<leader>h", ":vertical resize -2<CR>", { desc = "Réduire la fenêtre horizontalement" })

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

