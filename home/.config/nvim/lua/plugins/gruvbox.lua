return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  opts = {},

  config = function()
    -- chargement du thème
    vim.cmd([[colorscheme gruvbox]])
  end,
}

