local _ = require('utils')

local canvas = {}

canvas.SCROLL_INDICATOR_ELEMENTS = {
    RADIUS = 50,
    ARROW_WIDTH = 8,
    ARROW_HEIGHT = 15,
    ARROW_OFFSET = 8,

    ARROW_INDEX = 2,

    BALL = {
        type = 'circle',
        action = 'strokeAndFill',
        fillColor = {
            black = 1
        },
        radius = 3,
        center = {
            x = 0,
            y = 0,
        },
        strokeWidth = 1,
        strokeColor = {
            white = 1
        },
        shadow = {
            blurRadius = 2,
            alpha = 0.05,
            offset = {
                h = -0.5,
                w = 0,
            },
        },
        withShadow = true,
    },
    ARROW = {
        type = 'segments',
        action = 'strokeAndFill',
        fillColor = {
            black = 1,
        },
        strokeWidth = 1,
        strokeColor = {
            white = 1,
        },
        shadow = {
            blurRadius = 2,
            alpha = 0.05,
            offset = {
                h = -0.5,
                w = 0,
            },
        },
        withShadow = true,
    }
}


local calculateCoordinates = function(weight)
    local height = canvas.SCROLL_INDICATOR_ELEMENTS.ARROW_HEIGHT * (1 + weight)
    local width = canvas.SCROLL_INDICATOR_ELEMENTS.ARROW_WIDTH
    local offset = canvas.SCROLL_INDICATOR_ELEMENTS.ARROW_OFFSET + (10 * weight)
    local cornerOffset = offset / 2
    return {
        { x = -width, y = -cornerOffset },
        { x = 0, y = -height },
        { x = width, y = -cornerOffset },
        { x = 0, y = -offset },
        { x = -width, y = -cornerOffset },
    }
end


local initializeScrollIndicator = function(x, y)
    local indicator = hs.canvas.new(
        hs.geometry.rect(
            x - canvas.SCROLL_INDICATOR_ELEMENTS.RADIUS,
            y - canvas.SCROLL_INDICATOR_ELEMENTS.RADIUS,
            2 * canvas.SCROLL_INDICATOR_ELEMENTS.RADIUS,
            2 * canvas.SCROLL_INDICATOR_ELEMENTS.RADIUS
        )
    )
    :transformation(
        hs.canvas.matrix.translate(
            canvas.SCROLL_INDICATOR_ELEMENTS.RADIUS,
            canvas.SCROLL_INDICATOR_ELEMENTS.RADIUS
        )
    )
    :level('overlay')
    :appendElements(
        _.table.absorb({}, canvas.SCROLL_INDICATOR_ELEMENTS.BALL),
        _.table.absorb(
            {
                coordinates = calculateCoordinates(0)
            },
            canvas.SCROLL_INDICATOR_ELEMENTS.ARROW
        )
    )
    return indicator
end


canvas.new = function(self, x, y)
    local instance = {}
    instance.scrollIndicator = initializeScrollIndicator(x, y):show()
    self.__index = self
    return setmetatable(instance, self)
end


canvas.updateScrollIndicator = function(self, dx, dy, scrollWeight)
    local canvasCenter = hs.geometry.rect(self.scrollIndicator:frame()).center
    local angle = math.deg(math.atan(dy - canvasCenter.y, dx - canvasCenter.x)) + 90
    self.scrollIndicator[canvas.SCROLL_INDICATOR_ELEMENTS.ARROW_INDEX].coordinates = calculateCoordinates(scrollWeight)
    self.scrollIndicator:rotateElement(
        canvas.SCROLL_INDICATOR_ELEMENTS.ARROW_INDEX,
        angle,
        { x = 0, y = 0 }
    )
    self.scrollIndicator:show()
    return self
end


canvas.delete = function(self)
    self.scrollIndicator:delete()
    self.scrollIndicator = nil
end


return canvas