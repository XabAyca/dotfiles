return{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-buffer",  -- Source pour la complétion basée sur les buffers
    "hrsh7th/cmp-path",     -- Source pour la complétion des chemins de fichiers
  },
  config = function()
    -- Importer nvim-cmp
    local cmp = require"cmp"

    cmp.setup({
      sources = {
        { name = "buffer" },  -- Complétion basée sur le contenu des buffers ouverts
        { name = "path" },     -- Complétion pour les chemins de fichiers
      },

      -- Configuration des touches pour naviguer dans les suggestions
      mapping = {
        ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
        ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirmer la complétion avec Entrée
      },

      -- Désactiver la complétion automatique
      completion = {
        autocomplete = false  -- La complétion ne s'active pas automatiquement
      }
    })
  end
}

