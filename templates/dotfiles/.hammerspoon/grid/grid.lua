local _ = require('utils')

local grid = {}


grid.X_BLOCK_SIZES = {1, 3, 6}
grid.Y_BLOCK_SIZES = {1, 2, 4}
grid.MAP = {
    {'Q', 'W', 'E'},
    {'A', 'S', 'D'},
    {'Z', 'X', 'C'},
}

grid.currentBlockSize = 2
grid.xBlockLength  = function() return grid.X_BLOCK_SIZES[grid.currentBlockSize] end
grid.yBlockLength  = function() return grid.Y_BLOCK_SIZES[grid.currentBlockSize] end
grid.xLength       = function() return #grid.MAP[1] * grid.xBlockLength() end
grid.yLength       = function() return #grid.MAP * grid.yBlockLength() end

local function getScreenFrame()
    return hs.screen.mainScreen():frame()
end


-- Grid State

grid.unitCell = function()
    local screenFrame = getScreenFrame()
    return hs.geometry.size(
        math.floor(screenFrame.w / grid.xLength()),
        math.floor(screenFrame.h / grid.yLength())
    )
end

grid.unitBlock = function()
    local screenFrame = getScreenFrame()
    return hs.geometry.size(
        math.floor(screenFrame.w / (grid.xLength() / grid.xBlockLength())),
        math.floor(screenFrame.h / (grid.yLength() / grid.yBlockLength()))
    )
end

grid.cellFrame = function(startX, startY, endX, endY)
    endX = endX or startX
    endY = endY or startY

    local screenFrame = getScreenFrame()
    local unitCell = grid.unitCell()

    local x = (startX - 1) * unitCell.w
    local y = (startY - 1) * unitCell.h
    local w = unitCell.w * (endX - startX + 1)
    local h = unitCell.h * (endY - startY + 1)

    local adjustedWidth = w
    if endX == grid.xLength() then
        adjustedWidth = screenFrame.w - x
    end

    local adjustedHeight = h
    if endY == grid.yLength() then
        adjustedHeight = screenFrame.h - y
    end

    return hs.geometry.rect(x + screenFrame.x, y + screenFrame.y, adjustedWidth, adjustedHeight)
end

grid.blockFrame = function(startX, startY, endX, endY)
    endX = endX or startX
    endY = endY or startY

    return grid.cellFrame(
        (startX - 1) * grid.xBlockLength() + 1,
        (startY - 1) * grid.yBlockLength() + 1,
        endX * grid.xBlockLength(),
        endY * grid.yBlockLength()
    )
end

grid.getNearestX = function(x, dx)
    local screenFrame = getScreenFrame()
    x = x - screenFrame.x

    local unitCell = grid.unitCell()
    local pos
    if dx < 0 then
        pos = _.math.minmax(1, math.floor((x - 1) / unitCell.w) + 1, grid.xLength())
        return grid.cellFrame(pos, 1).x
    else
        pos = _.math.minmax(1, math.ceil((x + 1) / unitCell.w), grid.xLength())
        return grid.cellFrame(pos, 1).x2
    end
end

grid.getNearestY = function(y, dy)
    local screenFrame = getScreenFrame()
    y = y - screenFrame.y

    local unitCell = grid.unitCell()
    local pos
    if dy < 0 then
        pos = _.math.minmax(1, math.floor((y - 1) / unitCell.h) + 1, grid.yLength())
        return grid.cellFrame(1, pos).y
    else
        pos = _.math.minmax(1, math.ceil((y + 1) / unitCell.h), grid.yLength())
        return grid.cellFrame(1, pos).y2
    end
end


return grid