-- https://sheepolution.com/learn/book/16 
-- "main.lua" for Love2D 
local thisFile = "main.lua"

local fileToRun = "Canvas_tests" --> moved to 'ColorListSelector'
--local fileToRun = "Canvas_tests (12)" --> moved to 'ColorListSelector'


print("["..thisFile.."] loaded/running.")

-- [] add a print of all Version info:  Love2D, LuaJIT, Lua... 

print("[main.lua] loading "..fileToRun..".lua\n")
require(fileToRun) -- load the file with the main Love2D Callbacks. 

