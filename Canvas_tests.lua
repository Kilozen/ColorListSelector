local thisFile = "Canvas_tests.lua"
print("[" .. thisFile .. "] loaded/running.")

--[[ -- 8/10/22 -- 
    TESTS for using a Canvas as a Scrolling select Menu 
    - draw a tall, thin canvas, with text & color boxes 
    - translate it to make it scroll on the screen 

    For development: create one Big ~desktop canvas/window,  
    and a small 'app' canvas, & the color canvass within it. 

    TODO: 
    - get two screen objects to launch the color picker. 
    - (when the picker is brought up, it should probably be in the same position it was left at)

    - if you click or hover on a color, it updates, if you click on an empty part of the screen, it stops updating (and the picker goes away)

    - if mouse "hovers" outside the color picker area, the object should probably return to its previous color 

    - OLD: 
    ? if you click (release?) without dragging (much) that triggers it? 
    (draw a white box on the canvas to ack. a click)
    translate canvas coords back to colorList index 

    -- implement PgUp/Dn keys? 

    [] Think about writing this WHOLE thing to be "modular" / a separate, reusable file. 
    and the specific buttons and colors are configured in a 3rd separate file. 
]]

local lastClick = { -- used to carry x,y info of last click or touch
    active = false,
    x = 0,
    y = 0
}

local xx_workScreen = { -- approx size of the desktop being Developed on
    width = 2000,
    height = 1000,
    xPos = 5,
    yPos = 35,
    resizable = true }

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
    color = { .6, .4, .4 } -- default starting color
}

local testObj2 = {
    x = 50,
    y = 220,
    width = 300,
    height = 100,
    color = { .4, .4, .6 } -- default starting color
}

local testObjList = { testObj1, testObj2 } -- test objects (rectangles) to color on screen
local selectedObject = 1 -- begin with region 1 already selected by default


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
-- this is a *static* canvas, drawn once at startup.
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


function love.update(dt)
    if love.keyboard.isDown("down") then
        colorCanvas.yPos = colorCanvas.yPos - colorCanvas.speed
    elseif love.keyboard.isDown("up") then
        colorCanvas.yPos = colorCanvas.yPos + colorCanvas.speed
    end

    -- This 'if' causes screen to scroll *steadily* up if you touch the upper part of the screen.
    -- if lastClick.active then
    --     if lastClick.y < 200 then
    --         colorCanvas.yPos = colorCanvas.yPos - colorCanvas.speed
    --     else
    --         colorCanvas.yPos = colorCanvas.yPos + colorCanvas.speed
    --     end
    -- end

    -- if mouse is in the colorCanvas area...
    if (love.mouse.getX() > colorCanvas.xPos) and
        (love.mouse.getX() < colorCanvas.xPos + colorCanvas.width)
    then
        local ccy = love.mouse.getY() - colorCanvas.yPos -- cursor y position on the colorCanvas
        local buttonNum = ccYtoB(ccy) -- get the ID of the Button ID the cursor is on

        -- print mouse position, button, etc...
        -- print(love.mouse.getY(), ccy, "button", buttonNum,
        --     colorList[buttonNum][1], colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4])

        -- update the color of the currently "selected" object
        if selectedObject ~= 0 then
            local selObj = testObjList[selectedObject]
            selObj.color = { colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4] }
        end


        -- if a click/press is 'active' the colorCanvas can be "dragged"
        if lastClick.active then
            --colorCanvas.yPos = colorCanvas.yPos + (love.mouse.getY() - lastClick.y) -- (no.. this makes it accelerate)
            colorCanvas.yPos = colorCanvas.yStartDr + (love.mouse.getY() - lastClick.y)
        end
    end
end


function love.draw()
    --drawColorWindow() -- test-draw direct to screen

    -- love.graphics.setColor(1, 1, 1)
    drawAppCanvas()
    love.graphics.draw(AppCanvas, 0, 0)

    --colorCanvas.Ypos = colorCanvas.yPos + 1 -- auto drift
    --love.graphics.draw(ColorsCanvas, 400, colorCnvYpos, 0, 0.5, 0.5) -- draw scaled canvas to screen
    love.graphics.draw(ColorsCanvas, colorCanvas.xPos, colorCanvas.yPos)

    -- draw a box to show where a click happened
    if lastClick.active then
        love.graphics.setColor(.7, .7, 0)
        love.graphics.rectangle("fill", lastClick.x, lastClick.y, 10, 10)
    end
end


function love.mousepressed(x, y, button, istouch, presses) -- should work for both mouseclick & touchscreen...
    -- keep both mouse & touchscreeen in mind here!

    print("mousepressed = " .. x, y)
    -- love.graphics.rectangle("fill", x, y, 10, 10) -- no, can't draw from inside a callback.

    -- if clicking in the color-picker area...
    if x > colorCanvas.xPos then
        -- don't change the object selection 
    else
        -- de-select current object if clicking outisde the color picker area
        selectedObject = 0
    end

    -- check if any screen objects got clicked:
    for i in ipairs(testObjList) do
        local o = testObjList[i]
        if x > o.x and y > o.y and x < (o.x + o.width) and y < (o.y + o.height) then
            selectedObject = i
        end
    end
    -- []? also check for clicks on color buttons?...


    -- keeping track of the last mouse-down gets used in *dragging* interactions
    lastClick.active = true
    lastClick.x = x
    lastClick.y = y
    colorCanvas.yStartDr = colorCanvas.yPos -- save current position of colorCanvas, in case it gets dragged
end


function love.mousereleased(x, y, button, istouch, presses)
    lastClick.active = false
end


function love.wheelmoved(x, y)
    colorCanvas.yPos = colorCanvas.yPos + (y * 20) -- speed & direction probably need to be configurable...
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
