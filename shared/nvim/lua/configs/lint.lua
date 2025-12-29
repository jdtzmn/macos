local lint = require("lint")

-- Configure linters
lint.linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  vue = { "eslint_d" },
  json = { "eslint_d" },
}

-- Auto-lint on these events
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})

-- Auto-fix ESLint issues on save
local fix_augroup = vim.api.nvim_create_augroup("eslint_fix", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = fix_augroup,
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.vue", "*.json" },
  callback = function()
    local result = vim.fn.system("eslint_d --fix " .. vim.fn.expand("%"))
    if vim.v.shell_error ~= 0 then
      vim.notify("ESLint fix failed: " .. result, vim.log.levels.WARN)
    end
    -- Reload buffer to show changes
    vim.cmd("edit!")
  end,
})
