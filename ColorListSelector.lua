print(...)
local thisFile = "ColorListSelector.lua"
print("[" .. thisFile .. "] loaded/running.")

-- 8/26/22 -- 
local Conf = require('ColorListConfig') -- get all the user 'Config' data for the colors & buttons
-- Import all the User Config data from ColorListConfig (and create local  shortcut names  to use them)
local buttonHeight = Conf.buttonHeight -- shortcut name
local buttonSpacing = Conf.buttonSpacing
local colorList = Conf.colorList
local colorHexList = Conf.colorHexList
local testObjList = Conf.ObjectList -- [] kmk ToDo rename testObjList to ~objectList


local selectedObject = 0 -- integer: the Currently Selected (touched) object number from <-- Conf.ObjectList 
local touchscreen = false -- detect & set this during init


local UIcanvasData = {
    --[[
        The "full screen" of the app (small smartphone size by default) 
        Everything specified in ColorListConfig.lua is drawn on THIS canvas. 
        Normally, you'll probably just want to make this canvas the same dimensions 
        that your overall "app" window is.  It will be drawn on top of your app 
        (but its background is transparent, so your other content shows through.)
    ]]
    width = 640 * 1,
    height = 360 * 1
}
local UIcanvas = {} -- pre-declare the canvas object to be Local. 


local colorsCanvasData = { -- size of the (usually hidden) color picker
    active = false,
    width = 200,
    height = 500, -- this is just an initial value, it's actually calculated in createColorsCanvas()
    speed = 8, -- scroll speed for things like arrow keys
    xPos = 400, -- x position on the app screen
    yPos = 0, -- the y coordinate will change when user scrolls the window
    yStartDr = 0, -- the y position of the canvas at the start of a Drag
}
local colorsCanvas = {} -- pre-declare the canvas object to be Local. 


--[[ ColorListSelector.lua -- Simple Color Picker UI module for Love2D 

    THIS is the 'Library' file... hopefully people can often use it without any 
    modification.  
    The file ColorListConfig.lua is where the user can edit the color list, 
    and any buttons needed to trigger it. 

    These functions provide a pop-up, scrollable, list of colors which can be associated
     with objects on the screen (such as color-select buttons) to bring up the list, 
     then colors are touched to apply them. 

    It is implemented for computer Mouse, and phone Touchscreen (android currently)
    
    How the code works: 
    There is an "app" canvas (where you put your things to be colored, and buttons
    to trigger the color menu/selector.)
    And a "color" selector canvas (tall and narrow, scrollable) 
    The colorsCanvas is scrolled simply by drawing it at different y coordinates
    (most of that tall canvas will be off the top or bottom of the screen.)

    love.draw() -- is pretty simple: 
    it draws the user's app objects to the UIcanvas, then draws the UIcanvas
    to the Love2D app window. 
    and *if* the colorsCanvas is "active", then it also draws the colorsCanvas 
    over the Love2D app window, at its current scrolled y coordinate. 

    The position (y-axis scrolling) of the colorsCanvas (i.e. colorsCanvasData.yPos)
    is updated by the callback love.wheelmoved(x, y)

    love.update() 
    .yPos is also updated in love.update() if an Up/Down key is being held, 
    or if a touchscreen or mouse click is being held down and dragged. 
    love.update() also shows a preview of any color the mouse cursor is 'hovering' over. 

    love.mousepressed() tracks the possible start of a mouse drag action.  and it
    dismisses the color select canvas if the user clicks on a blank part of the screen. 

    love.mousereleased() is perhaps the most fussy bit of logic because it takes
    different actions depending on whether the last user action was a Drag, or 
    a Click, and on a touchscreen, or with a mouse.  
    Since a mouse 'hover' lets a user preview their color choice, we know that 
    a click is their 'decision' so we dismiss the color picker, but a touchscreen
    user can't 'hover', so we regard their click as being a preview try of a color
    and we don't dismiss the picker, until they click off of the color menu. 
    mousereleased() also checkes to see if any other defined screen objects were
    clicked on (specifically, the buttons that call the color picker to appear.)
    

    API: all data and functions are *Local* to this module, *except* for 
    the Love2D Callback functions. 

--]]

--[[ -- CHANGE LOG (read upward)
8/26/22 - moved a bunch of pure-data / config stuff out of here and into ColorListConfig.lua 
cleaned up the Naming of things. 

8/25/22 - changing the name from "Canvas_tests.lua" to ColorListSelector.lua 
and moving it to a separate project folder of its own.  Prior to this it 
was just one of many 'test' files in 'love2d_per_Tests'. 

So far this has not been version conrolled except for a lot of backup saves, like: Canvas_tests (12).lua 
--]]

--[[
    TESTS for using a Canvas as a Scrolling select Menu 
    - draw a tall, thin canvas, with text & color boxes 
    - translate it to make it scroll on the screen 

    For development: create one Big 'desktop' canvas/window,  
    and, within it, a small 'app' canvas, & the color selector canvas. 

    When implementing UI interactions, keep in mind that Mouse "hover" also 
    shows color selection effects instantly... but touchscreens can't do this, 
    so touchscreen clicks may be handled a bit differently. 

    TODO: 
    - modularize this & describe "how to use" it. 
    - give it a proper name (not "Canvas test")
    - ColorListSelector


    - make a separate "Demo" test driver file to use this module remotely... 
    - (then do the same in DragonPaint)


    - make a command to "Random Pick"? 
    - make PgUp/Dn arrows for touchscreen? 
    - (future: make a mini-list sidebar for faster scrolling?)

    - limitation: ~288 colors works on desktop, but results in a canvass that is TOO BIG for android l2d.
    - (figure out what the limit is, and why.)

    - bug: scroll wheel & PgUp/Dn can move the window when it's invisible 
    - put limits to scrolling far off screen. 

    - ?draw a white box on buttons to ack. a selection? 
    - cosmetic improvements (rounded buttons?)
    - make fit more exact for any mobile screen (scale?)

    [] Think about writing this WHOLE thing to be "modular" / a separate, reusable file. 
       and the specific buttons and colors are configured in a 3rd separate file. 

    Also, Publish this as an independent, reusable Module on GitHub. 
]]

-------------------------------------------------------------
--[[  Hex Color stuff -- 
    Todo: maybe support using a simpler TEXT FILE rather than lua format config? 
    one line per line, or comma separators, but
    allow people to use quotes or not, we should parse it either way. 
    Also accept hex value preceeded by # or 0x or neither. 

    If we do specify a simple text file format, it should Optimise for 
    *simplicity* (minimze punctuation, because its easier to remove than to add) 
    and maximize human readablity.  so e.g. it should just be 
    name (single quotes are probably needed here though , values, carriage return
    with spaces as separators. 
    option to reverse order? 
--]]


-- This function was modified from: https://github.com/s-walrus/hex2color/blob/master/hex2color.lua  {kmk}
local function Hex2Color(hex, value)
    --return {tonumber(string.sub(hex, 2, 3), 16)/256, tonumber(string.sub(hex, 4, 5), 16)/256, tonumber(string.sub(hex, 6, 7), 16)/256, value or 1}
    return { tonumber(string.sub(hex, 1, 2), 16) / 256,
        tonumber(string.sub(hex, 3, 4), 16) / 256,
        tonumber(string.sub(hex, 5, 6), 16) / 256, value or 1 }
end


-- meh.. this is ugly but for testing now...
local function convFlatPairsToColorList(flatTable)
    local fixedList = {}

    for i = 1, #flatTable, 2 do -- read from input table, 2 at a time
        --print(flatTable[i], flatTable[i + 1])

        -- convert hex to RGB...
        local rgb = Hex2Color(flatTable[i])

        -- add new entry to end of the fixed format list
        fixedList[#fixedList + 1] = { flatTable[i + 1], rgb[1], rgb[2], rgb[3] }
        local tt = fixedList[#fixedList]
        --print('{' .. tt[1], tt[2], tt[3], tt[4] .. '}')
    end
    return fixedList
end


-------------------------------------------------------------


local lastClick = { -- save x,y info of last initiation of a mouse click or touch (for dragging operations)
    active = false,
    -- x = 0,
    y = 0
}



local function drawAppContent()
    -- just draw any old thing on the screen as a placeholder.  a few rectangles...
    for i in ipairs(testObjList) do
        local x = testObjList[i].x
        local y = testObjList[i].y
        local recWidth = testObjList[i].width
        local recHeight = testObjList[i].height

        love.graphics.setColor(testObjList[i].color)

        local mode = "fill"
        local rx = nil -- 10  -- if you want rounded corners...
        local ry = nil
        local segments = nil -- 5
        love.graphics.rectangle(mode, x, y, recWidth, recHeight, rx, ry, segments)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print(testObjList[i].text, x + 10, y + 10)
    end
end


local function drawUIcanvas() -- called repeatedly
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas(UIcanvas) -- draw to the other canvas...
    --love.graphics.clear(0, 0, 0) -- opaque black
    love.graphics.clear() -- transparent black
    love.graphics.clear(0, 0, 1, 0.2) -- TEST: color (translucent) the sub-canvas to make its boundaries visible for dev.
    drawAppContent()
    love.graphics.setCanvas() -- re-enable drawing to the main screen
    love.graphics.setColor(1, 1, 1)
end


local function createUIcanvas() -- called once
    -- create the  Canvas that represents the entire App (within the development 'desktop' canvas)

    UIcanvas = love.graphics.newCanvas(UIcanvasData.width, UIcanvasData.height)
    drawUIcanvas()
end


local function ccBtoY(button) -- colorsCanvas Button # --> Y coord
    -- basically: button number * height ... with a few tweaks.
    local y = (button - 1) * (buttonHeight + buttonSpacing)
    return y
end


local function ccYtoB(y) -- colorsCanvas Y coord --> Button #
    -- this calculation regards the spacing under the button as part of the button,
    -- so shifting y at least centers it better:
    y = y + (buttonSpacing / 2)

    -- basically: y coordinate / buttonHeight
    local button = (y / (buttonHeight + buttonSpacing)) + 1
    button = math.floor(button)

    if button < 1 then button = 1 end
    if button > #colorList then button = #colorList end
    return button
end


-- draw the CONTENT of the color show/select canvas (this is only done once)
local function drawColorsCanvas()
    local mode = "fill"
    local x = 0
    local y = 0
    local buttonWidth = colorsCanvasData.width
    --local recHeight = 40
    local rx = nil -- 10 -- (if you want rounded corners)
    local ry = nil
    local segments = nil -- 5

    love.graphics.setFont(love.graphics.newFont(buttonHeight - 6))

    -- draw each color sample rectangle and color name
    for i = 1, #colorList do -- (could have used ipairs)
        love.graphics.setColor(colorList[i][2], colorList[i][3], colorList[i][4])

        y = ccBtoY(i) -- get Y coordinate to use for next button
        love.graphics.rectangle(mode, x, y, buttonWidth, buttonHeight, rx, ry, segments)

        love.graphics.setColor(0, 0, 0) -- black text
        -- RGB colors can add up to 3... if they add to <1.5, they're dark, so use whiteish text
        local darkThreshold = 0.7 -- tried values of: 0.7,  1.29,  1.5...
        if (colorList[i][2] + colorList[i][3] + colorList[i][4]) < darkThreshold then
            love.graphics.setColor(.7, .7, .7) -- white(ish) text
        end
        love.graphics.print(colorList[i][1], x + 2, y)
    end
end


local function createColorsCanvas()
    -- Create the movable Canvas to put the color list on.
    -- just create the canvas object, and draw it (once) in the background.
    -- this is a *static* canvas, drawn once at startup.

    local y = ccBtoY(#colorList + 1) -- get Y coordinate of the LAST color button

    colorsCanvasData.height = y -- todo: calculate this from color list size
    colorsCanvas = love.graphics.newCanvas(colorsCanvasData.width, colorsCanvasData.height)

    love.graphics.setCanvas(colorsCanvas) -- draw to the other canvas...
    -- love.graphics.clear(0, 0, 0) -- opaque black
    love.graphics.clear() -- transparent black
    love.graphics.clear(0, 1, 0, 0.2) -- TEST: color (translucent) the sub-canvas to make its boundaries visible for dev.
    drawColorsCanvas()
    love.graphics.setCanvas() -- re-enable drawing to the main screen
end


local function load() -- initialization stuff: this should be called from the main program's love.load()

    -- detect whether the device is using a touchscreen UI
    if love.system.getOS() == "Android" then
        touchscreen = true
    else
        touchscreen = false
    end


    -- convert a Hex-color list format to our expected color list format... 
    colorList = convFlatPairsToColorList(colorHexList)



    -- (manually painting the "app canvas" into the main window gives flexibility to show all 'windows' during development)
    createUIcanvas()

    colorsCanvasData.yPos = buttonSpacing -- initial position, begin just slightly below top of screen.
    createColorsCanvas()
end


local function inColorsCanvas() -- test if mouse/cursor is within the ColorsCanvas
    local isIn = false

    if (love.mouse.getX() > colorsCanvasData.xPos) and
        (love.mouse.getX() < colorsCanvasData.xPos + colorsCanvasData.width) -- (maybe add check of Y coordinate too?)
    then
        isIn = true
    end
    return isIn
end


local function updateObjColor() -- update the color of the currently "selected" object, to the color sample the mouse is over.
    local ccy = love.mouse.getY() - colorsCanvasData.yPos -- cursor y position on the ColorsCanvas
    local buttonNum = ccYtoB(ccy) -- get the ID (index) of the Button the cursor is over
    -- print(love.mouse.getY(), ccy, "button", buttonNum,
    --     colorList[buttonNum][1], colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4])
    local selObj = testObjList[selectedObject]
    selObj.color = { colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4] }
end


local function update(dt) -- this is the whatever functionality needs to happen during "love.update()"
    --[[
        In other callbacks, updates happen from events like Clicks.
        Here, we handle mouse "hover" updates, and
        keys or touches that are "held" down (e.g. dragging)

        Update things like:
        scrolled position of the color picker
        color updates due to mouse hover
    --]]
    if colorsCanvasData.active -- if the color picker is currently displayed...
    then
        -- Up/Down Keys can scroll color picker
        if love.keyboard.isDown("down") then
            colorsCanvasData.yPos = colorsCanvasData.yPos - colorsCanvasData.speed
        elseif love.keyboard.isDown("up") then
            colorsCanvasData.yPos = colorsCanvasData.yPos + colorsCanvasData.speed
        end

        -- -- (This code was used before touchscreen dragging was implemeted)
        -- -- This 'if' causes screen to scroll *steadily* up if you touch the upper part of the screen:
        -- if lastClick.active then
        --     if lastClick.y < 200 then
        --         colorsCanvasData.yPos = colorsCanvasData.yPos - colorsCanvasData.speed
        --     else
        --         colorsCanvasData.yPos = colorsCanvasData.yPos + colorsCanvasData.speed
        --     end
        -- end

        if selectedObject ~= 0 then -- if there is a 'selected' object to color...

            -- if MOUSE is IN the area of an 'active' ColorsCanvas...
            if inColorsCanvas() then

                -- Color update:
                -- do Instant Preview only for pointers that can "hover"
                if touchscreen == false then
                    updateObjColor()
                    --[[ we don't want to do "instant updates" for touchscreens because then it would select
                        a color even on *drags*, and we can't "undo" on "release" because the touch seems 
                        to retain a .getY() value, so it keeps applying the unintended color.
                    --]]
                end


                -- Drag:
                -- if a click/press is 'active' (held down) the ColorsCanvas can be "dragged"
                if lastClick.active then
                    colorsCanvasData.yPos = colorsCanvasData.yStartDr + (love.mouse.getY() - lastClick.y)
                end

            else -- mouse is outside the color selector, so revert to the previous color

                local selObj = testObjList[selectedObject]
                selObj.color = { selObj.color_previous[1], selObj.color_previous[2], selObj.color_previous[3] }
            end
        end
    end -- end checks related to ColorsCanvas

end


local function draw() -- this is the whatever functionality needs to happen during "love.draw()"
    --drawColorsCanvas() -- dev test: test-draw direct to screen

    drawUIcanvas() -- update the main app window, in the background, then draw it:
    love.graphics.draw(UIcanvas, 0, 0)

    -- draw the (static) Color picker canvas (if active)
    if colorsCanvasData.active then
        love.graphics.draw(colorsCanvas, colorsCanvasData.xPos, colorsCanvasData.yPos)
        --love.graphics.draw(colorsCanvas, 400, colorCnvYpos, 0, 0.5, 0.5) -- draw scaled canvas to screen
        --colorsCanvasData.yPos = colorsCanvasData.yPos + 1 -- auto drift
    end

    -- draw a little box to show where a click/touch happened
    -- if lastClick.active then
    --     love.graphics.setColor(.7, .7, 0)
    --     love.graphics.rectangle("fill", lastClick.x, lastClick.y, 10, 10)
    -- end
end


local function mousepressed(x, y, button, istouch, presses) -- keep both mouse & touchscreeen in mind here!

    -- Clicking (anywhere) enables possible dragging operations
    -- Clicking *away* from active areas, dismisses the color picker (and de-selects any objects)
    -- (colors are actually "Selected" elsewhere, in the .update() function, based on x,y hover coordinates)

    --> see .mousereleased() for the following funcitonality:
    -- Releasing on a color-able object, Selects that Object and Activates the color Picker
    -- Releasing a *touch* (mobile screen) does nothing
    -- Releasing a *mouse* click dismisses the color picker (finalizes selection) if it wasn't a "drag"


    -- keeping track of the last mouse-down gets used in *dragging* interactions
    lastClick.active = true
    --lastClick.x = x
    lastClick.y = y
    colorsCanvasData.yStartDr = colorsCanvasData.yPos -- save current Y position of ColorsCanvas, in case it gets dragged


    -- if clicking Outside the color-picker area...
    if not inColorsCanvas() then
        selectedObject = 0 -- de-select current color-able object
        colorsCanvasData.active = false -- dismiss the color picker
    end

end


local function mousereleased(x, y, button, istouch, presses)
    print("mouse at " .. x, y)

    lastClick.active = false -- touch is no longer down... no 'drag' is active.
    -- (we don't want things getting dragged just from mouse movement)

    -- Releasing a *mouse* click dismisses the color picker (finalizes selection) if it wasn't a "drag"
    -- Releasing a *touch* (mobile screen) does nothing (keep the color picker visible)
    -- Clicking (& Releasing) on a color-able object, Selects that Object and Activates the color Picker


    -- if the mouse hasn't been 'dragged' significantly, then something was 'mouseclicked'
    -- if y == lastClick.y
    if math.abs(y - lastClick.y) < 5 then

        -- print the current object color to the console
        if selectedObject ~= 0 then
            local c = testObjList[selectedObject].color
            print("color = ", c[1], c[2], c[3])
        end

        if not istouch then -- if it's a *mouse* click (not a touchscren), consider a click to indicate a final selection:
            colorsCanvasData.active = false -- dismiss the color picker
            selectedObject = 0 -- de-select current colorable object (not necessary, but for clarity)
        else
            -- touchscreens update color on release, but don't close the color select canvas
            if selectedObject ~= 0 then -- if there is a 'selected' object to color...
                updateObjColor()
            end
        end
    end


    -- check if any Colorable Screen Objects got clicked:
    for i in ipairs(testObjList) do
        local o = testObjList[i] -- 'shortcut' to current Object
        if x > o.x and y > o.y and x < (o.x + o.width) and y < (o.y + o.height) then -- if "inside" the button...
            selectedObject = i

            -- save the starting color before previewing new colors
            o.color_previous = { o.color[1], o.color[2], o.color[3] }

            colorsCanvasData.active = true -- Show the color picker
            -- kmk, could put a break the loop here...
        end
    end

end


local function wheelmoved(x, y)
    colorsCanvasData.yPos = colorsCanvasData.yPos + (y * 20) -- speed & direction probably need to be configurable...
end


local function keypressed(key)
    if key == "pagedown" then -- PageDown button...
        -- scroll down 1 screen height (minus one button size)
        colorsCanvasData.yPos = colorsCanvasData.yPos - (UIcanvasData.height - (buttonHeight + buttonSpacing))
    end
    if key == "pageup" then -- PageUp button...
        -- scroll up 1 screen height (minus one button size)
        colorsCanvasData.yPos = colorsCanvasData.yPos + (UIcanvasData.height - (buttonHeight + buttonSpacing))
    end
end


-- Return the Module functions which can be called from the outside:
return {
    keypressed = keypressed,
    load = load,
    update = update,
    draw = draw,
    wheelmoved = wheelmoved,
    mousepressed = mousepressed,
    mousereleased = mousereleased,
}
