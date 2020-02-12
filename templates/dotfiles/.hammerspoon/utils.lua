local utils = {}

-- Math

utils.math = {}

utils.math.mod = function(index, length)
    return (index - 1) % length + 1
end

utils.math.minmax = function(min, value, max)
    return math.min(math.max(min, value), max)
end


-- Tables

utils.table = {}

utils.table.absorb = function(t, new)
    for k, v in pairs(new) do
        t[k] = v
    end
    return t
end

-- Data Structures

utils.circle = {}

utils.circle.new = function(self, idFunction)
    local instance = {
        length = 0,
        node = nil,
        first = nil,
        last = nil,
        idFunction = idFunction,
        idMap = {}
    }

    self.__index = self
    return setmetatable(instance, self)
end

local createInitialNode = function(data)
    local node = {
        data = data,
        next = nil,
        prev = nil
    }
    node.next = node
    node.prev = node
    return node
end

utils.circle.get = function(self)
    return self.node and self.node.data or nil
end

utils.circle.next = function(self)
    if not self.node then
        return nil
    end

    self.node = self.node.next
    return self:get()
end

utils.circle.prev = function(self)
    if not self.node then
        return nil
    end

    self.node = self.node.prev
    return self:get()
end

utils.circle.insertBefore = function(self, data)
    if not self.node then
        self.node = createInitialNode(data)
    else
        local new = {
            data = data,
            prev = self.node.prev,
            next = self.node
        }
        self.node.prev.next = new
        self.node.prev = new
        self.node = new
    end

    self.idMap[self.idFunction(self.node.data)] = self.node
    return self.node
end

utils.circle.insertAfter = function(self, data)
    if not self.node then
        self.node = createInitialNode(data)
    else
        local new = {
            data = data,
            prev = self.node,
            next = self.node.next
        }
        self.node.next.prev = new
        self.node.next = new
        self.node = new
    end

    self.idMap[self.idFunction(self.node.data)] = self.node
    return self.node
end

utils.circle.remove = function(self, data)
    local node = self.idMap[self.idFunction(self.node.data)]
    if not node then
        return data
    end

    if node == self.node then
        self.node = self.node.next
    end

    self.node.prev = node.prev
    node.prev.next = self.node

    return data
end


-- Strings

utils.string = {}

utils.string.startsWith = function(str, start)
    return str:sub(1, #start) == start
end


-- Canvas

utils.canvas = {}

utils.canvas.hex2color = function(hex, alpha)
    alpha = alpha or 1.0
    return {
        red = tonumber('0x' .. string.sub(hex, 2, 3)) / 255,
        green = tonumber('0x' .. string.sub(hex, 4, 5)) / 255,
        blue = tonumber('0x' .. string.sub(hex, 6, 7)) / 255,
        alpha = alpha
    }
end


-- Hotkeys

utils.hotkey = {}

utils.hotkey.limitRepeat = function(fn, delay)
    local delay = delay or 0.1
    local repeatDisabled = false
    return function()
        if not repeatDisabled then
            repeatDisabled = true
            hs.timer.doAfter(delay, function() repeatDisabled = false end)
            return fn()
        end
    end
end


-- Windows

utils.windows = {}

utils.windows.isStandard = function(window)
    return window:role() == 'AXWindow' and window:subrole() == 'AXStandardWindow'
end

utils.windows.getOrderedWindows = function()
    local windowsById = {}
    for i, v in ipairs(hs.window.allWindows()) do
        windowsById[v:id()] = v
    end

    local result = {}
    for i, v in ipairs(hs.window._orderedwinids()) do
        local window = windowsById[v]
        if window and window:isVisible() and utils.windows.isStandard(window) then
            table.insert(result, window)
        end
    end
    return result
end


-- Time

utils.time = {}

utils.time.ns2ms = function(ns)
    return ns / 1000 / 1000
end

utils.time.ms2s = function(ms)
    return ms / 1000
end


return utils