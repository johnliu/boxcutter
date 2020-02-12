local _    = require('utils')
local grid = require('grid.grid')

local control = {}

control.DIRECTION_MAP = {
    left  = { dx = -1, dy =  0 },
    h     = { dx = -1, dy =  0 },
    right = { dx =  1, dy =  0 },
    l     = { dx =  1, dy =  0 },
    up    = { dx =  0, dy = -1 },
    k     = { dx =  0, dy = -1 },
    down  = { dx =  0, dy =  1 },
    j     = { dx =  0, dy =  1 },
}

control.bind = function(modal, module)
    modal.entered = function(self) module.start() end

    local bindings = {
        { key = 'escape', fn = module.stop },
        { key = 'return', fn = module.stop },
        { key = 'space', fn = module.toggleMaximize },
        { key = '=', fn = function() module.adjustBlockSize(-1) end },
        { key = '-', fn = function() module.adjustBlockSize(1) end },
        {
            key = 'tab',
            fn = module.nextWindow,
            repeatable = 0.2,
        },
        {
            mods = {'shift'},
            key = 'tab',
            fn = module.previousWindow,
            repeatable = 0.2,
        },
    }

    for k, v in pairs(control.DIRECTION_MAP) do
        table.insert(bindings, {
            key = k,
            fn = function() module.moveInDirection(v.dx, v.dy) end,
            repeatable = 0.1,
        })
        table.insert(bindings, {
            mods = {'shift'},
            key = k,
            fn = function() module.resizeInDirection(v.dx, v.dy) end,
            repeatable = 0.1,
        })
    end

    for i = 1, #grid.MAP do
        for j = 1, #grid.MAP[i] do
            table.insert(bindings, {
                key = grid.MAP[j][i],
                fn = function() module.selectOverlayPane(i, j) end
            })
        end
    end

    for i, binding in ipairs(bindings) do
        modal:bind(
            binding.mods or {},
            binding.key,
            nil,
            binding.fn,
            binding.repeatable and _.hotkey.limitRepeat(binding.fn, binding.repeatable) or nil
        )
    end
end

return control