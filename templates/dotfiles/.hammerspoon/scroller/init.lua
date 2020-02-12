local _ =      require('utils')
local events = require('hs.eventtap.event')
local canvas = require('scroller.canvas')

local module = {}
module.STATES = {
    START = 0,
    MODE_CHECK = 1,
    DRAGGING = 2,
    TOGGLED = 3,

}
module.MIDDLE_MOUSE_ID = 2
module.DEAD_ZONE_RADIUS = 15
module.SCROLL_MULTIPLIER = 0.025
module.MAX_SCROLL_RATE = 50
module.CHROME_TAB_HEIGHT = 42

module.scrollIndicator = nil
module.scrollState = module.STATES.START
module.initialPosition = { x = 0, y = 0}
module.scrollRate = { x = 0, y = 0 }
module.scrollRemainder = { x = 0, y = 0 }


module.start = function(event)
    module.clickListener:start()
end


local shouldIgnore = function(event)
    local eventType = event:getType()
    local isMiddleButton = event:getProperty(events.properties.mouseEventButtonNumber) == module.MIDDLE_MOUSE_ID

    if isMiddleButton then
        return not (
            eventType == events.types.otherMouseDown or
            eventType == events.types.otherMouseUp or
            eventType == events.types.otherMouseDragged
        )
    end

    return eventType ~= events.types.mouseMoved
end


local isOnTab = function(event)
    local windows = _.windows.getOrderedWindows()
    local position = hs.geometry.new(event:location())
    for i, window in ipairs(windows) do
        local windowFrame = window:frame()
        if position:inside(windowFrame) then
            local application = window:application():name()
            if application == 'Google Chrome' then
                return position:inside({windowFrame.x, windowFrame.y, windowFrame.w, module.CHROME_TAB_HEIGHT})
            end
            return false
        end
    end
    return false
end


module.handleStart = function(event)
    module.scrollState = module.STATES.MODE_CHECK
    module.initialPosition = event:location()
    module.scrollRate = {
        x = 0,
        y = 0,
    }
    module.scrollRemainder = {
        x = 0,
        y = 0,
    }
    module.scrollIndicator = canvas:new(module.initialPosition.x, module.initialPosition.y)
    return true, {}
end


module.handleModeCheck = function(event)
    local eventType = event:getType()
    local position = event:location()
    local isOutsideDeadzone = (
        math.abs(position.x - module.initialPosition.x) > module.DEAD_ZONE_RADIUS or
        math.abs(position.y - module.initialPosition.y) > module.DEAD_ZONE_RADIUS
    )

    if event:getType() == events.types.otherMouseDragged then
        if isOutsideDeadzone then
            module.scrollState = module.STATES.DRAGGING
            module.scrollListener:start()
            events.newScrollEvent({0, 0}, {}, 'pixel'):post()
        end
    else
        if not isOutsideDeadzone then
            module.scrollState = module.STATES.TOGGLED
            module.scrollListener:start()
            events.newScrollEvent({0, 0}, {}, 'pixel'):post()
        end
    end
    return true, {}
end


module.handleMouseMoved = function(event)
    local position = event:location()
    local dx, dy = module.initialPosition.x - position.x, module.initialPosition.y - position.y
    module.scrollRate = {
        x = math.abs(dx) > module.DEAD_ZONE_RADIUS and math.min(math.floor(dx) * module.SCROLL_MULTIPLIER, module.MAX_SCROLL_RATE) or 0,
        y = math.abs(dy) > module.DEAD_ZONE_RADIUS and math.min(math.floor(dy) * module.SCROLL_MULTIPLIER, module.MAX_SCROLL_RATE) or 0
    }

    local scrollRateSize = math.max(
        math.abs(module.scrollRate.x) ^ 0.5 / module.MAX_SCROLL_RATE ^ 0.5,
        math.abs(module.scrollRate.y) ^ 0.5 / module.MAX_SCROLL_RATE ^ 0.5
    )

    module.scrollIndicator:updateScrollIndicator(
        position.x,
        position.y,
        scrollRateSize
    )

    return true, {}
end


module.handleStop = function(event)
    module.scrollListener:stop()
    module.scrollRate = { x = 0, y = 0 }
    module.scrollRemainder = { x = 0, y = 0 }
    module.scrollIndicator:delete()
    module.scrollState = module.STATES.START
    return true, {}
end


module.clickListener = hs.eventtap.new(
    {
        events.types.otherMouseDown,
        events.types.otherMouseUp,
        events.types.otherMouseDragged,
        events.types.mouseMoved,
    },
    function(event)
        if shouldIgnore(event) then
            return false, {}
        end

        local eventType = event:getType()

        if module.scrollState == module.STATES.START then
            if eventType == events.types.otherMouseDown and not isOnTab(event) then
                return module.handleStart(event)
            end
        elseif module.scrollState == module.STATES.MODE_CHECK then
            if eventType == events.types.otherMouseDragged then
                return module.handleModeCheck(event)
            elseif eventType == events.types.otherMouseUp then
                return module.handleModeCheck(event)
            end
        elseif module.scrollState == module.STATES.DRAGGING then
            if eventType == events.types.otherMouseDragged then
                return module.handleMouseMoved(event)
            elseif eventType == events.types.otherMouseUp then
                return module.handleStop(event)
            end
        elseif module.scrollState == module.STATES.TOGGLED then
            if eventType == events.types.mouseMoved then
                return module.handleMouseMoved(event)
            elseif eventType == events.types.otherMouseDown then
                return module.handleStop(event)
            end
        end

        return false, {}
    end
)


module.scrollListener = hs.eventtap.new(
    {
        events.types.scrollWheel
    },
    function(event)
        if module.scrollState ~= module.STATES.DRAGGING and module.scrollState ~= module.STATES.TOGGLED then
            return false, {}
        end

        local xRemainder = module.scrollRemainder.x + (module.scrollRate.x % 1)
        local yRemainder = module.scrollRemainder.y + (module.scrollRate.y % 1)

        events.newScrollEvent(
            {
                math.floor(module.scrollRate.x) + math.floor(xRemainder),
                math.floor(module.scrollRate.y) + math.floor(yRemainder),
            },
            {},
            'pixel'
        ):post()

        module.scrollRemainder = {
            x = xRemainder % 1,
            y = yRemainder % 1,
        }
        
        return false, {}
    end
)


return module