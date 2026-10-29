return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite" },
  keys = {
    {
      "<leader>gb",
      -- -w : ignore les changements d'espaces (réindentation, etc.)
      -- -M : suit les lignes déplacées à l'intérieur du fichier
      "<CMD>Git blame -w -M<CR>",
      desc = "Git blame du fichier",
    },
    { "<leader>gs", "<CMD>Git<CR>", desc = "Git status" },
  },
}
