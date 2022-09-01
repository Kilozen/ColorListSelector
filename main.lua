--[[ "main.lua" for Love2D -- TEST DRIVER 1 for ColorListSelector

    The User's color list and trigger buttons are defined in ColorListConfig.lua 

    Then in this (user) file, draw whatever you want on the screen, and 
    apply the selected colors from the buttons on whatever else you want to color. 

    kmk todo: Create a *minimalist* "template_main.lua" file, with nothing in it 
    besides the minimum needed.  
    And make one or two simple "Example" apps (2 different sized 'work screen's,
    different font sizes & screen colors.)
--]]


require "strict"
local CLS = require('ColorListSelector')


local appWindow_mobile = {
    --[[
        These are the dimensions, etc. of the Love2D app window to create. 
        For a small device, it is likely to be the Full Screen size of the
        device.  On a desktop, it might be full screen, or a smaller window. 
    --]]
    width = 640 * 1,
    height = 360 * 1,
    xPos = nil,
    yPos = nil,
    resizable = false
}

local appWindow_larger = {
    width = 2000,
    height = 1000,
    --xPos = 5,
    --yPos = 35,
    resizable = true
}

local appWindow = appWindow_mobile -- assign whichever appWindow size to currently develop with



function love.load()
    -- create the Love2D main app window 
    love.window.setMode(appWindow.width, appWindow.height,
        { resizable = appWindow.resizable, x = appWindow.xPos, y = appWindow.yPos })

    local gameFont = love.graphics.newFont(40)
    love.graphics.setFont(gameFont)
    --love.graphics.setBackgroundColor(0.2, 0, 0.2) -- bg color of the main window

    CLS.load() -- let ColorListSelector do its initialization 
end


function love.update(dt)
    -- (user code here)

    CLS.update(dt)
end


function love.draw()
    love.graphics.print("Example1", 20, 20)

    love.graphics.setColor(0.15, 0.15, 0.9)
    love.graphics.circle("fill", 200, 50, 40)

    love.graphics.setColor(0.9, 0.15, 0.15)
    love.graphics.circle("fill", 240, 30, 20)


    CLS.draw()
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    CLS.keypressed(key)
end


function love.wheelmoved(x, y)
    -- (user code here if desired)

    CLS.wheelmoved(x, y)
end


function love.mousepressed(x, y, button, istouch, presses)
    -- (user code here if desired)

    CLS.mousepressed(x, y)
end


function love.mousereleased(x, y, button, istouch, presses)
    -- (user code here if desired)

    CLS.mousereleased(x, y)
end
