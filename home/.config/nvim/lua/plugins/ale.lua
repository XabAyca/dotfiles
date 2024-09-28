return {
  "dense-analysis/ale",
  config = function()
    local g = vim.g
    g.ale_linters_explicit = 1
    g.ale_virtualtext_cursor = "disabled"
    g.ale_sign_column_always = 1 -- Garde la colonne des signes toujours visible
    g.ale_set_highlights = 0

    -- Configuration des icônes pour les erreurs, avertissements, etc.
    g.ale_sign_error = "✗"          -- Icône pour les erreurs
    g.ale_sign_warning = "⚠"         -- Icône pour les avertissements
    g.ale_sign_info = "ℹ"            -- Icône pour les infos
    g.ale_sign_hint = "➤"            -- Icône pour les indices

    g.ale_linters = {
      ruby = {"rubocop", "ruby"},
      lua = {"lua_language_server"},
      elixir = {"credo"},
      eruby = {"erblint"},
      haml = {"hamlint"},
      javascript = {"standard"},
      haml = {"haml-lint"},
      python = {"pytype"}
    }
  end
}

