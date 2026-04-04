return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
        markdown = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path:match("/templates/.*%.ya?ml$") then
          return nil
        end
        return {
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        }
      end,
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
