keymap = {
    escape=53, f1=122, f2=120, f3=99, f4=118, f5=96, f6=97, f7=98, f8=100, f9=101, f10=109, f11=103, f12=111,
    n1=18, n2=19, n3=20, n4=21, n5=23, n6=22, n7=26, n8=28, n9=25, n0=29, minus=27, hut=24, en=93, delete=51, fowardDel=117,
    tab=48, q=12, w=13, e=14, r=15, t=17, y=16, u=32, i=34, o=31, p=35, atmark=33, kakko=30,
    a=0, s=1, d=2, f=3, g=5, h=4, j=38, k=40, l=37, semicolon=41, colon=39, kakkotoji=42, enter=36,
    z=6, x=7, c=8, v=9, b=11, n=45, m=46, commma=43, dot=47, slash=44, haifun=94,
    space=49, left=123, up=126, down=125, right=124, home=115, pageUp=126, pageDown=121, kend=119, eisuu=102, kana=104
}

remapKey = {
    { 'h', {}, 'left'},
    { 'j', {}, 'down'},
    { 'k', {}, 'up'},
    { 'l', {}, 'right'},
    { 'a', {'cmd'}, 'left'},  -- beginning of line
    { 'e', {'cmd'}, 'right'}, -- end of line
    { 'd', {}, 'fowardDel'},
    { 'x', {}, 'delete'}
}


function btToMods(bef, afr, afrT)
-- bef getFlags() afr getFlags() afrT table
    for key, val in pairs(bef) do
        afr[key] = val
    end
    if afr['cmd'] then table.insert(afrT, 'cmd') end
    if afr['alt'] then  table.insert(afrT, 'alt') end
    if afr['shift'] then table.insert(afrT, 'shift') end
    if afr['ctrl'] then table.insert(afrT, 'ctrl') end
    if afr['fn'] then table.insert(afrT, 'fn') end
end

function simpleRemap( fMods, fKeyCode, fTable )
    for i, ival in ipairs(fTable) do
        if fKeyCode == keymap[ival[1]] then
            local ffMods = {}
            for j, jval in ipairs(ival[2]) do
                ffMods[jval] = true
            end
            local pMods = {}
            btToMods(fMods, ffMods, pMods)
            
            hs.eventtap.event.newKeyEvent(pMods, keymap[ival[3]], true):post()
            hs.timer.usleep(12000)
            hs.eventtap.event.newKeyEvent(pMods, keymap[ival[3]], false):post()      
            return true
        end
    end
    return false
end


-- local keyCommon = {}
-- keyCommon:new = function(keyLabel)
--                     local obj = {}
--                     obj.keyLabel = keyLabel
--                     obj.keyCode = keymap[keyLabel]
--                     --0xf->keyDown, 0xf0->keyUp, 0xf00->keyRepeat
--                     obj.keyState =  0x0                    
--                     obj.rawModBit = 0x0
--                     obj:analyzeMod = function( event )
--                                         local modTbl = event:getFlags()
--                                         if modTbl["cmd"] then self.rawModBit = bit32.bor(self.rawModBit, 0xf) end
--                                         if modTbl["alt"] then self.rawModBit = bit32.bor(self.rawModBit, 0xf0) end
--                                         if modTbl["shift"] then self.rawModBit = bit32.bor(self.rawModBit,0xf00) end
--                                         if modTbl["ctrl"] then self.rawModBit = bit32.bor(self.rawModBit,0xf000) end
--                                         if modTbl["fn"] then self.rawModBit = bit32.bor(self.rawModBit, 0xf0000) end
--                                     end
                    
--                     obj:update =    function( event )
--                                         if hs.eventtap.event.types.keyDown == event:getKeyCode() then

--                                         elseif hs.eventtap.event.types.keyUp == event:getKeyCode() then

--                                         else
--                                             return false
--                                         end
--                                     end
--                     return obj
--                 end

pressLeft = false
pressRight = false
pressMiddle = false
clickCount = 0
clickPos = 0
pClickCount = 0
dragStart = false
qDown = 0
qUp = 0

function keyPressToMouse( fType, fMods, fKeyCode)
    local pMods = {}
    if keymap["f"] == fKeyCode then
        if "keyup" == fType then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], hs.mouse.getAbsolutePosition()):setProperty(hs.eventtap.event.properties.mouseEventClickState, pClickCount):post()
            pressLeft = false
            dragStart = false
            qUp = hs.timer.secondsSinceEpoch()
        elseif pressLeft then
            clickCount = 0
        --     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDragged"], hs.mouse.getAbsolutePosition()):post()
        elseif "keydown" == fType then
            qDown = hs.timer.secondsSinceEpoch()
            if clickCount > 0 and (qDown - qUp) > 0.2 then
                clickCount = 0
            end
            clickCount = clickCount + 1
            clickPos = hs.mouse.getAbsolutePosition()
            local clm = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], clickPos, fMods)
            clm:setProperty(hs.eventtap.event.properties.mouseEventClickState, clickCount)
            clm:post()
            pClickCount = clickCount
            pressLeft = true
            --hs.timer.doAfter(0.02, function() dragMouse(pos) end)
        end
        return true
    elseif keymap["g"] == fKeyCode then
        if "keyup" == fType then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["middleMouseUp"], hs.mouse.getAbsolutePosition()):post()
            pressMiddle = false
        elseif pressMiddle then
        --     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["middleMouseDragged"], hs.mouse.getAbsolutePosition()):post()
        elseif "keydown" == fType then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["middleMouseDown"], hs.mouse.getAbsolutePosition()):post()
            pressMiddle = true
        end
        return true
    elseif keymap["v"] == fKeyCode then
        if "keyup" == fType then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["rightMouseUp"], hs.mouse.getAbsolutePosition()):post()
            pressRight = false
        elseif pressRight then
        --     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["rightMouseDragged"], hs.mouse.getAbsolutePosition()):post()
        elseif "keydown" == fType then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["rightMouseDown"], hs.mouse.getAbsolutePosition()):post()
            pressRight = true
        end
        return true
    elseif "keydown" == fType then
        if keymap["r"] == fKeyCode then
            hs.eventtap.event.newScrollEvent({0,-3}, {}, "line"):post()
            hs.timer.usleep(12000)
            return true
        elseif keymap["n4"] == fKeyCode then
            hs.eventtap.event.newScrollEvent({0,3}, {}, "line"):post()
            hs.timer.usleep(12000)
            return true
        elseif keymap["t"] == fKeyCode then
            hs.eventtap.event.newScrollEvent({-1,0}, {}, "line"):post()
            hs.timer.usleep(12000)
            return true
        elseif keymap["n5"] == fKeyCode then
            hs.eventtap.event.newScrollEvent({1,0}, {}, "line"):post()
            hs.timer.usleep(12000)
            return true
        end
    end
    return false
end

local pressedIME = 0
local pXY = { x=-1, y=-1 }
local nXY = {}
local run = true
pressedHyper = false
eventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp, hs.eventtap.event.types.mouseMoved}, 
    function(e)
        --trueを返すと乗っ取る
        --falseを返すと通過する
        local keyCode = e:getKeyCode()
        local keyDown = (e:getType() == hs.eventtap.event.types.keyDown)
        local keyUp = (e:getType() == hs.eventtap.event.types.keyUp)
        local mouseMv = (e:getType() == hs.eventtap.event.types.mouseMoved)
        if pressedHyper then
            if keyCode == 0x72 then
                if keyUp then
                    --hs.alert.show("OFF")
                    pressedHyper = false
                    if pressLeft then
                        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], hs.mouse.getAbsolutePosition()):post()
                        pressLeft = false
                        dragStart = false
                    end
                    if pressRight then
                        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["rightMouseUp"], hs.mouse.getAbsolutePosition()):post()
                        pressRight = false
                    end
                    if pressMiddle then
                        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["middleMouseUp"], hs.mouse.getAbsolutePosition()):post()
                        pressMiddle = false
                    end
                end
                return true
            end

            local mods = e:getFlags()
            if keyDown then
                if keyPressToMouse("keydown", mods, keyCode) then return true end
                if simpleRemap(mods, keyCode, remapKey) then return true end
            end
            if keyUp then
                if keyPressToMouse("keyup", mods, keyCode) then return true end
            end
            if mouseMv then
                if pressLeft then
                    local lpos = hs.mouse.getAbsolutePosition()
                    if math.abs(clickPos["x"]-lpos["x"])>5 or math.abs(clickPos["y"]-lpos["y"])>5 then
                        if not dragStart then
                            dragStart = true
                            local llpos = { x = clickPos["x"]-5, y = clickPos["y"]-5}
                            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], clickPos):setProperty(hs.eventtap.event.properties.mouseEventClickState, pClickCount):post()
                            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], clickPos, mods):setProperty(hs.eventtap.event.properties.mouseEventClickState, pClickCount):post()
                            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDragged"], llpos, mods):setProperty(hs.eventtap.event.properties.mouseEventClickState, pClickCount):post()
                        end
                    end
                    if dragStart and run then
                        run = false
                        hs.timer.doAfter(0.02, function() run = true end)
                        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDragged"], lpos, mods):setProperty(hs.eventtap.event.properties.mouseEventClickState, pClickCount):post()
                    end
                end          
            end
        else
            if keyCode == 0x72 then
                if keyDown then
                    --hs.alert.show("ON")
                    pressedHyper = true

                    return true
                end
            end
        end

        --IME設定ここから
        if keyCode == 0x68 then

            if keyDown then
                pressedIME = pressedIME + 1
                if pressedIME == 2 then
                    -- hs.eventtap.event.newKeyEvent({}, 104, true):post()
                    -- hs.timer.usleep(200000)
                    -- hs.eventtap.event.newKeyEvent({}, 104, false):post()
                    hs.alert.show("あ")
                    hs.timer.doAfter(0.1, function() hs.alert.closeAll(3) end)
                    return false --そのまま、かなキーのダウンを送る
                end
            end

            if keyUp then
                if pressedIME == 1 then
                    hs.eventtap.event.newKeyEvent({}, 102, true):post()
                    hs.timer.usleep(200000)
                    hs.eventtap.event.newKeyEvent({}, 102, false):post()
                    hs.alert.show("英")
                    hs.timer.doAfter(0.1, function() hs.alert.closeAll(3) end)
                    pressedIME = 0
                elseif pressedIME > 1 then
                    pressedIME = 0
                    return false --そのまま、かなキーのアップを送る
                end
            end

            return true
        end
        --IME設定ここまで

        return false
    end)

eventtap:start()

-- Command + Ctrl + ↑ : フルスクリーン
hs.hotkey.bind("alt", keymap["up"], function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h

    win:setFrame(f)
end)

-- Command + Ctrl + ← : ウィンドウ左寄せ
hs.hotkey.bind("alt", keymap["left"], function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h

    win:setFrame(f)
end)

-- Command + Ctrl + ← : ウィンドウ右寄せ
hs.hotkey.bind("alt", keymap["right"], function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h

    win:setFrame(f)
end)