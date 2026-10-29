return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({
      -- Couleurs reprises du thème de Neovim
      fzf_colors = true,
      -- Plein écran, sans bordure ni preview : comme un buffer normal
      winopts = {
        fullscreen = true,
        border = "none",
        preview = { hidden = true },
      },
      -- Prompt en haut, résultats en dessous, compteur discret à droite
      fzf_opts = {
        ["--layout"] = "reverse",
        ["--info"] = "inline-right",
      },
      defaults = {
        header = false, -- pas de ligne d'aide au-dessus des résultats
        formatter = "path.filename_first", -- nom du fichier d'abord, dossier ensuite
      },
      files = {
        fd_opts = "--type f --hidden --exclude .git",
      },
      grep = {
        rg_glob = true, -- globs après ` -- ` (sans -g) : `motif -- app/**`, `motif -- !spec/**`
        rg_opts = "--column --line-number --no-heading --color=always --smart-case "
          .. "--max-columns=4096 --max-count=50 --hidden --glob '!.git/*' -e",
      },
    })

    -- smart-splits capte <C-j>/<C-k> en mode terminal : on les rend à fzf dans sa fenêtre
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fzf",
      callback = function(ev)
        for _, key in ipairs({ "<C-j>", "<C-k>" }) do
          vim.keymap.set("t", key, key, { buffer = ev.buf })
        end
      end,
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>ff", function()
      fzf.files({ no_ignore = true })
    end, { desc = "Recherche de fichiers par nom" })

    keymap.set("n", "<leader>fg", fzf.live_grep, {
      desc = "Recherche dans le contenu (globs rg après ` -- `)",
    })

    keymap.set("n", "<leader>fb", fzf.buffers, {
      desc = "Recherche dans les buffers ouverts",
    })

    keymap.set("n", "<leader>fx", fzf.grep_cword, {
      desc = "Recherche du mot sous le curseur",
    })

    keymap.set("n", "<leader>fi", fzf.git_bcommits, {
      desc = "Historique git du buffer courant",
    })
  end,
}
