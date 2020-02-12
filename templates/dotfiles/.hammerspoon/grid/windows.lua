local _    = require('utils')
local grid = require('grid.grid')

local windows = {}
windows.MAXIMIZED_WINDOWS_KEY = 'grid.windows.maximized'
windows.ANIMATION_TIME = 0


local watchWindow = function(window, onWindowChanged)
    if not window then
        return
    end

    return window:newWatcher(
        function(element, event, watcher, info)
            onWindowChanged(window)
        end
    ):start({hs.uielement.watcher.windowMoved, hs.uielement.watcher.windowResized})
end


windows.manager = {}
windows.manager.new = function(self, onWindowChanged)
    local instance = {}
    instance.windowCircle = windows.getWindows()

    instance.currentWindowWatcher = watchWindow(instance.windowCircle:get(), onWindowChanged)
    instance.currentWindowFilter = hs.window.filter.new(_.windows.isStandard):subscribe(
        {
            hs.window.filter.windowFocused,
        },
        function(window, name, event)
            if event == hs.window.filter.windowFocused then
                if instance.currentWindowWatcher then
                    instance.currentWindowWatcher:stop()
                end
                instance.currentWindowWatcher = watchWindow(window, onWindowChanged)
                onWindowChanged(window)
                
                local expectedWindow = instance.windowCircle:get()
                if expectedWindow == window then
                    return
                end

                instance.windowCircle = windows.getWindows()
                onWindowChanged(instance.windowCircle:get())
            end
        end
    )

    self.__index = self
    return setmetatable(instance, self)
end


windows.manager.currentWindow = function(self)
    return self.windowCircle:get()
end


windows.manager.previousWindow = function(self)
    local window = self:currentWindow()
    if not window then
        return
    end
    return self.windowCircle:prev():focus()
end

windows.manager.nextWindow = function(self)
    local window = self:currentWindow()
    if not window then
        return
    end
    return self.windowCircle:next():focus()
end

windows.manager.moveInDirection = function(self, dx, dy)
    local screenFrame = hs.screen.mainScreen():frame()
    local window = self:currentWindow()
    if not window then
        return nil
    end

    local windowFrame = window:frame()

    local x = windowFrame.topleft.x
    if dx ~= 0 then
        x = grid.getNearestX(x, dx)
    end

    local y = windowFrame.topleft.y
    if dy ~= 0 then
        y = grid.getNearestY(y, dy)
    end

    window:setFrame({
        x = math.min(x, screenFrame.w - windowFrame.w),
        y = math.min(y, screenFrame.h - windowFrame.h),
        w = windowFrame.w,
        h = windowFrame.h
    },
    windows.ANIMATION_TIME)
    return window
end

windows.manager.resizeInDirection = function(self, dx, dy)
    local window = self:currentWindow()
    if not window then
        return nil
    end

    local windowFrame = window:frame()

    local x = windowFrame.bottomright.x
    if dx ~= 0 then
        x = grid.getNearestX(x, dx)
    end

    local y = windowFrame.bottomright.y
    if dy ~= 0 then
        y = grid.getNearestY(y, dy)
    end

    window:setFrame({
        x = windowFrame.x,
        y = windowFrame.y,
        w = x - windowFrame.x,
        h = y - windowFrame.y,
    },
    windows.ANIMATION_TIME)
    return window
end

windows.manager.setWindowByBlock = function(self, startX, startY, endX, endY)
    local window = self:currentWindow()
    if not window then
        return nil
    end

    local blockFrame = grid.blockFrame(startX, startY, endX, endY)
    window:setFrame(blockFrame.table, windows.ANIMATION_TIME)
    return window
end

local getMaximizedWindowKey = function(window)
    return windows.MAXIMIZED_WINDOWS_KEY .. '.' .. window:id()
end

windows.manager.toggleMaximize = function(self)
    local window = self:currentWindow()
    if not window then
        return nil
    end

    local windowFrame = window:frame()
    local cellFrame = grid.cellFrame(1, 1, grid.xLength(), grid.yLength())

    local key = getMaximizedWindowKey(window)
    local storedFrame = hs.settings.get(key)
    if storedFrame then
        window:setFrame(storedFrame, windows.ANIMATION_TIME)
        hs.settings.clear(key)
    else
        hs.settings.set(key, windowFrame.table)
        window:setFrame(cellFrame.table, windows.ANIMATION_TIME)
    end
    return window
end

windows.manager.delete = function(self)
    self.currentWindowFilter:unsubscribeAll()
    self.currentWindowWatcher:stop()

    local windowIds = {}
    for i, window in ipairs(hs.window.allWindows()) do
        windowIds[tostring(window:id())] = true
    end

    -- Clean up dead window keys
    for i, key in ipairs(hs.settings.getKeys()) do
        if _.string.startsWith(key, windows.MAXIMIZED_WINDOWS_KEY) then
            local windowId = string.sub(key, string.len(windows.MAXIMIZED_WINDOWS_KEY) + 1 + 1)
            if windowIds[windowId] == nil then
                hs.settings.clear(key)
            end
        end
    end
end


windows.manager.debug = function(self)
    local initial = self.windowCircle.node

    local node = initial
    repeat
        print(node.data:application():name())
        node = node.next
    until node.data == initial.data

    print()
end


windows.getWindows = function()
    local circle = _.circle:new(function(window)
        return window:id()
    end)

    for i, window in ipairs(_.windows.getOrderedWindows()) do
        circle:insertAfter(window)
    end

    circle:next()
    return circle
end


return windows