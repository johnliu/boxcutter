local _    = require('utils')
local grid = require('grid.grid')

local canvas = {}


canvas.PRIMARY_COLOR = '#F29F05'
canvas.OVERLAY_ELEMENTS = {
    BACKGROUND = {
        type = 'rectangle',
        action = 'fill',
        fillColor = {
            black = 1.0,
            alpha = 0.35,
        },
    },
    BLOCK_SEPARATOR = {
        type = 'segments',
        action = 'stroke',
        strokeColor = _.canvas.hex2color(canvas.PRIMARY_COLOR),
        strokeWidth = 2,
    },
    CELL_SEPARATOR = {
        type = 'segments',
        action = 'stroke',
        strokeDashPattern = { 4, 6 },
        strokeColor = _.canvas.hex2color(canvas.PRIMARY_COLOR),
        strokeWidth = 1,
    },
    BLOCK_LABEL_BACKGROUND = {
        type = 'rectangle',
        action = 'fill',
        roundedRectRadii = {
            xRadius = 3,
            yRadius = 3,
        },
        fillColor = _.canvas.hex2color(canvas.PRIMARY_COLOR),
    },
    BLOCK_LABEL_TEXT = {
        type = 'text',
        action = 'fill',
        textFont = 'SF Pro Text Bold',
        textSize = 14.0,
        textAlignment = 'center',
    },
    BLOCK_LABEL_OFFSET = 12,
    BLOCK_LABEL_SIZE = 24,
    BLOCK_LABEL_TEXT_ADJUSTMENT = 1,
}
canvas.WINDOW_SELECTOR_ELEMENTS = {
    HIGHLIGHT = {
        type = 'rectangle',
        action = 'fill',
        roundedRectRadii = {
            xRadius = 6,
            yRadius = 6,
        },
        fillColor = _.canvas.hex2color(canvas.PRIMARY_COLOR, 0.4)
    }
}
canvas.OVERLAY_PANE_ELEMENTS = {
    PANE = {
        type = 'rectangle',
        action = 'fill',
        fillColor = _.canvas.hex2color(canvas.PRIMARY_COLOR, 0.5)
    }
}

local function getScreenFrame()
    return hs.screen.mainScreen():fullFrame()
end

canvas.new = function(self)
    local instance = {}
    local screenFrame = getScreenFrame()
    instance.overlay = hs.canvas.new(screenFrame):level('overlay')
    instance.overlayPane = nil
    instance.windowSelector = hs.canvas.new(screenFrame):level('floating')

    self.__index = self
    return setmetatable(instance, self)
end

canvas.updateOverlay = function(self)
    local screenFrame = getScreenFrame()
    local usableScreenFrame = hs.screen.mainScreen():frame()
    local elements = {
        _.table.absorb(
            {
                frame = usableScreenFrame.table
            },
            canvas.OVERLAY_ELEMENTS.BACKGROUND
        )
    }

    -- Grid Lines
    for i = 2, grid.xLength() do
        local cellFrame = grid.cellFrame(i, 1)

        local separator
        if _.math.mod(i, grid.xBlockLength()) == 1 then
            separator = canvas.OVERLAY_ELEMENTS.BLOCK_SEPARATOR
        else
            separator = canvas.OVERLAY_ELEMENTS.CELL_SEPARATOR
        end

        local element = _.table.absorb(
            {
                coordinates = {
                    { x = cellFrame.x, y = cellFrame.y },
                    { x = cellFrame.x, y = cellFrame.y + usableScreenFrame.h },
                }
            },
            separator
        )

        table.insert(elements, element)
    end
    
    for i = 2, grid.yLength() do
        local cellFrame = grid.cellFrame(1, i)

        local separator
        if _.math.mod(i, grid.yBlockLength()) == 1 then
            separator = canvas.OVERLAY_ELEMENTS.BLOCK_SEPARATOR
        else
            separator = canvas.OVERLAY_ELEMENTS.CELL_SEPARATOR
        end

        local element = _.table.absorb(
            {
                coordinates = {
                    { x = cellFrame.x, y = cellFrame.y },
                    { x = cellFrame.x + usableScreenFrame.w, y = cellFrame.y },
                }
            },
            separator
        )

        table.insert(elements, element)
    end

    -- Block Labels
    for i = 1, #grid.MAP do
        for j = 1, #grid.MAP[i] do
            local blockFrame = grid.blockFrame(i, j)
            local labelBackground = _.table.absorb(
                {
                    frame = {
                        x = blockFrame.x + canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_OFFSET,
                        y = blockFrame.y + canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_OFFSET,
                        w = canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_SIZE,
                        h = canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_SIZE,
                    }
                },
                canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_BACKGROUND
            )
            local labelText = _.table.absorb(
                {
                    text = grid.MAP[j][i],
                    frame = {
                        x = blockFrame.x + canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_OFFSET,
                        y = blockFrame.y + canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_OFFSET + canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_TEXT_ADJUSTMENT,
                        w = canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_SIZE,
                        h = canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_SIZE,
                    }
                },
                canvas.OVERLAY_ELEMENTS.BLOCK_LABEL_TEXT
            )

            table.insert(elements, labelBackground)
            table.insert(elements, labelText)
        end
    end

    self.overlay:replaceElements(table.unpack(elements))
    return self
end

canvas.showOverlay = function(self)
    self:updateOverlay()
    self.overlay:show(0.1)
    return self
end

canvas.hideOverlay = function(self)
    self.overlay:hide(0.15)
    return self
end

canvas.updateWindowSelector = function(self, window)
    if window == nil then
        while self.windowSelector:elementCount() > 0 do
            self.windowSelector:removeElement()
        end
        return self
    end

    local element = _.table.absorb(
        { frame = window:frame().table },
        canvas.WINDOW_SELECTOR_ELEMENTS.HIGHLIGHT
    )

    self.windowSelector:replaceElements(element)
    return self
end

canvas.showWindowSelector = function(self, window)
    self:updateWindowSelector(window)
    self.windowSelector:show(0.1)
    return self
end

canvas.hideWindowSelector = function(self)
    self.windowSelector:hide(0.15)
    return self
end

canvas.updateOverlayPane = function(self, startX, startY, endX, endY)
    local blockFrame = grid.blockFrame(startX, startY, endX, endY)
    local element = _.table.absorb(
        { frame = blockFrame.table },
        canvas.OVERLAY_PANE_ELEMENTS.PANE
    )
    self.overlayPane:replaceElements(element)
    self.overlayPane:show()
    return self
end

canvas.showOverlayPane = function(self, startX, startY, endX, endY)
    self.overlayPane = hs.canvas.new(getScreenFrame()):level('overlay')
    self:updateOverlayPane(startX, startY, endX, endY)
    return self
end

canvas.hideOverlayPane = function(self, startX, startY, endX, endY)
    if self.overlayPane then
        self:updateOverlayPane(startX, startY, endX, endY)
        self.overlayPane:delete(1.5)
        self.overlayPane = nil
    end
    return self
end

canvas.cancelOverlayPane = function(self)
    if self.overlayPane then
        self.overlayPane:delete()
        self.overlayPane = nil
    end
    return self
end

canvas.delete = function(self)
    self.overlay:delete()
    self.windowSelector:delete()
    if self.overlayPane then
        self.overlayPane:delete()
        self.overlayPane = nil
    end
end


return canvas