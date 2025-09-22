return {
  {
    "dhruvasagar/vim-table-mode",
    init = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
      vim.g.table_mode_always_active = 0
    end,
    keys = {
      { "<leader>tm", "<cmd>TableModeToggle<cr>", desc = "Toggle table mode" },
      { "<leader>tr", "<cmd>TableModeRealign<cr>", desc = "Realign table" },
      { "<leader>tt", "<cmd>'<,'>Tableize<cr>", mode = "v", desc = "Tableize selection" },
    },
  },
}
