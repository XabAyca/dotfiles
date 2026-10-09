local languages = {
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
  "query",
  "regex",
  "ruby",
  "sql",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(languages)

    -- coloration syntaxique et indentation améliorée pour tout langage dont le parser est installé
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        if pcall(vim.treesitter.start) then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- <Ctrl-y> sélectionne le bloc courant puis l'élargit, <bs> le réduit :
    -- simples raccourcis vers la sélection incrémentale native (:h v_an)
    vim.keymap.set("n", "<C-y>", "van", { remap = true })
    vim.keymap.set("x", "<C-y>", "an", { remap = true })
    vim.keymap.set("x", "<bs>", "in", { remap = true })
  end,
}
