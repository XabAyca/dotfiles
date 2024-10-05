return{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-buffer",  -- Source pour la complétion basée sur les buffers
    "hrsh7th/cmp-path",     -- Source pour la complétion des chemins de fichiers
    "hrsh7th/cmp-cmdline"
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
      mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping.complete(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      -- Désactiver la complétion automatique
      completion = {
        autocomplete = false  -- La complétion ne s'active pas automatiquement
      }
    })

    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      }),
      matching = { disallow_symbol_nonprefix_matching = false }
    })
  end
}

