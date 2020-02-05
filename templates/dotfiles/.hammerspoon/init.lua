-- Utils

function cycleNumbers(index, length)
    return (index - 1) % length + 1
end

function hex2table(hex, alpha)
    alpha = alpha or 1.0
    return {
        red = tonumber('0x' .. string.sub(hex, 2, 3)) / 255,
        green = tonumber('0x' .. string.sub(hex, 4, 5)) / 255,
        blue = tonumber('0x' .. string.sub(hex, 6, 7)) / 255,
        alpha = alpha
    }
end

function range(min, value, max)
    return math.min(math.max(min, value), max)
end

function getScreenFrame()
    return hs.screen.mainScreen():frame()
end

function repeatDelay(fn)
    local repeatDisabled = false
    return function()
        if not repeatDisabled then
            repeatDisabled = true
            hs.timer.doAfter(0.05, function() repeatDisabled = false end)
            return fn()
        end
    end
end

function ns2ms(ns)
    return ns / 1000 / 1000
end

function ms2s(ms)
    return ms / 1000
end

-- Grid
local grid = {
    xBlockSizes = {1, 3, 6},
    yBlockSizes = {1, 2, 4},
    currentBlockSize = 2
}
grid.map = {
    {'Q', 'W', 'E'},
    {'A', 'S', 'D'},
    {'Z', 'X', 'C'}
}

function grid.xBlockLength() return grid.xBlockSizes[grid.currentBlockSize] end
function grid.yBlockLength() return grid.yBlockSizes[grid.currentBlockSize] end
function grid.xLength() return #grid.map[1] * grid.xBlockLength() end
function grid.yLength() return #grid.map * grid.yBlockLength() end

function grid.unitCell()
    local screenFrame = getScreenFrame()
    return hs.geometry.size(
        math.floor(screenFrame.w / grid.xLength()),
        math.floor(screenFrame.h / grid.yLength())
    )
end

function grid.unitBlock()
    local screenFrame = getScreenFrame()
    return hs.geometry.size(
        math.floor(screenFrame.w / (grid.xLength() / grid.xBlockLength())),
        math.floor(screenFrame.h / (grid.yLength() / grid.yBlockLength()))
    )
end

function grid.mapFromIndex(x, y)
    return grid.map[(y - 1) / grid.yBlockLength() + 1][(x - 1) / grid.xBlockLength() + 1]
end

function grid.cellFrame(startX, startY, endX, endY)
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

    return hs.geometry.rect(x, y, adjustedWidth, adjustedHeight)
end

function grid.getNearestPosition(window)
    local windowFrame = window:frame()
    local unitCell = grid.unitCell()
    
    posX = math.floor(windowFrame.x / unitCell.w)
    posY = math.floor(windowFrame.y / unitCell.h)

    return hs.geometry.point(posX + 1, posY + 1)
end

function grid.getNearestSize(window)
    local windowFrame = window:frame()
    local unitCell = grid.unitCell()

    w = math.floor(windowFrame.w / unitCell.w)
    h = math.floor(windowFrame.h / unitCell.h)

    return hs.geometry.size(w, h)
end

-- Window Management

local windowOrder = nil
local windowIndex = nil
local maximizedWindows = {}

function cycleWindow(direction)
    if direction == 0 then
        if windowOrder[windowIndex]:isStandard() then
            return
        end
        direction = 1
    end

    repeat
        windowIndex = cycleNumbers(windowIndex + direction, #windowOrder)
    until windowOrder[windowIndex]:isStandard()
    return windowOrder[windowIndex]:focus()
end

function moveInDirection(window, directionX, directionY)
    local windowFrame = window:frame()
    local nearestPosition = grid.getNearestPosition(window)
    local nearestFrame = grid.cellFrame(nearestPosition.x, nearestPosition.y)

    if directionX > 0 then
        nearestPosition.x = nearestPosition.x + 1
    elseif directionX < 0 then
        if nearestFrame.x == windowFrame.x then
            nearestPosition.x = nearestPosition.x - 1
        end
    end

    if directionY > 0 then
        nearestPosition.y = nearestPosition.y + 1
    elseif directionY < 0 then
        if nearestFrame.y == windowFrame.y then
            nearestPosition.y = nearestPosition.y - 1
        end
    end

    nearestFrame = grid.cellFrame(
        range(1, nearestPosition.x, grid.xLength()),
        range(1, nearestPosition.y, grid.yLength())
    )
    window:setFrame({
        x = nearestFrame.x,
        y = nearestFrame.y,
        w = windowFrame.w,
        h = windowFrame.h
    },
    0)
end

function resizeInDirection(window, directionX, directionY)
    local windowFrame = window:frame()
    local nearestPosition = grid.getNearestPosition(window)
    local nearestSize = grid.getNearestSize(window)
    local nearestFrame = grid.cellFrame(
        nearestPosition.x,
        nearestPosition.y,
        nearestPosition.x + nearestSize.w - 1,
        nearestPosition.y + nearestSize.h - 1
    )

    if directionX > 0 then
        nearestSize.w = nearestSize.w + 1
    elseif directionX < 0 then
        if nearestFrame.w == windowFrame.w then
            nearestSize.w = nearestSize.w - 1
        end
    end

    if directionY > 0 then
        nearestSize.h = nearestSize.h + 1
    elseif directionY < 0 then
        if nearestFrame.h == windowFrame.h then
            nearestSize.h = nearestSize.h - 1
        end
    end

    nearestFrame = grid.cellFrame(
        range(1, nearestPosition.x, grid.xLength()),
        range(1, nearestPosition.y, grid.yLength()),
        range(1, nearestPosition.x + nearestSize.w - 1, grid.xLength()),
        range(1, nearestPosition.y + nearestSize.h - 1, grid.yLength())
    )
    window:setFrame({
        x = windowFrame.x,
        y = windowFrame.y,
        w = nearestFrame.w,
        h = nearestFrame.h
    },
    0)
end

function setWindow(window, startX, startY, endX, endY)
    local cellFrame = grid.cellFrame(startX, startY, endX, endY)
    window:setFrame({
        x = cellFrame.x,
        y = cellFrame.y,
        w = cellFrame.w,
        h = cellFrame.h
    },
    0)
end

function setWindowByBlock(window, startX, startY, endX, endY)
    setWindow(
        window,
        (startX - 1) * grid.xBlockLength() + 1,
        (startY - 1) * grid.yBlockLength() + 1,
        endX * grid.xBlockLength(),
        endY * grid.yBlockLength()
    )
end

function toggleMaximize(window)
    local maximizedFrame = grid.cellFrame(1, 1, grid.xLength(), grid.yLength())
    local windowId = window:id()
    local windowFrame = window:frame()

    if maximizedWindows[windowId] then
        window:setFrame(maximizedWindows[windowId], 0)
        maximizedWindows[windowId] = nil
    else
        maximizedWindows[windowId] = {
            x = windowFrame.x,
            y = windowFrame.y,
            w = windowFrame.w,
            h = windowFrame.h,
        }
        setWindow(window, 1, 1, grid.xLength(), grid.yLength())
    end
end

-- Canvas

local color = '#F29F05'
local selectorRadius = 6
local overlayLabelOffset = 12
local overlayLabelSize = 24
local overlayLabelRadius = 3
local overlayTextAdjustment = 1

function drawSelector(window, selector)
    local windowFrame = window:frame()

    element = {
        type = 'rectangle',
        action = 'fill',
        frame = windowFrame.table,
        roundedRectRadii = { xRadius = selectorRadius, yRadius = selectorRadius },
        fillColor = hex2table(color, 0.4)
    }

    if selector == nil then
        selector = hs.canvas.new(getScreenFrame())
        selector:level('floating')
        selector:appendElements(element)
    else
        selector:replaceElements(element)
    end

    return selector
end

function drawOverlay()
    local screenFrame = getScreenFrame()
    local overlay = hs.canvas.new(screenFrame)
    overlay:level('overlay')
    overlay:appendElements({
        type = 'rectangle',
        action = 'fill',
        fillColor = { black = 1.0, alpha = 0.35 }
    })

    -- Grid Lines
    local majorLine = {
        strokeDashPattern = {},
        strokeColor = hex2table(color),
        strokeWidth = 2
    }
    local minorLine = {
        strokeDashPattern = {12, 4},
        strokeColor = hex2table(color, 1),
        strokeWidth = 0.5
    }

    for i = 2, grid.xLength() do
        local cellFrame = grid.cellFrame(i, 1)

        element = {
            type = 'segments',
            action = 'stroke',
            coordinates = {
                { x = cellFrame.x, y = 0 },
                { x = cellFrame.x, y = screenFrame.h }
            }
        }

        if cycleNumbers(i, grid.xBlockLength()) == 1 then
            for k, v in pairs(majorLine) do element[k] = v end
        else
            for k, v in pairs(minorLine) do element[k] = v end
        end
        overlay:appendElements(element)
    end

    for j = 2, grid.yLength() do
        local cellFrame = grid.cellFrame(1, j)

        element = {
            type = 'segments',
            action = 'stroke',
            coordinates = {
                { x = 0, y = cellFrame.y },
                { x = screenFrame.w, y = cellFrame.y }
            }
        }

        if cycleNumbers(j, grid.yBlockLength()) == 1 then
            for k, v in pairs(majorLine) do element[k] = v end
        else
            for k, v in pairs(minorLine) do element[k] = v end
        end
        overlay:appendElements(element)
    end

    -- Block Labels
    for i = 1, grid.xLength(), grid.xBlockLength() do
        for j = 1, grid.yLength(), grid.yBlockLength() do
            local cellFrame = grid.cellFrame(i, j)
            local labelFrame = {
                x = cellFrame.x + overlayLabelOffset,
                y = cellFrame.y + overlayLabelOffset,
                w = overlayLabelSize,
                h = overlayLabelSize
            }
            overlay:appendElements(
                {
                    type = 'rectangle',
                    action = 'fill',
                    frame = labelFrame,
                    roundedRectRadii = { xRadius = overlayLabelRadius, yRadius = overlayLabelRadius },
                    fillColor = hex2table(color)
                },
                {
                    type = 'text',
                    action = 'fill',
                    frame = {
                        x = cellFrame.x + overlayLabelOffset,
                        y = cellFrame.y + overlayLabelOffset + overlayTextAdjustment,
                        w = overlayLabelSize,
                        h = overlayLabelSize - 2 * overlayTextAdjustment
                    },
                    text = grid.mapFromIndex(i, j),
                    textFont = 'SF Pro Text Bold',
                    textSize = 14.0,
                    textAlignment = 'center'
                }
            )
        end
    end

    return overlay
end

function drawPane(pane, startX, startY, endX, endY)
    endX = endX or startX
    endY = endY or startY

    local cellFrame = grid.cellFrame(
        (startX - 1) * grid.xBlockLength() + 1,
        (startY - 1) * grid.yBlockLength() + 1,
        endX * grid.xBlockLength(),
        endY * grid.yBlockLength()
    )
    local element = {
        type = 'rectangle',
        action = 'fill',
        frame = cellFrame.table,
        fillColor = hex2table(color, 0.35),
    }

    if pane == nil then
        pane = hs.canvas.new(getScreenFrame())
        pane:level('overlay')
        pane:appendElements(element)
    else
        pane:replaceElements(element)
    end

    return pane
end

-- Hotkeys

local modal = hs.hotkey.modal.new({'ctrl', 'alt', 'cmd'}, 'space', nil)
local currentOverlay = nil
local currentSelector = nil
local currentPane = nil
local selectedBlock = nil

local directionMap = {
    left  = { directionX = -1, directionY =  0 },
    h     = { directionX = -1, directionY =  0 },
    right = { directionX =  1, directionY =  0 },
    l     = { directionX =  1, directionY =  0 },
    up    = { directionX =  0, directionY = -1 },
    k     = { directionX =  0, directionY = -1 },
    down  = { directionX =  0, directionY =  1 },
    j     = { directionX =  0, directionY =  1 }
}

function resetCanvas(reenterCanvas, enterTime, exitTime)
    reenterCanvas = reenterCanvas or false
    enterTime = enterTime or 0
    exitTime = exitTime or 0

    if currentOverlay then
        currentOverlay:delete(exitTime)
        currentOverlay = nil
    end

    if currentSelector then
        currentSelector:delete(exitTime)
        currentSelector = nil
    end

    if reenterCanvas then
        currentOverlay = drawOverlay():show(enterTime)
        currentSelector = drawSelector(windowOrder[windowIndex]):show(enterTime)
    end
end

function resetPane(animationTime)
    animationTime = animationTime or 0
    selectedBlock = nil
    if currentPane then
        currentPane:delete(animationTime)
        currentPane = nil
    end
end

function modal:entered()
    windowOrder = hs.window.orderedWindows()
    windowIndex = next(windowOrder)
    cycleWindow(0)

    resetCanvas(true, 0.1)
    resetPane()
end

function modal:exited()
    resetCanvas(false, 0, 0.15)
    resetPane()
end

local fn = function(direction)
    return function()
        resetPane()
        drawSelector(cycleWindow(direction), currentSelector):show()
    end
end
modal:bind({}, 'tab', nil, fn(1), repeatDelay(fn(1)))
modal:bind({'shift'}, 'tab', nil, fn(-1), repeatDelay(fn(-1)))

for k, v in pairs(directionMap) do
    local fn = function(moveOrResize)
        return function()
            resetPane()
            moveOrResize(windowOrder[windowIndex], v.directionX, v.directionY)
            drawSelector(windowOrder[windowIndex], currentSelector)
        end
    end
    modal:bind({}, k, nil, fn(moveInDirection), repeatDelay(fn(moveInDirection)))
    modal:bind({'shift'}, k, nil, fn(resizeInDirection), repeatDelay(fn(resizeInDirection)))
end

for i = 1, grid.xLength() / grid.xBlockLength() do
    for j = 1, grid.yLength() / grid.yBlockLength() do
        modal:bind({}, grid.map[j][i], function()
            local window = windowOrder[windowIndex]

            if selectedBlock == nil then
                selectedBlock = {x = i, y = j}
                currentPane = drawPane(currentPane, i, j, i, j):show()
            else
                endX = math.max(i, selectedBlock.x)
                endY = math.max(j, selectedBlock.y)
                setWindowByBlock(
                    window,
                    selectedBlock.x,
                    selectedBlock.y,
                    endX,
                    endY
                )
                drawSelector(window, currentSelector)
                drawPane(currentPane, selectedBlock.x, selectedBlock.y, endX, endY):show()
                resetPane(1.5)
            end
        end)
    end
end

modal:bind({}, '-', nil, function()
    grid.currentBlockSize = range(1, grid.currentBlockSize - 1, #grid.xBlockSizes)
    resetCanvas(true, 0)
end)
modal:bind({}, '=', nil, function()
    grid.currentBlockSize = range(1, grid.currentBlockSize + 1, #grid.yBlockSizes)
    resetCanvas(true, 0)
end)

modal:bind({}, 'space', nil, function()
    resetPane()
    toggleMaximize(windowOrder[windowIndex])
    drawSelector(windowOrder[windowIndex], currentSelector):show()
end)

modal:bind({}, 'escape', nil, function()
    modal:exit()
end)

modal:bind({}, 'return', nil, function()
    modal:exit()
end)

-- Scrolling

local indicatorRadius = 30
local indicatorArrowHalfWidth = 15
local indicatorArrowHeight = 35
local indicatorArrowOffset = 5

function drawScrollIndicator(scrollIndicator, x, y, directionX, directionY, scrollWeight)
    directionX = directionX or 0
    directionY = directionY or 0
    scrollWeight = scrollWeight and scrollWeight / 2 + 0.5 or 0.5

    local coordinates = {
        { x = -indicatorArrowHalfWidth * scrollWeight, y = 0 },
        { x = 0, y = -indicatorArrowHeight * scrollWeight },
        { x = indicatorArrowHalfWidth * scrollWeight, y = 0 },
        { x = 0, y = -indicatorArrowOffset },
        { x = -indicatorArrowHalfWidth * scrollWeight, y = 0 },
    }

    if not scrollIndicator then
        scrollIndicator = hs.canvas.new(hs.geometry.rect(
            x - indicatorRadius,
            y - indicatorRadius,
            2 * indicatorRadius,
            2 * indicatorRadius
        )):transformation(
            hs.canvas.matrix.translate(indicatorRadius, indicatorRadius)
        )

        scrollIndicator:level('overlay')
        scrollIndicator:appendElements(
            {
                type = 'circle',
                action = 'strokeAndFill',
                fillColor = { black = 1.0 },
                radius = 3,
                center = { x = 0, y = 0 },
                strokeWidth = 1,
                strokeColor = { white = 1 },
                shadow = {
                    blurRadius = 2,
                    alpha = 0.05,
                    offset = { h = -0.5, w = 0 }
                },
                withShadow = true
            },
            {
                type = 'segments',
                action = 'strokeAndFill',
                fillColor = { black = 1.0 },
                coordinates = coordinates,
                strokeWidth = 1,
                strokeColor = { white = 1 },
                shadow = {
                    blurRadius = 2,
                    alpha = 0.05,
                    offset = { h = -0.5, w = 0 }
                },
                withShadow = true
            }
        )
    else
        local indicatorElementIndex = 2
        local angle = math.deg(math.atan(directionY - y, directionX - x)) + 90
        scrollIndicator[indicatorElementIndex].coordinates = coordinates
        scrollIndicator:rotateElement(2, angle, { x = 0, y = 0 })
    end

    return scrollIndicator
end

local events = require('hs.eventtap.event')

local expectedButtonNumber = 2
local dragThresholdMs = 150
local maxScrollRate = 30

local isToggled = false
local initialScrollPosition = nil
local initialScrollTimestamp = nil
local xScrollRate = 0
local yScrollRate = 0

local scrollIndicator = nil


function calculateScrollRate(initial, current)
    local direction = initial - current > 0 and 1 or -1
    return direction * math.min(math.floor(math.abs(initial - current) * 0.025), maxScrollRate)
end

function calculateScrollWeight(xScrollRate, yScrollRate)
    return math.min(1, math.sqrt(xScrollRate ^ 2 + yScrollRate ^ 2) / maxScrollRate)
end

function resetScrollerState()
    if scrollIndicator then
        scrollIndicator:delete()
        scrollIndicator = nil
    end

    initialScrollPosition = nil
    initialScrollTimestamp = nil
    xScrollRate = 0
    yScrollRate = 0
end

middleClickListener = hs.eventtap.new(
    {
        events.types.mouseMoved,
        events.types.otherMouseDown,
        events.types.otherMouseDragged,
        events.types.otherMouseUp
    },
    function(event)
        local eventType = event:getType()
        if eventType ~= events.types.mouseMoved and event:getProperty(events.properties.mouseEventButtonNumber) ~= expectedButtonNumber then
            return false, {}
        end

        if eventType == events.types.otherMouseDown then
            if isToggled then
                resetScrollerState()
            else
                -- We don't yet know whether it's a drag or a toggle, but either way we need to set the variables below.
                initialScrollPosition = event:location()
                initialScrollTimestamp = event:timestamp()
                scrollIndicator = drawScrollIndicator(scrollIndicator, initialScrollPosition.x, initialScrollPosition.y):show()

                hs.timer.doAfter(ms2s(dragThresholdMs), function()
                    if not isToggled then
                        events.newScrollEvent({xScrollRate, yScrollRate}, {}, 'pixel'):post()
                    end
                end)
            end

            return true, {}
        elseif eventType == events.types.otherMouseUp then
            if initialScrollTimestamp and ns2ms(event:timestamp() - initialScrollTimestamp) > dragThresholdMs then
                resetScrollerState()
            else
                if not isToggled then
                    isToggled = true
                    events.newScrollEvent({xScrollRate, yScrollRate}, {}, 'pixel'):post()
                else
                    isToggled = false
                end
            end

            return false, {}
        else
            if eventType == events.types.mouseMoved and not isToggled then
                return false, {}
            end

            if eventType == events.types.otherMouseDragged and isToggled then
                return false, {}
            end

            currentMousePosition = event:location()
            xScrollRate = calculateScrollRate(initialScrollPosition.x, currentMousePosition.x)
            yScrollRate = calculateScrollRate(initialScrollPosition.y, currentMousePosition.y)
            
            drawScrollIndicator(
                scrollIndicator,
                initialScrollPosition.x,
                initialScrollPosition.y,
                currentMousePosition.x,
                currentMousePosition.y,
                calculateScrollWeight(xScrollRate, yScrollRate)
            ):show()
            return true, {}
        end
    end
)

scrollListener = hs.eventtap.new(
    {
        events.types.scrollWheel
    },
    function(event)
        if not initialScrollPosition then
            return
        end

        events.newScrollEvent({xScrollRate, yScrollRate}, {}, 'pixel'):post()
        
        return false, {}
    end
)

middleClickListener:start()
scrollListener:start()