--[[ "main.lua" for Love2D -- TEST DRIVER 1 for ColorListSelector

    The User's color list and trigger buttons are defined in ColorListConfig.lua 

    Then in this (user) file, draw whatever you want on the screen, and 
    apply the selected colors from the buttons on whatever else you want to color. 

    kmk todo: Create a *minimalist* "template_main.lua" file, with nothing in it 
    besides the minimum needed.  
    And make one or two simple "Example" apps (2 different sized 'work screen's,
    different font sizes & screen colors.)
--]]


local CLS = require('ColorListSelector')


function love.load()
    local gameFont = love.graphics.newFont(40)
    love.graphics.setFont(gameFont)
    --love.graphics.setBackgroundColor(0.2, 0, 0.2) -- bg color of the main window


    CLS.load()
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

