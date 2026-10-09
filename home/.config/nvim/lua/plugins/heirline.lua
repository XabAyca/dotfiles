return {
  "rebelot/heirline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local conditions = require("heirline.conditions")
    local devicons = require("nvim-web-devicons")
    local lazy_status = require("lazy.status")

    -- palette reprise de ~/.config/tmux/catppuccin_gruvbox.tmuxtheme
    local colors = {
      bg = "#282828", fg = "#ebdbb2", gray = "#3c3836", black = "#1d2021", dim = "#665c54",
      red = "#fb4934", green = "#b8bb26", yellow = "#fabd2f", blue = "#83a598",
      pink = "#d3869b", cyan = "#8ec07c", orange = "#fe8019",
    }

    -- même dessin que les modules tmux : bout arrondi, icône sur fond coloré, texte sur fond gris
    local function pill(color, icon, body)
      local fill = type(color) == "function" and color or function() return color end
      return {
        { provider = "\u{e0b6}", hl = function(self) return { fg = fill(self) } end },
        { provider = icon, hl = function(self) return { fg = "black", bg = fill(self) } end },
        { hl = { fg = "fg", bg = "gray" }, { provider = " " }, body, { provider = " " } },
        { provider = "\u{e0b4} ", hl = { fg = "gray" } },
      }
    end

    local Mode = pill(function(self) return self.colors[self.mode] or "green" end, "\u{e62b} ", {
      provider = function(self) return self.letters[self.mode] or self.mode end,
      hl = { bold = true },
    })
    Mode.init = function(self) self.mode = vim.fn.mode(1):sub(1, 1) end
    Mode.static = {
      letters = { n = "N", i = "I", v = "V", V = "VL", ["\22"] = "VB", s = "S", S = "SL", ["\19"] = "SB", R = "R", c = "C", r = "P", ["!"] = "!", t = "T" },
      colors = { i = "blue", v = "orange", V = "orange", ["\22"] = "orange", s = "pink", S = "pink", ["\19"] = "pink", R = "red", c = "yellow", t = "cyan" },
    }
    Mode.update = { "ModeChanged", pattern = "*:*", callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end) }

    local function count(key, sign, color)
      return {
        provider = function(self) return (self.status[key] or 0) > 0 and (sign .. self.status[key]) end,
        hl = { fg = color },
      }
    end

    local Git = pill("orange", "\u{e0a0} ", {
      { provider = function(self) return self.status.head end, hl = { bold = true } },
      count("added", " +", "green"),
      count("changed", " ~", "yellow"),
      count("removed", " -", "red"),
    })
    Git.condition = conditions.is_git_repo
    Git.init = function(self) self.status = vim.b.gitsigns_status_dict end

    -- ALE n'alimente pas vim.diagnostic (ale_use_neovim_diagnostics_api = 0), on lit ses compteurs
    local Diagnostics = pill(function(self) return self.status.error > 0 and "red" or "orange" end, "\u{f188} ", {
      count("error", "◉ ", "red"),
      count("warning", " ◉ ", "orange"),
      count("info", " ◉ ", "blue"),
    })
    Diagnostics.condition = function(self)
      local ok, c = pcall(vim.fn["ale#statusline#Count"], vim.api.nvim_get_current_buf())
      if not ok then return false end
      self.status = { error = c.error + c.style_error, warning = c.warning + c.style_warning, info = c.info }
      return self.status.error + self.status.warning + self.status.info > 0
    end

    local File = pill("pink", "\u{f07b} ", {
      { provider = function() local name = vim.fn.expand("%:.") return name == "" and "[No Name]" or name end },
      { condition = function() return vim.bo.modified end, provider = " ●", hl = { fg = "orange" } },
      { condition = function() return vim.bo.readonly or not vim.bo.modifiable end, provider = " \u{f023}", hl = { fg = "red" } },
    })

    local LazyUpdates = {
      condition = lazy_status.has_updates,
      provider = function() return lazy_status.updates() .. " " end,
      hl = { fg = "orange" },
    }

    local Recording = pill("red", "\u{f044a} ", {
      provider = function() return "@" .. vim.fn.reg_recording() end,
      hl = { bold = true },
    })
    Recording.condition = function() return vim.fn.reg_recording() ~= "" end
    -- planifié : pendant RecordingLeave, reg_recording() renvoie encore le registre
    Recording.update = { "RecordingEnter", "RecordingLeave", callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end) }

    local SearchCount = {
      condition = function(self)
        if vim.v.hlsearch == 0 then return false end
        local ok, search = pcall(vim.fn.searchcount, { recompute = 1 })
        self.search = search
        return ok and (search.total or 0) > 0
      end,
      provider = function(self)
        return string.format("\u{f002} %d/%s%d ", self.search.current, self.search.incomplete == 2 and ">" or "", self.search.total)
      end,
      hl = { fg = "yellow" },
    }

    local ShowCmd = { provider = "%S ", hl = { fg = "yellow", bold = true } }

    local FileInfo = pill("yellow", "\u{f121} ", {
      init = function(self)
        self.icon, self.icon_color = devicons.get_icon_color(vim.fn.expand("%:t"), vim.fn.expand("%:e"), { default = true })
      end,
      { provider = function(self) return self.icon end, hl = function(self) return { fg = self.icon_color } end },
      { provider = function() return " " .. vim.bo.filetype end },
      { provider = function() return "  " .. (vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc) end, hl = { fg = "dim" } },
      { provider = function() return "  " .. ({ unix = "\u{f17c}", dos = "\u{f17a}", mac = "\u{f179}" })[vim.bo.fileformat] end, hl = { fg = "dim" } },
    })

    local Position = pill("blue", "\u{f01a4} ", { provider = "%4l:%-3c %3P" })

    local Inactive = {
      condition = conditions.is_not_active,
      hl = { fg = "dim" },
      { provider = " %f" }, { provider = "%=" }, { provider = "%l:%c " },
    }

    local Active = {
      { provider = " " }, Mode, Git, Diagnostics, File,
      { provider = "%=" },
      ShowCmd, SearchCount, Recording, LazyUpdates, FileInfo, Position,
    }

    require("heirline").setup({
      statusline = { hl = { fg = "fg", bg = "bg" }, fallthrough = false, Inactive, Active },
      opts = { colors = colors },
    })
  end,
}
