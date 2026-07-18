---@class Split
---@field private start integer
---@field private finish integer
local Split = {}
Split.__index = Split

function Split.new(start, finish)
    if start > finish then
        return nil, {
            code = "INVALID_SPLIT_GEN",
            start = start,
            finish = finish,
        }
    end
	return setmetatable({
		start = start,
		finish = finish,
	}, Split)
end

-- returns top/middle/bottom of split
function Split:top()
	return self.start
end

function Split:middle()
	return math.floor((self.start + self.finish) / 2)
end

function Split:bottom()
	return self.finish
end

-- returns number of lines
function Split:lines()
	return self.finish - self.start + 1
end

-- returns a new split table based on the number of divisions
---@param divisions integer
function Split:split(divisions)
	local result = {}

	local length = self:lines()
	local size = math.floor(length / divisions)
	local remain = length % divisions

	local start = self.start

	for i = 1, divisions do
		local width = size
		if i <= remain then
			width = width + 1
		end

		local finish = start + width - 1

        local split, err = Split.new(start, finish)
        if split == nil then
            return nil, err
        end

		result[i] = split
		start = finish + 1
	end

	return result
end

-- returns a new split based on the number of divisions and index
---@param index integer
---@param divisions integer
function Split:child(index, divisions)
	if index < 1 or index > divisions then
		return nil, {
			code = "INDEX_OUT_OF_RANGE",
			index = index,
			divisions = divisions,
		}
	end
    local split, err = self:split(divisions)
    if split == nil then
        return nil, err
    end
	return split[index]
end

return Split
