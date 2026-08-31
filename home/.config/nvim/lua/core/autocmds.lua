-- Supprime les espaces en fin de ligne avant la sauvegarde
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if not vim.bo.binary then
      vim.cmd([[%s/\s\+$//e]])
    end
  end,
})
