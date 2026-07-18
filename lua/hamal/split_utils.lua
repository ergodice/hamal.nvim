local Split = require("hamal.split")

local M = {}

function M.entire_buf(bufnr)
    bufnr = bufnr or 0

    local last = vim.api.nvim_buf_line_count(bufnr)
    local split, err = Split.new(1, last)
    if split == nil then
        return nil, err
    end

    return split
end

function M.displayed_lines(winid)
    winid = winid or 0

    local top = vim.fn.line("w0", winid)
    local bottom = vim.fn.line("w$", winid)

    local split, err = Split.new(top, bottom)
    if split == nil then
        return nil, err
    end

    return split
end

return M
