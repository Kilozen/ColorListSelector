local thisFile = "Canvas_tests.lua"
print("[" .. thisFile .. "] loaded/running.")

--[[ -- 8/4/22 -- 
    TESTS for using a Canvas as a Scrolling select Menu 
    - draw a tall, thin canvas, with text & color boxes 
    - translate it to make it scroll on the screen 

    For development: create one Big ~desktop canvas/window,  
    and a small 'app' canvas, & the color canvass within it. 

    TODO: 
    -- make buttons work 
    -- ? if you click (release?) without dragging (much) that triggers it? 
    (draw a white box on the canvas to ack. a click)
    translate canvas coords back to colorList index 
]]

local lastClick = { -- used to carry x,y info of last click or touch
    active = false,
    x = 0,
    y = 0
}

local x_workScreen = { -- approx size of the desktop being Developed on
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

local objectColor = { .6, .4, .4 }

-- draw the CONTENT of the app
local function drawAppWindow()

    -- just draw any old thing on it as a placeholder...
    local mode = "fill"
    local x = 100
    local y = 100
    local recWidth = 250
    local recHeight = 200
    local rx = nil -- 10
    local ry = nil
    local segments = nil -- 5

    --love.graphics.setColor(.6, .4, .4)
    --print(objectColor[1], objectColor[2], objectColor[3])
    love.graphics.setColor(objectColor[1], objectColor[2], objectColor[3])
    love.graphics.rectangle(mode, x, y, recWidth, recHeight, rx, ry, segments)
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
        local buttonNum = ccYtoB(ccy)
        print(love.mouse.getY(), ccy, "button", buttonNum, colorList[buttonNum][1],
            colorList[buttonNum][2], colorList[buttonNum][3], colorList[buttonNum][4])

        objectColor[1] = colorList[buttonNum][2]
        objectColor[2] = colorList[buttonNum][3]
        objectColor[3] = colorList[buttonNum][4]
        --objectColor = { .6, .4, .4 }

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
    print(x, y)
    -- love.graphics.rectangle("fill", x, y, 10, 10) -- no, can't draw in a callback.
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
