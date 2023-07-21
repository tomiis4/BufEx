---@class SelectScreen
---@field [1] number win
---@field [2] number buf


local select_screens = {} ---@type SelectScreen[]
local api = vim.api

local U = require('bufex.utils')
local M = {}


local function clear_screens()
    for _, v in pairs(select_screens) do
        local win, buf = v[1], v[2]

        if win ~= nil and api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, true)
        end

        if buf ~= nil and api.nvim_buf_is_valid(buf) then
            api.nvim_buf_delete(buf, { force = true })
        end
    end

    select_screens = {}
end

---@param title string
---@param position 'left'|'right'|'center'
---@param size Size
---@param content table<table<string>, table<number>> -- 1) val, 2) val start
---@param callback fun(option: string, n_option: number)
---@return number, number
function M.new_select(title, position, size, content, callback)
    local buf, win = U.setup_win_buf(title, position, size, content[1])

    -- configure win and register it to `input_screens`
    api.nvim_set_current_win(win)
    table.insert(select_screens, { win, buf })

    local function select_item()
        local row = api.nvim_win_get_cursor(0)[1]

        local i = 1
        -- FIXME: fix not clicking on 1. item and not options
        vim.print(vim.inspect(content))
        while row > content[2][i] do
            i = i + 1
        end

        callback(content[1][i], i)
        clear_screens()
    end

    vim.keymap.set('n', '<cr>', select_item, { buffer = buf, })
    return buf, win
end

return M
