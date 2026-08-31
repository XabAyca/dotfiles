return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({
      "ivy", -- barre ancrée en bas de l'écran
      winopts = { height = 0.25, preview = { hidden = true } }, -- compact, sans preview
      fzf_opts = { ["--layout"] = "default" }, -- prompt en bas, résultats au-dessus
      keymap = {
        fzf = {
          ["ctrl-j"] = "down",
          ["ctrl-k"] = "up",
        },
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
