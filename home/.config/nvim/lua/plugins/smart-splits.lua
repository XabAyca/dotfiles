return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  keys = {
    -- Navigation nvim splits <-> tmux panes
    { "<C-h>", function() require("smart-splits").move_cursor_left() end,  mode = { "n", "t" }, desc = "Navigate left (nvim/tmux)" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end,  mode = { "n", "t" }, desc = "Navigate down (nvim/tmux)" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end,    mode = { "n", "t" }, desc = "Navigate up (nvim/tmux)" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, mode = { "n", "t" }, desc = "Navigate right (nvim/tmux)" },
    -- Resize nvim splits <-> tmux panes
    { "<M-h>", function() require("smart-splits").resize_left() end,  mode = { "n", "t" }, desc = "Resize left (nvim/tmux)" },
    { "<M-j>", function() require("smart-splits").resize_down() end,  mode = { "n", "t" }, desc = "Resize down (nvim/tmux)" },
    { "<M-k>", function() require("smart-splits").resize_up() end,    mode = { "n", "t" }, desc = "Resize up (nvim/tmux)" },
    { "<M-l>", function() require("smart-splits").resize_right() end, mode = { "n", "t" }, desc = "Resize right (nvim/tmux)" },
  },
}
