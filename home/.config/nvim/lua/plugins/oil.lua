-- ~/.config/nvim/lua/plugins/oil.lua
-- Config oil.nvim pour lazy.nvim : plein buffer, colonnes détaillées

local detailed = true
local detail_columns = {
  "icon",
  "permissions",
  "size",
}

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Chargé au démarrage pour que `nvim .` ouvre Oil à la place de netrw
  lazy = false,
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Oil : dossier du fichier courant" },
    { "<leader>e", "<CMD>Oil<CR>", desc = "Oil : explorateur" },
  },
  opts = {
    -- Remplace netrw (:Ex, `nvim .`, `:e dossier/`)
    default_file_explorer = true,

    columns = detail_columns,

    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },

    win_options = {
      wrap = false,
      signcolumn = "no",
      cursorcolumn = false,
      foldcolumn = "0",
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = "nvic",
    },

    -- Les suppressions vont dans la corbeille au lieu d'être définitives
    delete_to_trash = true,
    -- Pas de confirmation pour les opérations simples (créer, renommer un fichier)
    skip_confirm_for_simple_edits = true,
    -- Propose d'enregistrer si on ouvre une nouvelle entrée pas encore créée
    prompt_save_on_select_new_entry = true,
    -- Rafraîchit automatiquement quand des fichiers changent sur le disque
    watch_for_changes = true,
    -- Garde le curseur sur le nom du fichier, pas sur les colonnes
    constrain_cursor = "name",

    view_options = {
      show_hidden = true,
      -- Affiche tous les fichiers et dossiers en . (y compris .git)
      -- Seul ".." reste masqué (on remonte avec -)
      is_hidden_file = function(name, _)
        return vim.startswith(name, ".")
      end,
      is_always_hidden = function(name, _)
        return name == ".."
      end,
      natural_order = true,
      sort = {
        { "type", "asc" }, -- dossiers d'abord
        { "name", "asc" },
      },
    },

    use_default_keymaps = true,
    keymaps = {
      ["q"] = { "actions.close", mode = "n" },
      ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Ouvrir en split vertical" },
      ["<C-x>"] = { "actions.select", opts = { horizontal = true }, desc = "Ouvrir en split horizontal" },
      -- Libère Ctrl-h / Ctrl-l pour la navigation entre fenêtres
      ["<C-h>"] = false,
      ["<C-l>"] = false,
      ["<C-r>"] = "actions.refresh",
      ["gy"] = { "actions.yank_entry", desc = "Copier le chemin complet" },
      ["gd"] = {
        desc = "Afficher/masquer les détails",
        callback = function()
          detailed = not detailed
          require("oil").set_columns(detailed and detail_columns or { "icon" })
        end,
      },
    },
  },
}
