return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "famiu/bufdelete.nvim",
  },
  config = function()
    local fzf = require("fzf-lua")

    -- Ferme le buffer sélectionné dans le picker sans casser les splits
    local delete_buffer = function(selected, opts)
      for _, sel in ipairs(selected) do
        local entry = require("fzf-lua.path").entry_to_file(sel, opts)
        if entry and entry.bufnr then
          require("bufdelete").bufdelete(entry.bufnr, true)
        end
      end
    end

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
      buffers = {
        actions = {
          ["ctrl-d"] = { fn = delete_buffer, reload = true },
        },
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

    keymap.set("n", "<leader>fw", function()
      fzf.files({ cwd = vim.fn.expand("%:p:h"), no_ignore = true })
    end, { desc = "Recherche de fichier dans le dossier du buffer courant" })

    keymap.set("n", "<leader>fi", fzf.git_bcommits, {
      desc = "Historique git du buffer courant",
    })
  end,
}
