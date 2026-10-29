return {
  "dense-analysis/ale",
  config = function()
    local g = vim.g

    -- Linters : uniquement ceux listés plus bas, pas de formatage auto
    g.ale_linters_explicit = 1
    g.ale_fix_on_save = 0

    -- Quand linter : en sortant du mode insertion et en mode normal,
    -- pas à chaque frappe (moins de bruit pendant qu'on écrit)
    g.ale_lint_on_text_changed = "normal"
    g.ale_lint_on_insert_leave = 1
    g.ale_lint_delay = 300

    -- Affichage
    g.ale_virtualtext_cursor = "disabled"
    g.ale_sign_column_always = 1 -- Garde la colonne des signes toujours visible
    g.ale_set_highlights = 1
    g.ale_set_signs = 1
    g.ale_use_neovim_diagnostics_api = 0

    -- Message en bas de l'écran : indique quel outil signale le problème
    g.ale_echo_msg_format = "[%linter%] %severity%: %s"
    g.ale_echo_msg_error_str = "Erreur"
    g.ale_echo_msg_warning_str = "Avertissement"
    g.ale_echo_msg_info_str = "Info"

    -- Icônes pour les erreurs, avertissements, etc.
    g.ale_sign_error = "◉"
    g.ale_sign_warning = "◉"
    g.ale_sign_info = "◉"

    g.ale_linters = {
      ruby = { "rubocop", "ruby", "standardrb" },
      lua = { "lua_language_server" },
      elixir = { "credo" },
      eruby = { "erblint" },
      haml = { "haml-lint" },
      javascript = { "standard" },
      python = { "pytype" },
      rust = { "cargo" },
    }

    -- Couleurs des signes ALE, réappliquées à chaque changement de thème
    local function set_ale_colors()
      vim.api.nvim_set_hl(0, "ALEErrorSign", { fg = "#cc241d" })
      vim.api.nvim_set_hl(0, "ALEWarningSign", { fg = "#d65d0e" })
      vim.api.nvim_set_hl(0, "ALEInfoSign", { fg = "#458588" })
    end

    set_ale_colors()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_ale_colors })
  end,
}
