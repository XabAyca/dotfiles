return {
  "nvim-treesitter/nvim-treesitter",
  -- main is Neovim 0.12 only; master is the branch that supports 0.11.
  branch = "master",
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter.configs")

    -- configuration de treesitter
    treesitter.setup({
      -- activation de la coloration syntaxique
      highlight = {
        additional_vim_regex_highlighting = false,
        enable = true,
      },
      -- activation de l'indentation améliorée
      indent = { enable = true },

      -- langages installés et configurés
      ensure_installed = {
        "bash",
        "dockerfile",
        "elixir",
        "gitignore",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "ruby",
        "sql",
        "typescript",
        "vim",
        "yaml",
      },
      -- lorse de l'appui sur <Ctrl-space> sélectionne le bloc
      -- courant spécifique au langage de programmation
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-y>",
          node_incremental = "<C-y>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
