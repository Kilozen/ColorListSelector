local thisFile = "Canvas_tests.lua"
print("[" .. thisFile .. "] loaded/running.")

--[[ -- 8/3/22 -- 
    TESTS for using a Canvas as a Scrolling select Menu
    - draw a tall, thin canvas, with text & color boxes 
    - translate it to make it scroll on the screen 

    For development: create one Big canvas,  and a small app canvas, & color canvass within it. 

    TODO: 
    - implement Dragging of the menu... 
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


-- draw the CONTENT of the app
local function drawAppWindow()

    -- just draw any old thing on it as a placeholder...
    local mode = "line"
    local x = 100
    local y = 100
    local recWidth = 250
    local recHeight = 200
    local rx = nil -- 10
    local ry = nil
    local segments = nil -- 5

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(mode, x, y, recWidth, recHeight, rx, ry, segments)
end


-- create the  Canvas that represents the entire App (within the development canvas)
local function createAppCanvas()

    AppCanvas = love.graphics.newCanvas(appCanvas.width, appCanvas.height)

    love.graphics.setCanvas(AppCanvas) -- draw to the other canvas... 
    --love.graphics.setBackgroundColor(0.2, 0.2, 0) -- bg color of the color window  -- this doesn't see to work right on Canvas..?
    love.graphics.clear(0, 0, 0.2)
    drawAppWindow()
    love.graphics.setCanvas() -- re-enable drawing to the main screen 
end


local colorList = {
    { "Red", 1, 0, 0 },
    { "Yellow", 1, 1, 0 },
    { "Magenta", 1, 0, 1 },
    { "Green", 0, 1, 0 },
    { "Cyan", 0, 1, 1 },
    { "Blue", 0, 0, 1 },
}


local colorCanvas = { -- size of the (usually hidden) color picker
    width = 200,
    height = 1000,
    speed = 8,
    xPos = 400, -- x position on the app screen
    yPos = 0, -- the y coordinate will change when user scrolls the window
    yStartDr = 0, -- the y position of the canvas at the start of a Drag
}



-- draw the CONTENT of the color show/choose page
local function drawColorWindow()
    local mode = "fill"
    local x = 0
    local y = 0
    local recWidth = 200
    local recHeight = 40
    local rx = nil -- 10
    local ry = nil
    local segments = nil -- 5

    -- todo: change to a Loop through a color table...

    for i = 1, #colorList do
        love.graphics.setColor(colorList[i][2], colorList[i][3], colorList[i][4])
        love.graphics.rectangle(mode, x, y, recWidth, recHeight, rx, ry, segments)

        love.graphics.setColor(0, 0, 0) -- black text 
        love.graphics.print(colorList[i][1], x, y)

        y = y + 50
    end
end


-- create the movable Canvas to put the color display on
local function createColorCanvas()
    ColorsCanvas = love.graphics.newCanvas(colorCanvas.width, colorCanvas.height)

    love.graphics.setCanvas(ColorsCanvas) -- draw to the other canvas... 
    --love.graphics.setBackgroundColor(0.2, 0.2, 0) -- bg color of the color window  -- this doesn't see to work right on Canvas..?
    love.graphics.clear(0, 0.2, 0)
    drawColorWindow()
    love.graphics.setCanvas() -- re-enable drawing to the main screen 
end


function love.load()
    love.window.setMode(workScreen.width, workScreen.height,
        { resizable = workScreen.resizable, x = workScreen.xPos, y = workScreen.yPos })
    --love.window.setMode(appCanvas.width, appCanvas.height, { resizable = true })

    love.graphics.setBackgroundColor(0.2, 0, 0.2) -- bg color of the main window 

    local gameFont = love.graphics.newFont(40)
    love.graphics.setFont(gameFont)

    -- (manually painting the "app canvas" into the main window gives flexibility to show all 'windows' during development)
    createAppCanvas()

    colorCanvas.yPos = 250
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

    -- make the colorCanvas "draggable"
    if lastClick.active then
        --colorCanvas.xPos = love.mouse.getX() - lastClick.x
        --colorCanvas.yPos = colorCanvas.yPos + (love.mouse.getY() - lastClick.y) -- (no.. this makes it accelerate)
        colorCanvas.yPos = colorCanvas.yStartDr + (love.mouse.getY() - lastClick.y)
    end
end


function love.draw()
    --drawColorWindow() -- test-draw direct to screen

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(AppCanvas, 0, 0)

    --love.graphics.draw(ColorsCanvas, 400, colorCnvYpos, 0, 0.5, 0.5) -- draw scaled canvas to screen
    love.graphics.draw(ColorsCanvas, colorCanvas.xPos, colorCanvas.yPos)
    --colorCnvYpos = colorCnvYpos - 1  -- auto drift

    if lastClick.active then -- show where click happened
        love.graphics.setColor(1, 1, 1)
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
