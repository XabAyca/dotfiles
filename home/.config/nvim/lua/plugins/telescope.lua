return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "BurntSushi/ripgrep",
    -- fzf implémentation en C pour plus de rapidité
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope-file-browser.nvim",
    "aaronhallaert/advanced-git-search.nvim",
    "famiu/bufdelete.nvim",
  },
  config = function()
    local telescopeConfig = require("telescope.config")
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
    -- Chercher dans les fichiers cachés mais respecter .gitignore
    table.insert(vimgrep_arguments, "--hidden")
    table.insert(vimgrep_arguments, "--glob")
    table.insert(vimgrep_arguments, "!.git/*")

    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    require("telescope").load_extension("advanced_git_search")

    -- Ferme les buffers sélectionnés via bufdelete pour préserver les splits
    local delete_buffer = function(prompt_bufnr)
      local current_picker = action_state.get_current_picker(prompt_bufnr)
      current_picker:delete_selection(function(selection)
        require("bufdelete").bufdelete(selection.bufnr, true)
      end)
    end

    telescope.setup({
      defaults = {
        vimgrep_arguments = vimgrep_arguments,
        file_ignore_patterns = { ".git/" },

        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
      pickers = {
        find_files = {
          -- fd est plus rapide que le finder par défaut
          find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
        },
        live_grep = {
          -- Limite les résultats pour plus de réactivité
          additional_args = { "--max-count=50" },
        },
        buffers = {
          mappings = {
            i = { ["<C-d>"] = delete_buffer },
            n = { ["<C-d>"] = delete_buffer, ["dd"] = delete_buffer },
          },
        },
      },
      extensions = {
        file_browser = {
          grouped = true,
          hidden = { file_browser = true, folder_browser = true },
          display_stat = false,
          respect_gitignore = true,
        },
      },
    })

    telescope.load_extension("fzf")

    local keymap = vim.keymap -- for conciseness

    keymap.set(
      "n",
      "<leader>ff",
      "<cmd>Telescope find_files hidden=true no_ignore=true<cr>",
      { desc = "Recherche de chaînes de caractères dans les noms de fichiers" }
    )
    keymap.set(
      "n",
      "<leader>fg",
      "<cmd>Telescope live_grep<cr>",
      { desc = "Recherche de chaînes de caractères dans le contenu des fichiers" }
    )
    keymap.set(
      "n",
      "<leader>fb",
      "<cmd>Telescope buffers<cr>",
      { desc = "Recherche de chaînes de caractères dans les noms de buffers" }
    )
    keymap.set(
      "n",
      "<leader>fx",
      "<cmd>Telescope grep_string<cr>",
      { desc = "Recherche de la chaîne de caractères sous le curseur" }
    )
    keymap.set(
      "n",
      "<leader>fw",
      "<cmd>Telescope file_browser display_stat=false grouped=true no_ignore=true hidden=true path=%:p:h select_buffer=true<cr>",
      { desc = "Recherche de fichier" }
    )
    keymap.set(
      "n",
      "<leader>fi",
      "<cmd>AdvancedGitSearch<cr>",
      { desc = "Recherche Git" }
    )
  end,
}

