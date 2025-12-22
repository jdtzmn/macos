require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Remap NvChad's Alt+h terminal toggle to Alt+t (Alt+h used by WezTerm pane navigation)
vim.keymap.del({ "n", "t" }, "<A-h>")
map({ "n", "t" }, "<A-t>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggleable horizontal term" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
