---@class Searcher
---@field winid integer
---@field bufnr integer
---@field divisions integer
---@field current Split
---@field private history Split[]
local Searcher = {}
Searcher.__index = Searcher

function Searcher.new(winid, divisions, split)
	return setmetatable({
		winid = winid,
		bufnr = vim.api.nvim_win_get_buf(winid),
		divisions = divisions,
		current = split,
		history = {},
	}, Searcher)
end

function Searcher:focus_on(index)
	local child, err = self.current:child(index, self.divisions)
	if not child then
		return nil, err
	end

	table.insert(self.history, self.current)
	self.current = child
	return self.current
end

function Searcher:back()
	if #self.history == 0 then
		return nil, {
			code = "NO_HISTORY_FOUND",
			self = self,
		}
	end

	self.current = table.remove(self.history)
	return self.current
end

function Searcher:is_finished()
	return self.current:lines() <= 1 or self.current:lines() < require("hamal.state").opts.divisions
end

local jump_place = {
    function(self) return self.current:top() end,
    function(self) return self.current:middle() end,
    function(self) return self.current:bottom() end,
}
function Searcher:set_cursor(place)
	local curosr_col = vim.api.nvim_win_get_cursor(0)[2] -- api returns {row, col}, [2] gets col
	vim.api.nvim_win_set_cursor(self.winid, { jump_place[place](self), curosr_col })
end

return Searcher
