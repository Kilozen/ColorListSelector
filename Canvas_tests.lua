local thisFile = "Canvas_tests.lua"
print("[" .. thisFile .. "] loaded/running.")

--[[ -- 8/12/22 -- 
    TESTS for using a Canvas as a Scrolling select Menu 
    - draw a tall, thin canvas, with text & color boxes 
    - translate it to make it scroll on the screen 

    For development: create one Big ~desktop canvas/window,  
    and a small 'app' canvas, & the color canvass within it. 

    When implementing UI interactions, keep in mind that Mouse "hover" also 
    shows color selection effects instantly... but touchscreens can't do this, 
    so touchscreen clicks may be handled a bit differently. 

    TODO: 
    - fix Phone to revert to previous color if the touch was a "drag" 
    (no.. actually the phone will still retain a "mouse position", so you 
    can't stop it from applying the new color unless you stop phone from 
    updating color in the .update() function)


    - OLD: 
    ? if you click (release?) without dragging (much) that triggers it? 
    (draw a white box on the canvas to ack. a click)
    translate canvas coords back to colorList index 

    -- implement PgUp/Dn keys? 

    [] Think about writing this WHOLE thing to be "modular" / a separate, reusable file. 
    and the specific buttons and colors are configured in a 3rd separate file. 
]]

local touchscreen = false -- detect & set this during init

local lastClick = { -- save x,y info of last initiation of a click or touch (for dragging operations)
    active = false,
    -- x = 0,
    y = 0
}

local xx_workScreen = { -- approx size of the desktop being Developed on
    width = 2000,
    height = 1000,
    xPos = 5,
    yPos = 35,
    resizable = true
}

local workScreen = { -- size of the target Hardware Platform Screen
    width = 640 * 1,
    height = 360 * 1,
    xPos = nil,
    yPos = nil,
    resizable = false
}


local appCanvas = { -- the "full screen" of the app (small smartphone size by default)
    width = 640 * 1,
    height = 360 * 1,
}



local testObj1 = {
    x = 50,
    y = 100,
    width = 300,
    height = 100,
    color = { .6, .4, .4 }, -- default starting color
    color_previous = { .6, .4, .4 }
}

local testObj2 = {
    x = 50,
    y = 220,
    width = 300,
    height = 100,
    color = { .4, .4, .6 }, -- default starting color
    color_previous = { .4, .4, .6 }
}

local testObjList = { testObj1, testObj2 } -- test objects (rectangles) to color on screen
local selectedObject = 0


-- draw the "Content" of the app
local function drawAppWindow()

    for i in ipairs(testObjList) do
        -- just draw any old thing on it as a placeholder...
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
    end

end


local function drawAppCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas(AppCanvas) -- draw to the other canvas...
    --love.graphics.setBackgroundColor(0.2, 0.2, 0) -- bg color of the color window  -- this doesn't see to work right on Canvas..?
    love.graphics.clear(0, 0, 0.2)
    drawAppWindow()
    love.graphics.setCanvas() -- re-enable drawing to the main screen
    love.graphics.setColor(1, 1, 1)
end


-- create the  Canvas that represents the entire App (within the development canvas)
local function createAppCanvas()

    AppCanvas = love.graphics.newCanvas(appCanvas.width, appCanvas.height)
    drawAppCanvas()
end


local colorList = {
    { "Red", 1, 0, 0 },
    { "Yellow", 1, 1, 0 },
    { "Magenta", 1, 0, 1 },
    { "Green", 0, 1, 0 },
    { "Cyan", 0, 1, 1 },
    { "Blue", 0, 0, 1 },

    { "Red", .5, 0, 0 },
    { "Yellow", .5, .5, 0 },
    { "Magenta", .5, 0, .5 },
    { "Green", 0, .5, 0 },
    { "Cyan", 0, .5, .5 },
    { "Blue", 0, 0, .5 },
}


local colorCanvas = { -- size of the (usually hidden) color picker
    active = false,
    width = 200,
    height = 700,
    speed = 8,
    xPos = 400, -- x position on the app screen
    yPos = 0, -- the y coordinate will change when user scrolls the window
    yStartDr = 0, -- the y position of the canvas at the start of a Drag
}


local buttonHeight = 30 -- default 30
local buttonSpacing = 6 -- default 6

local function ccBtoY(button) -- colorCanvas Button --> Y coord
    local y = (button - 1) * (buttonHeight + buttonSpacing)
    return y
end


local function ccYtoB(y) -- colorCanvas Y coord --> Button #
    -- the calculation includes the spacing under the button as part of the button,
    -- so shifting y at least centers it better:
    y = y + (buttonSpacing / 2)

    local button = (y / (buttonHeight + buttonSpacing)) + 1
    button = math.floor(button)

    if button < 1 then button = 1 end
    if button > #colorList then button = #colorList end
    return button
end


-- draw the CONTENT of the color show/choose page
local function drawColorWindow()
    local mode = "fill"
    local x = 0
    local y = 0
    local buttonWidth = 200
    --local recHeight = 40
    local rx = nil -- 10
    local ry = nil
    local segments = nil -- 5

    love.graphics.setFont(love.graphics.newFont(buttonHeight - 6))

    for i = 1, #colorList do
        love.graphics.setColor(colorList[i][2], colorList[i][3], colorList[i][4])

        y = ccBtoY(i)
        love.graphics.rectangle(mode, x, y, buttonWidth, buttonHeight, rx, ry, segments)

        love.graphics.setColor(0, 0, 0) -- black text
        love.graphics.print(colorList[i][1], x + 2, y)

        --y = y + buttonHeight + buttonSpacing
    end
end


-- create the movable Canvas to put the color display on
-- this is a *static* canvas, drawn once at startup:
-- just create the canvas object, and draw it (once) in the background.
local function createColorCanvas()
    ColorsCanvas = love.graphics.newCanvas(colorCanvas.width, colorCanvas.height)

    love.graphics.setCanvas(ColorsCanvas) -- draw to the other canvas...
    --love.graphics.setBackgroundColor(0.2, 0.2, 0) -- bg color of the color window  -- this doesn't see to work right on Canvas..?
    -- love.graphics.clear(0, 0.2, 0)  -- color the sub-canvas to make its boundaries visible for dev.
    love.graphics.clear(0, 0, 0)
    drawColorWindow()
    love.graphics.setCanvas() -- re-enable drawing to the main screen
end


function love.load()
    -- detect whether the device is using a touchscreen UI
    if love.system.getOS() == "Android" then
        touchscreen = true
    else
        touchscreen = false
    end

    love.window.setMode(workScreen.width, workScreen.height,
        { resizable = workScreen.resizable, x = workScreen.xPos, y = workScreen.yPos })
    --love.window.setMode(appCanvas.width, appCanvas.height, { resizable = true })

    love.graphics.setBackgroundColor(0.2, 0, 0.2) -- bg color of the main window

    love.graphics.setFont(love.graphics.newFont(40))

    -- (manually painting the "app canvas" into the main window gives flexibility to show all 'windows' during development)
    createAppCanvas()

    colorCanvas.yPos = 0
    createColorCanvas()
end


local function inColorCanvas() -- test if mouse/cursor is Over the ColorCanvas
    local isIn = false

    if (love.mouse.getX() > colorCanvas.xPos) and
        (love.mouse.getX() < colorCanvas.xPos + colorCanvas.width) -- (maybe add check of Y coordinate too?)
    then
        isIn = true
    end
    return isIn
end


local function updateObjColor() -- update the color of the currently "selected" object
    local ccy = love.mouse.getY() - colorCanvas.yPos -- cursor y position on the colorCanvas
    local buttonNum = ccYtoB(ccy) -- get the ID of the Button ID the cursor is on
    -- print(love.mouse.getY(), ccy, "button", buttonNum,
    --     colorList[buttonNum][1], colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4])
    local selObj = testObjList[selectedObject]
    selObj.color = { colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4] }
end


function love.update(dt)

    -- Elsewhere, updates happen from events like Clicks.
    -- Here, we handle mouse "hover" updates, and
    -- keys or touches that are "held" down (e.g. dragging)

    -- Update things like:
    -- scrolled position of the color picker
    -- color updates due to mouse hover

    if colorCanvas.active
    then
        -- Up/Down Keys can scroll color picker
        if love.keyboard.isDown("down") then
            colorCanvas.yPos = colorCanvas.yPos - colorCanvas.speed
        elseif love.keyboard.isDown("up") then
            colorCanvas.yPos = colorCanvas.yPos + colorCanvas.speed
        end

        -- -- (This code was used before touchscreen dragging was implemeted)
        -- -- This 'if' causes screen to scroll *steadily* up if you touch the upper part of the screen:
        -- if lastClick.active then
        --     if lastClick.y < 200 then
        --         colorCanvas.yPos = colorCanvas.yPos - colorCanvas.speed
        --     else
        --         colorCanvas.yPos = colorCanvas.yPos + colorCanvas.speed
        --     end
        -- end

        if selectedObject ~= 0 then -- if there is a 'selected' object to color...

            -- if mouse is IN the area of an 'active' colorCanvas...
            if inColorCanvas() then

                -- Color update:
                -- do Instant preview only for pointers that can "hover"
                if touchscreen == false then
                    --[[ we don't want to do "instant updates" for touchscreens because then it would select
                        a color even on *drags*, and we can't "undo" on "release" because the touch seems 
                        to retain a .getY() value, so it keeps applying the unintended color.
                    --]]
                    updateObjColor()
                    -- -- update the color of the currently "selected" object
                    -- local ccy = love.mouse.getY() - colorCanvas.yPos -- cursor y position on the colorCanvas
                    -- local buttonNum = ccYtoB(ccy) -- get the ID of the Button ID the cursor is on
                    -- -- print(love.mouse.getY(), ccy, "button", buttonNum,
                    -- --     colorList[buttonNum][1], colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4])
                    -- local selObj = testObjList[selectedObject]
                    -- selObj.color = { colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4] }
                end


                -- Drag:
                -- if a click/press is 'active' (held down) the colorCanvas can be "dragged"
                if lastClick.active then
                    colorCanvas.yPos = colorCanvas.yStartDr + (love.mouse.getY() - lastClick.y)
                end

            else -- mouse is outside the color selector, so revert  to the previous color

                local selObj = testObjList[selectedObject]
                selObj.color = { selObj.color_previous[1], selObj.color_previous[2], selObj.color_previous[3] }
            end
        end
    end -- end checks related to colorCanvas

end


function love.draw()
    --drawColorWindow() -- dev test: test-draw direct to screen

    drawAppCanvas() -- update the main app window, in the background, then draw it:
    love.graphics.draw(AppCanvas, 0, 0)

    -- draw the (static) Color picker canvas (if active)
    if colorCanvas.active then
        love.graphics.draw(ColorsCanvas, colorCanvas.xPos, colorCanvas.yPos)
        --love.graphics.draw(ColorsCanvas, 400, colorCnvYpos, 0, 0.5, 0.5) -- draw scaled canvas to screen
        --colorCanvas.Ypos = colorCanvas.yPos + 1 -- auto drift
    end

    -- draw a little box to show where a click/touch happened
    -- if lastClick.active then
    --     love.graphics.setColor(.7, .7, 0)
    --     love.graphics.rectangle("fill", lastClick.x, lastClick.y, 10, 10)
    -- end
end


function love.mousepressed(x, y, button, istouch, presses) -- keep both mouse & touchscreeen in mind here!

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
    colorCanvas.yStartDr = colorCanvas.yPos -- save current Y position of colorCanvas, in case it gets dragged


    -- if clicking Outside the color-picker area...
    if not inColorCanvas() then
        selectedObject = 0 -- de-select current color-able object
        colorCanvas.active = false -- dismiss the color picker
    end

end


function love.mousereleased(x, y, button, istouch, presses)
    print("mouse at " .. x, y)

    lastClick.active = false -- touch is no longer down... no 'drag' is active.
    -- (we don't want things getting dragged just from mouse movement)

    -- Releasing a *mouse* click dismisses the color picker (finalizes selection) if it wasn't a "drag"
    -- Releasing a *touch* (mobile screen) does nothing (keep the color picker visible)
    -- Clicking (& Releasing) on a color-able object, Selects that Object and Activates the color Picker


    -- if the mouse hasn't been 'drgged' significantly, then something was 'mouseclicked'
    -- if y == lastClick.y
    if math.abs(y - lastClick.y) < 5 then

        if not istouch then -- if it's a *mouse* click (not a touchscren), consider a click to indicate a final selection:
            -- (not needed... non touchscreens already update coloring in .update() )
            -- if selectedObject ~= 0 then -- if there is a 'selected' object to color...
            --     updateObjColor()
            -- end
            colorCanvas.active = false -- dismiss the color picker
            selectedObject = 0 -- de-select current colorable object (not necessary, but logically consistent)
        else
            -- touchscreens update color on release, but don't end the selection process
            if selectedObject ~= 0 then -- if there is a 'selected' object to color...
                -- kmkmk
                updateObjColor()
            end
        end

        -- else -- if something was "dragged", that's not a "select" operation, so revert to the previous color

        --     print("drag release...")
        --     -- (for a *mouse* hovering over a color, this revert won't be noticable, but it matters for touchscreens)
        --     if selectedObject ~= 0 then
        --         local selObj = testObjList[selectedObject]
        --         selObj.color = { selObj.color_previous[1], selObj.color_previous[2], selObj.color_previous[3] }
        --     end
    end


    -- check if any Colorable Screen Objects got clicked:
    for i in ipairs(testObjList) do
        local o = testObjList[i]
        if x > o.x and y > o.y and x < (o.x + o.width) and y < (o.y + o.height) then
            selectedObject = i

            -- save the starting color before previewing new colors
            -- o.color_previous = o.color  -- No.. that would just be an alias.. right?
            o.color_previous = { o.color[1], o.color[2], o.color[3] }

            colorCanvas.active = true -- show the color picker
            -- kmk, could put a ~break loop here...
        end
    end

end


function love.wheelmoved(x, y)
    colorCanvas.yPos = colorCanvas.yPos + (y * 20) -- speed & direction probably need to be configurable...
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
