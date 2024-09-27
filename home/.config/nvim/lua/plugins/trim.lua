-- Fonction pour supprimer les espaces en trop avant la sauvegarde et lors de l'ouverture des fichiers
local function trim_trailing_whitespace()
  if not vim.bo.binary then
    vim.cmd([[%s/\s\+$//e]])
  end
end

vim.api.nvim_create_autocmd({"BufRead", "BufWritePre"}, {
  pattern = "*",  -- Applique à tous les fichiers
  callback = trim_trailing_whitespace
})

return {}
