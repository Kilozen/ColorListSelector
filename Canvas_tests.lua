local thisFile = "Canvas_tests.lua"
print("[" .. thisFile .. "] loaded/running.")

-- 8/24/22 -- 
--[[ __Name__.lua -- Simple Color Picker UI for Love2D 
     These functions provide a pop-up, scrollable, list of colors which can be associated
     with objects on the screen (such as color-select buttons) to bring up the list, 
     then colors are touched to apply them. 

     It is implemented for computer Mouse, and phone Touchscreen (android currently)
    
    How the code works: 
    There is an "app" canvas (where you put your things to be colored, and buttons
    to trigger the color menu/selector.)
    And a "color" selector canvas (tall and narrow, scrollable) 
    The ColorsCanvas is scrolled simply by drawing it at different y coordinates
    (most of that tall canvas will be off the top or bottom of the screen.)

    love.draw() -- is pretty simple: 
    it draws the user's app objects to the AppCanvas, then draws the AppCanvas
    to the Love2D app window. 
    and *if* the ColorsCanvas is "active", then it also draws the ColorsCanvas 
    over the Love2D app window, at its current scrolled y coordinate. 

    The position (y-axis scrolling) of the ColorsCanvas (i.e. colorCanvas.yPos)
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

    - implement PgUp/Dn keys? 
    - draw a white box on buttons to ack. a selection? 
    - cosmetic improvements (rounded buttons?)
    - make fit more exact for any mobile screen (scale?)

    [] Think about writing this WHOLE thing to be "modular" / a separate, reusable file. 
       and the specific buttons and colors are configured in a 3rd separate file. 

    Also, Publish this as an independent, reusable Module on GitHub. 
]]

local touchscreen = false -- detect & set this during init

local lastClick = { -- save x,y info of last initiation of a mouse click or touch (for dragging operations)
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


local testObj1 = {  -- rectangle ~button wtih a text label 
    x = 50,
    y = 100,
    width = 300,
    height = 100,
    color = { .6, .4, .4 }, -- default starting color
    color_previous = { .6, .4, .4 },
    text = "Primary"   -- text label on the button 
}

local testObj2 = {
    x = 50,
    y = 220,
    width = 300,
    height = 100,
    color = { .4, .4, .6 }, -- default starting color
    color_previous = { .4, .4, .6 },
    text = "Secondary"
}

local testObjList = { testObj1, testObj2 } -- test objects (rectangles) to color on screen
local selectedObject = 0   -- the Currently Selected (touched) object 


-- draw the "Content" of the app
local function drawAppWindow()
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


local function drawAppCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas(AppCanvas) -- draw to the other canvas...
    --love.graphics.setBackgroundColor(0.2, 0.2, 0) -- bg color of the color window  -- this doesn't see to work right on Canvas..?
    love.graphics.clear(0, 0, 0.2)
    drawAppWindow()
    love.graphics.setCanvas() -- re-enable drawing to the main screen
    love.graphics.setColor(1, 1, 1)
end


-- create the  Canvas that represents the entire App (within the development 'desktop' canvas)
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

    { "Red", .6, 0, 0 },
    { "Yellow", .6, .6, 0 },
    { "Magenta", .6, 0, .6 },
    { "Green", 0, .6, 0 },
    { "Cyan", 0, .6, .6 },
    { "Blue", 0, 0, .6 },
}


local colorCanvas = { -- size of the (usually hidden) color picker
    active = false,
    width = 200,
    height = 700,  -- todo: calculate this from color list size 
    speed = 8,  -- scroll speed for things like arrow keys 
    xPos = 400, -- x position on the app screen
    yPos = 0, -- the y coordinate will change when user scrolls the window
    yStartDr = 0, -- the y position of the canvas at the start of a Drag
}


local buttonHeight = 30 -- default 30
local buttonSpacing = 6 -- default 6

local function ccBtoY(button) -- colorCanvas Button # --> Y coord 
    -- basically: button number * height ... with a few tweaks. 
    local y = (button - 1) * (buttonHeight + buttonSpacing)
    return y
end


local function ccYtoB(y) -- colorCanvas Y coord --> Button #
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


-- draw the CONTENT of the color show/select canvas
local function drawColorWindow()
    local mode = "fill"
    local x = 0
    local y = 0
    local buttonWidth = colorCanvas.width
    --local recHeight = 40
    local rx = nil -- 10 -- (if you want rounded corners)
    local ry = nil
    local segments = nil -- 5

    love.graphics.setFont(love.graphics.newFont(buttonHeight - 6))

    -- draw each color sample rectangle and color name
    for i = 1, #colorList do  -- (could have used ipairs)
        love.graphics.setColor(colorList[i][2], colorList[i][3], colorList[i][4])

        y = ccBtoY(i) -- get Y coordinate to use for next button
        love.graphics.rectangle(mode, x, y, buttonWidth, buttonHeight, rx, ry, segments)

        love.graphics.setColor(0, 0, 0) -- black text
        love.graphics.print(colorList[i][1], x + 2, y)
    end
end


-- create the movable Canvas to put the color list on
-- this is a *static* canvas, drawn once at startup:
-- just create the canvas object, and draw it (once) in the background.
local function createColorCanvas()
    ColorsCanvas = love.graphics.newCanvas(colorCanvas.width, colorCanvas.height)

    love.graphics.setCanvas(ColorsCanvas) -- draw to the other canvas...
    --love.graphics.setBackgroundColor(0.2, 0.2, 0) -- bg color of the color window  -- this doesn't seem to work right on Canvas..?
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

    love.graphics.setBackgroundColor(0.2, 0, 0.2) -- bg color of the main window

    love.graphics.setFont(love.graphics.newFont(40))

    -- (manually painting the "app canvas" into the main window gives flexibility to show all 'windows' during development)
    createAppCanvas()

    colorCanvas.yPos = 0
    createColorCanvas()
end


local function inColorCanvas() -- test if mouse/cursor is within the ColorCanvas
    local isIn = false

    if (love.mouse.getX() > colorCanvas.xPos) and
        (love.mouse.getX() < colorCanvas.xPos + colorCanvas.width) -- (maybe add check of Y coordinate too?)
    then
        isIn = true
    end
    return isIn
end


local function updateObjColor() -- update the color of the currently "selected" object, to the color sample the mouse is over. 
    local ccy = love.mouse.getY() - colorCanvas.yPos -- cursor y position on the colorCanvas
    local buttonNum = ccYtoB(ccy) -- get the ID (index) of the Button the cursor is over
    -- print(love.mouse.getY(), ccy, "button", buttonNum,
    --     colorList[buttonNum][1], colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4])
    local selObj = testObjList[selectedObject]
    selObj.color = { colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4] }
end


function love.update(dt)
    -- In other callbacks, updates happen from events like Clicks.
    -- Here, we handle mouse "hover" updates, and
    -- keys or touches that are "held" down (e.g. dragging)

    -- Update things like:
    -- scrolled position of the color picker
    -- color updates due to mouse hover 

    if colorCanvas.active -- if the color picker is currently displayed... 
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

            -- if MOUSE is IN the area of an 'active' colorCanvas...
            if inColorCanvas() then

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
                -- if a click/press is 'active' (held down) the colorCanvas can be "dragged"
                if lastClick.active then
                    colorCanvas.yPos = colorCanvas.yStartDr + (love.mouse.getY() - lastClick.y)
                end

            else -- mouse is outside the color selector, so revert to the previous color

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
        --colorCanvas.yPos = colorCanvas.yPos + 1 -- auto drift 
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


    -- if the mouse hasn't been 'dragged' significantly, then something was 'mouseclicked'
    -- if y == lastClick.y
    if math.abs(y - lastClick.y) < 5 then

        if not istouch then -- if it's a *mouse* click (not a touchscren), consider a click to indicate a final selection:
            colorCanvas.active = false -- dismiss the color picker
            selectedObject = 0 -- de-select current colorable object (not necessary, but logically consistent)
        else
            -- touchscreens update color on release, but don't close the color select canvas 
            if selectedObject ~= 0 then -- if there is a 'selected' object to color...
                updateObjColor()
            end
        end
    end


    -- check if any Colorable Screen Objects got clicked: 
    for i in ipairs(testObjList) do
        local o = testObjList[i]  -- 'shortcut' to current Object 
        if x > o.x and y > o.y and x < (o.x + o.width) and y < (o.y + o.height) then -- if "inside" the button... 
            selectedObject = i

            -- save the starting color before previewing new colors
            o.color_previous = { o.color[1], o.color[2], o.color[3] }

            colorCanvas.active = true -- Show the color picker
            -- kmk, could put a break the loop here...
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
