-- A global variable for the sub-key Hyper Mode
k = hs.hotkey.modal.new({}, 'F18')

--キー設定ここから
xcmd = 1
xalt = 2
xshift = 4
xctrl = 8

myRemap = {
 { 'h', {}, 'LEFT'},
 { 'j', {}, 'DOWN'},
 { 'k', {}, 'UP'},
 { 'l', {}, 'RIGHT'},
 { 'a', {'cmd'}, 'LEFT'},  -- beginning of line
 { 'e', {'cmd'}, 'RIGHT'}, -- end of line
 { 'd', {}, 'forwarddelete'},
 { 'x', {}, 'delete'}
}

exRemap = {}
for cnt=0, 15, 1 do
    mmod = 0
    mt = {}
    if (cnt & xcmd) ~= 0 then mmod = mmod | xcmd table.insert(mt,'cmd') end
    if (cnt & xalt) ~= 0 then mmod = mmod | xalt table.insert(mt,'alt') end 
    if (cnt & xshift) ~= 0 then mmod = mmod | xshift table.insert(mt,'shift') end
    if (cnt & xctrl) ~= 0 then mmod = mmod | xctrl table.insert(mt,'ctrl') end

    for i,bnd in ipairs(myRemap) do
        mmod2 = 0
        for j,lmod in ipairs(bnd[2]) do
            mmod2 = 0
            if lmod == 'cmd' then mmod2 = mmod2 | xcmd end
            if lmod == 'alt' then mmod2 = mmod2 | xalt end
            if lmod == 'shift' then mmod2 = mmod2 | xshift end
            if lmod == 'ctrl' then mmod2 = mmod2 | xctrl end
        end
        mmt = {}
        mmod3 = mmod | mmod2
        
        if (mmod3 & xcmd) ~= 0 then table.insert(mmt,'cmd') end
        if (mmod3 & xalt) ~= 0 then table.insert(mmt,'alt') end 
        if (mmod3 & xshift) ~= 0 then table.insert(mmt,'shift') end
        if (mmod3 & xctrl) ~= 0 then table.insert(mmt,'ctrl') end

        table.insert(exRemap,{mt,bnd[1],mmt,string.lower(bnd[3])})
    end
end

local flagKey = true
for i,bnd in ipairs(exRemap) do
    k:bind(
            bnd[1],
            bnd[2],
            function()
                hs.eventtap.event.newKeyEvent(bnd[3], bnd[4], true):post()
            end,
            function()
                hs.eventtap.event.newKeyEvent(bnd[3], bnd[4], false):post()
                flagKey = true
            end,
            function()
                if flagKey then
                    flagKey = false
                    hs.eventtap.event.newKeyEvent(bnd[3], bnd[4], true):post()
                    hs.timer.usleep(30000)
                    hs.eventtap.event.newKeyEvent(bnd[3], bnd[4], false):post()
                    flagKey = true
                end
            end )
end
--キー設定ここまで


--マウス設定ここから
pressedMBtn = nil
mouseTimer = nil
clickCount = 1
preMButton = nil
clickTimer = nil


function loopFunc()
    return function()
        if pressedMBtn == "left" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDragged"], hs.mouse.getAbsolutePosition()):post()
            mouseTimer = hs.timer.doAfter(0.02, loopFunc())
        elseif pressedMBtn == "right" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["rightMouseDragged"], hs.mouse.getAbsolutePosition()):post()
            mouseTimer = hs.timer.doAfter(0.02, loopFunc())
        elseif pressedMBtn == "middle" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["middleMouseDragged"], hs.mouse.getAbsolutePosition()):post()
            mouseTimer = hs.timer.doAfter(0.02, loopFunc())
        else
        end
    end
end


function pressMouseButton( fmods, button )
    return function()
        pressFlag = false
        if preMBtn == button then
            clickCount = clickCount + 1
            if clickCount > 3 then
                clickCount = 3
            end
        end
        
        preMBtn = button
        if button == "left" then
            --hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], hs.mouse.getAbsolutePosition()):setProperty(hs.eventtap.event.properties.mouseEventClickState, clickCount):post()
            me = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], hs.mouse.getAbsolutePosition())
            me:setProperty(hs.eventtap.event.properties.mouseEventClickState, clickCount)  
            me:post()
            pressFlag = true  
        elseif button == "right" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["rightMouseDown"], hs.mouse.getAbsolutePosition()):post()
            pressFlag = true
        elseif button == "middle" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["middleMouseDown"], hs.mouse.getAbsolutePosition()):post()
            pressFlag = true
        else
        end
        
        if pressedMBtn == nil and pressFlag then
            pressedMBtn = button
            
            mouseTimer = hs.timer.doAfter(0.016, loopFunc())
            if clickTimer == nil then
                clickTimer = hs.timer.doAfter(0.5, function() clickCount = 1 preMBtn = nil clickTimer = nil end)
            end
            
            
        end
        
    end
end

function releaseMouseButton( button )
    return function()
        if button == "left" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], hs.mouse.getAbsolutePosition()):post()
        elseif button == "right" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["rightMouseUp"], hs.mouse.getAbsolutePosition()):post()
        elseif button == "middle" then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["middleMouseUp"], hs.mouse.getAbsolutePosition()):post()
        else
        end
        if pressedMBtn == button then
                    pressedMBtn = nil
        end
    end
end

function mouseScroll(fmods, direction )
    return function()
        if direction == "down" then
            hs.eventtap.event.newScrollEvent({0,-3}, fmods, "line"):post()
            hs.timer.usleep(30000)
        elseif direction == "up" then
            hs.eventtap.event.newScrollEvent({0,3}, fmods, "line"):post()
            hs.timer.usleep(30000)
        elseif direction == "left" then
            hs.eventtap.event.newScrollEvent({1,0}, fmods, "line"):post()
            hs.timer.usleep(30000)
        elseif direction == "right" then
            hs.eventtap.event.newScrollEvent({-1,0}, fmods, "line"):post()
            hs.timer.usleep(30000)
        elseif direction == "release" then
        else
        end
    end
end

mouseMods = {}
for cnt=0, 15, 1 do
    mmod = 0
    mt = {}
    if (cnt & xcmd) ~= 0 then mmod = mmod | xcmd table.insert(mt,'cmd') end
    if (cnt & xalt) ~= 0 then mmod = mmod | xalt table.insert(mt,'alt') end 
    if (cnt & xshift) ~= 0 then mmod = mmod | xshift table.insert(mt,'shift') end
    if (cnt & xctrl) ~= 0 then mmod = mmod | xctrl table.insert(mt,'ctrl') end

    table.insert(mouseMods, mt)
end

for i,bnd in ipairs(mouseMods) do
    k:bind(bnd, 'f', pressMouseButton(bnd, "left"), releaseMouseButton("left"))
    k:bind(bnd, 'v', pressMouseButton(bnd, "right"), releaseMouseButton("right"))
    k:bind(bnd, 'g', pressMouseButton(bnd, "middle"), releaseMouseButton("middle"))
    k:bind(bnd, 'r', mouseScroll(bnd, "down"), mouseScroll(bnd, "realease"),mouseScroll(bnd, "down"))
    k:bind(bnd, '4', mouseScroll(bnd, "up"), mouseScroll(bnd, "realease"),mouseScroll(bnd, "up"))
    k:bind(bnd, '5', mouseScroll(bnd, "left"), mouseScroll(bnd, "realease"),mouseScroll(bnd, "left"))
    k:bind(bnd, 't', mouseScroll(bnd, "right"), mouseScroll(bnd, "realease"),mouseScroll(bnd, "right"))
end
--マウス設定ここまで


--ハイパーキー設定ここから
-- Enter Hyper Mode when F19 (left control) is pressed
pressedF19 = function()
  k:enter()
end

-- Leave Hyper Mode when F19 (left control) is pressed,
--   send ESCAPE if no other keys are pressed.
releasedF19 = function()
   k:exit()
end

--mouseModsをマウス設定から借用
-- Bind the Hyper key
for i,bnd in ipairs(mouseMods) do
    f19 = hs.hotkey.bind(bnd, 'F19', pressedF19, releasedF19)
end
--ハイパーキー設定ここまで



--IME設定ここから
local qStartTime = 0.0
local qDuration = 0.5
local IME = true
hs.hotkey.bind({}, 'F17',
    function()
        qStartTime = hs.timer.secondsSinceEpoch()
        IME = true
    end,
    function()
        local qEndTime = hs.timer.secondsSinceEpoch()
        local duration = qEndTime - qStartTime
        if duration < qDuration then
            hs.eventtap.event.newKeyEvent({}, 102, true):post()
            hs.timer.usleep(200000)
            hs.eventtap.event.newKeyEvent({}, 102, false):post()
            hs.alert.show("英")
            hs.timer.doAfter(0.02, function() hs.alert.closeAll(3) end)
            IME = false
        end
    end,
    function()
        local qEndTime = hs.timer.secondsSinceEpoch()
        local duration = qEndTime - qStartTime
        if duration >= qDuration and IME then
            hs.eventtap.event.newKeyEvent({}, 104, true):post()
            hs.timer.usleep(200000)
            hs.eventtap.event.newKeyEvent({}, 104, false):post()
            hs.alert.show("あ")
            hs.timer.doAfter(0.02, function() hs.alert.closeAll(3) end)
            IME = false
        end
    end
)
--IME設定ここまで