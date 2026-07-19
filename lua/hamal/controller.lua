local state = require("hamal.state")
local ns = vim.api.nvim_create_namespace("hamal.searcher")

---@class Controller
---@field searcher Searcher
---@field active boolean
local Controller = {}
Controller.__index = Controller

function Controller.new(searcher)
    local self = setmetatable({
        searcher = searcher,
        active = true,
    }, Controller)
    return self
end

-- split・movement
function Controller:split()
    self:highlight()

    -- takeover inputs (Blocking loop)
    while self.active do
        local ok, char = pcall(vim.fn.getcharstr)

        -- failsafe for <C-c>
        if not ok then
            self:quit()
            break
        end

        if char ~= nil and char ~= "" then
            local keytrans = vim.fn.keytrans(char)
            local keycode = vim.keycode(keytrans)

            if state.opts.keymaps[keycode] then
                state.opts.keymaps[keycode]()
            elseif state.opts.quit_on_unmapped_keys then
                self:quit()
                vim.api.nvim_feedkeys(char, "i", false)
                break
            end
        end
    end
end

function Controller:focus(index)
    local _, err = self.searcher:focus_on(index)
    if err then
        require("hamal.utils").notify_err(err.code)
    end
    self:highlight()

    if self.searcher:is_finished() then
        self:quit()
        self:set_cursor()
    end
end

function Controller:pan_focus()
    local _, err = self.searcher:back()
    if err then
        require("hamal.utils").notify_warn(err.code)
    end
    self:highlight()
end

function Controller:quit()
    self.active = false
    vim.on_key(nil, state.ns)
    self:clear_highlight()
    state.controllers[self.searcher.winid] = nil
end

function Controller:set_cursor()
    self.searcher:set_cursor(2)
end

function Controller:select()
    self.searcher:set_cursor(1)
    vim.cmd("normal! V")
    self.searcher:set_cursor(3)
    self:quit()
end

-- hilights
local function highlight_line(bufnr, line, hl)
    vim.api.nvim_buf_set_extmark(bufnr, ns, line - 1, 0, {
        line_hl_group = hl,
    })
end

local function highlight_range(bufnr, top, bottom, hl)
    vim.api.nvim_buf_set_extmark(bufnr, ns, top - 1, 0, {
        end_row = bottom,
        end_col = 0,
        hl_eol = true,
        line_hl_group = hl,
    })
end

function Controller:highlight()
    vim.api.nvim_buf_clear_namespace(self.searcher.bufnr, ns, 0, -1)

    local children, err = self.searcher.current:split(state.opts.divisions)
    if children == nil then
        return err
    end

    local number_of_highlights = {
        ["section"] = vim.tbl_count(state.opts.highlights.section),
        ["line"] = vim.tbl_count(state.opts.highlights.line),
    }

    local get_hl = function(tbl, div)
        local mod = div % number_of_highlights[tbl]
        if mod == 0 then -- lua table is one-based.
            return state.opts.highlights[tbl][number_of_highlights[tbl]]
        else
            return state.opts.highlights[tbl][mod]
        end
    end

    local index_of_hl_name = 1 -- hl format : { <name>, <spec> }
    for div = 1, state.opts.divisions do
        local section_hl = get_hl("section", div)
        if section_hl then
            highlight_range(
                self.searcher.bufnr,
                children[div]:top(),
                children[div]:bottom(),
                section_hl[index_of_hl_name]
            )
        end
        local line_hl = get_hl("line", div)
        if line_hl then
            if line_hl.top and line_hl.bottom then
                highlight_line(self.searcher.bufnr, children[div]:top(), line_hl.top[index_of_hl_name])
                highlight_line(self.searcher.bufnr, children[div]:bottom(), line_hl.bottom[index_of_hl_name])
            else
                highlight_line(self.searcher.bufnr, children[div]:top(), line_hl[index_of_hl_name])
                highlight_line(self.searcher.bufnr, children[div]:bottom(), line_hl[index_of_hl_name])
            end
        end
        vim.cmd.redraw()
    end
end

function Controller:clear_highlight()
    vim.api.nvim_buf_clear_namespace(self.searcher.bufnr, ns, 0, -1)
end

return Controller
