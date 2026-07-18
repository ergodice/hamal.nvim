local state = require("hamal.state")
local ns = vim.api.nvim_create_namespace("hamal.searcher")

---@class Controller
---@field searcher Searcher
local Controller = {}
Controller.__index = Controller

function Controller.new(searcher)
    local self = setmetatable({
        searcher = searcher,
    }, Controller)
    return self
end

-- split・movement
function Controller:split()
    self.searcher:set_cursor(2)
    self:highlight()

    -- takeover inputs
    vim.on_key(function(key)
        if key ~= "" then
            local keytrans = vim.fn.keytrans(key)
            vim.schedule(function()
                if state.opts.keymaps[keytrans] then
                    state.opts.keymaps[keytrans]()
                elseif state.opts.quit_on_unmapped_keys then
                    self:quit()
                end
            end)

            if not state.opts.keymaps[keytrans] and state.opts.quit_on_unmapped_keys then
                vim.notify("through")
                return nil
            end
            return ""
        end
    end, state.ns)
end

function Controller:focus(index)
    local _, err = self.searcher:focus_on(index)
    if err then
        require("hamal.utils").notify_err(err.code)
    end
    self.searcher:set_cursor(2)
    self:highlight()

    if self.searcher:is_finished() then
        self:quit()
    end
end

function Controller:pan_focus()
    local _, err = self.searcher:back()
    if err then
        require("hamal.utils").notify_warn(err.code)
    end
    self.searcher:set_cursor(2)
    self:highlight()
end

function Controller:quit()
    vim.on_key(nil, state.ns)
    self:clear_highlight()
    state.controllers[self.searcher.winid] = nil
end

-- hilights
local function highlight_line(bufnr, line, hl)
    vim.api.nvim_buf_set_extmark(bufnr, ns, line - 1, 0, {
        line_hl_group = hl,
    })
end

function Controller:highlight()
    vim.api.nvim_buf_clear_namespace(self.searcher.bufnr, ns, 0, -1)

    local children, err = self.searcher.current:split(state.opts.divisions)
    if children == nil then
        return err
    end

    local number_of_highlights = vim.tbl_count(state.opts.highlights)
    local get_hl = function(div)
        local mod = div % number_of_highlights
        if mod == 0 then -- lua table is one-based.
            return number_of_highlights
        else
            return mod
        end
    end
    local index_of_hl = 1 -- hl format : { <name>, <spec> }
    for div = 1, state.opts.divisions do
        highlight_line(self.searcher.bufnr, children[div]:top(), state.opts.highlights[get_hl(div)][index_of_hl])
        highlight_line(self.searcher.bufnr, children[div]:bottom(), state.opts.highlights[get_hl(div)][index_of_hl])
    end
end

function Controller:clear_highlight()
    vim.api.nvim_buf_clear_namespace(self.searcher.bufnr, ns, 0, -1)
end

return Controller
