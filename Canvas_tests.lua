local thisFile = "Canvas_tests.lua"
print("[" .. thisFile .. "] loaded/running.")

--[[ -- 8/3/22 -- 
    TESTS for using a Canvas as a Scrolling select Menu
    - draw a tall, thin canvas, with text & color boxes 
    - translate it to make it scroll on the screen 

    TODO: 
    - for Dev: create one Big canvas,  and a small app canvas, & color canvass within it. 

    - draw an outline / diff color screens 
    - draw the entire color screen for dev (scaled .5?)
]]


local workScreen = { -- approx size of the desktop being Developed on
    width = 2000,
    height = 1000,
    xPos = 5,
    yPos = 35,
}

local x_workScreen = { -- size of the target Hardware Platform Screen
    width = 640 * 1,
    height = 360 * 1,
    xPos = nil,
    yPos = nil,
}


local appCanvas = { -- the "full screen" of the app (small smartphone size by default)
    width = 640 * 1,
    height = 360 * 1,
}

local colorCanvas = { -- size of the (usually hidden) color picker
    width = 200,
    height = 1000,
    speed = 8,
    xPos = 400,  -- x position on the app screen 
    yPos = 0,  -- the y coordinate will change when user scrolls the window 
}


-- draw the CONTENT of the app
local function drawAppWindow()

    -- just draw any old thing on it as a placeholder... 
    local mode = "fill"
    local x = 50
    local y = 50
    local recWidth = 50
    local recHeight = 50
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
    love.graphics.clear(0.2, 0, 0)
    drawAppWindow()
    love.graphics.setCanvas() -- re-enable drawing to the main screen 
end


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

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(mode, x, y, recWidth, recHeight, rx, ry, segments)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Red", x, y)

    y = y + 50

    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle(mode, x, y, recWidth, recHeight, rx, ry, segments)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Blue", x, y)
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
        { resizable = true, x = workScreen.xPos, y = workScreen.yPos })
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
end


function love.draw()
    --drawColorWindow() -- test-draw direct to screen

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(AppCanvas, 0, 0)

    --love.graphics.draw(ColorsCanvas, 400, colorCnvYpos, 0, 0.5, 0.5) -- draw scaled canvas to screen
    love.graphics.draw(ColorsCanvas, colorCanvas.xPos, colorCanvas.yPos)
    --colorCnvYpos = colorCnvYpos - 1  -- auto drift
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end


function love.wheelmoved(x, y)
    colorCanvas.yPos = colorCanvas.yPos + (y * 20) -- speed & direction probably need to be configurable...
end
