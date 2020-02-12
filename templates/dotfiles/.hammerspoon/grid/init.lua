local _       = require('utils')
local grid    = require('grid.grid')
local windows = require('grid.windows')
local control = require('grid.control')
local canvas  = require('grid.canvas')

local module = {}

module.modal = nil
module.windowManager = nil
module.canvas = nil
module.selectedBlock = nil

module.bind = function(modal)
    module.modal = modal
    control.bind(modal, module)
end

module.reset = function()
    module.windowManager = nil
    module.selectedBlock = nil

    if module.canvas then
        module.canvas:delete()
        module.canvas = nil
    end
end

module.start = function()
    module.reset()
    module.windowManager = windows.manager:new(function(window)
        module.canvas:updateWindowSelector(window)
    end)
    module.canvas = canvas
        :new()
        :showOverlay()
        :showWindowSelector(module.windowManager:currentWindow())
end

module.stop = function()
    module.deselectOverlayPane()
    module.canvas
        :hideOverlay()
        :hideWindowSelector()
    module.windowManager:delete()
    module.modal:exit()
end

module.onWindowChanged = function(window)
    module.canvas:updateWindowSelector(window)
end

module.nextWindow = function()
    module.deselectOverlayPane()
    module.windowManager:nextWindow()
end

module.previousWindow = function()
    module.deselectOverlayPane()
    module.windowManager:previousWindow()
end

module.moveInDirection = function(dx, dy)
    module.deselectOverlayPane()
    module.windowManager:moveInDirection(dx, dy)
end

module.resizeInDirection = function(dx, dy)
    module.deselectOverlayPane()
    module.windowManager:resizeInDirection(dx, dy)
end

module.deselectOverlayPane = function()
    module.selectedBlock = nil
    module.canvas:cancelOverlayPane()
end

module.selectOverlayPane = function(x, y)
    if module.selectedBlock == nil then
        module.selectedBlock = { x = x, y = y }
        module.canvas:showOverlayPane(x, y, x, y)
    else
        x = math.max(x, module.selectedBlock.x)
        y = math.max(y, module.selectedBlock.y)
        local window = module.windowManager:setWindowByBlock(
            module.selectedBlock.x,
            module.selectedBlock.y,
            x,
            y
        )

        module.canvas:hideOverlayPane(
            module.selectedBlock.x,
            module.selectedBlock.y,
            x,
            y
        )
        
        module.deselectOverlayPane()
    end
end

module.adjustBlockSize = function(direction)
    grid.currentBlockSize = _.math.minmax(1, grid.currentBlockSize + direction, #grid.X_BLOCK_SIZES)
    module.canvas:updateOverlay()
end

module.toggleMaximize = function()
    module.windowManager:toggleMaximize()
end


return module