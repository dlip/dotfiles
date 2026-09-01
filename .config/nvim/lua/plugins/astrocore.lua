-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

local function yank_path(modifier, with_line)
  return function()
    local path = vim.fn.expand("%" .. modifier)
    if path == "" then
      vim.notify("Buffer has no file name", vim.log.levels.WARN)
      return
    end
    if with_line then path = path .. ":" .. vim.fn.line "." end
    vim.fn.setreg("+", path)
    vim.notify("Yanked " .. path)
  end
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
      },
    },
    mappings = {
      n = {
        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- write all buffers, falling back to the builtin <CR> in special buffers
        ["<CR>"] = {
          function()
            if vim.bo.buftype ~= "" or not vim.bo.modifiable then
              vim.api.nvim_feedkeys(vim.keycode "<CR>", "n", false)
            else
              vim.cmd "silent! wall"
            end
          end,
          desc = "Write all buffers",
        },

        ["<Leader>a"] = { function() require("snacks").picker.smart() end, desc = "Find files (smart)" },
        ["<Leader>gr"] = { function() require("snacks").picker.git_grep() end, desc = "Git grep" },

        ["<Leader>y"] = { desc = "Yank path" },
        ["<Leader>yf"] = { yank_path(":.", false), desc = "Relative filename" },
        ["<Leader>yF"] = { yank_path(":.", true), desc = "Relative filename with line" },
        ["<Leader>yp"] = { yank_path(":p", false), desc = "Full path" },
        ["<Leader>yP"] = { yank_path(":p", true), desc = "Full path with line" },

        -- alternate buffer, quiet when there is no alternate file
        ["<Tab>"] = {
          function()
            if vim.fn.bufnr "#" ~= -1 then vim.cmd.buffer "#" end
          end,
          desc = "Alternate buffer",
        },
      },
    },
  },
}
