local thisFile = "Canvas_tests.lua"
print("[" .. thisFile .. "] loaded/running.")

--[[
TESTS for using a Canvas as a Scrolling select Menu
- draw a tall, thin canvas, with text & color boxes 
- translate it to make it scroll on the screen 



screenCanvas = love.graphics.newCanvas(400, 600) 

-- set the canvas we want to draw on: 
love.graphics.setCanvas(screenCanvas) 
    love.graphics.clear() 
    drawGame(player2) -- onto canvas 

love.graphics.setCanvas()  -- return to the default canvas... 
love.graphics.draw(screenCanvas, 400) -- draw our canvass onto the default. 
... 
]]

local colorCanvas = {
    width = 200,
    height = 800,
    Ypos = 0,
    speed = 8,

}

local colorCnvYpos = 0
local colorCnvspeed = 8


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

    local colorCnvWidth = 200
    local colorCnvHeight = 200
    ColorsCanvas = love.graphics.newCanvas(colorCnvWidth, colorCnvHeight)

    love.graphics.setCanvas(ColorsCanvas) -- draw to the other canvas... 
    drawColorWindow()
    love.graphics.setCanvas() -- re-enable drawing to the main screen 
end


function love.load()
    love.window.setMode(640 * 1, 360 * 1, { resizable = true })

    local gameFont = love.graphics.newFont(40)
    love.graphics.setFont(gameFont)

    colorCnvYpos = 250
    createColorCanvas()
end


function love.update(dt)
    if love.keyboard.isDown("down") then
        colorCnvYpos = colorCnvYpos - colorCnvspeed
    elseif love.keyboard.isDown("up") then
        colorCnvYpos = colorCnvYpos + colorCnvspeed
    end
end


function love.draw()

    -- drawColorWindow() -- test-draw direct to screen


    love.graphics.setColor(1, 1, 1)
    --love.graphics.draw(ColorsCanvas, 400, colorCnvYpos, 0, 0.5, 0.5) -- draw scaled canvas to screen
    love.graphics.draw(ColorsCanvas, 400, colorCnvYpos)
    --colorCnvYpos = colorCnvYpos - 1  -- auto drift
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end


function love.wheelmoved(x, y)
    colorCnvYpos = colorCnvYpos + (y * 20) -- speed & direction probably need to be configurable...
end
