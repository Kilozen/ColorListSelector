--[[ conf.lua -- Love2d Configuration File 

	This is run before the LÖVE modules are loaded, and overwrites the 
    (default) love.conf function, which is later called by the LÖVE 'boot' script. 

	{k, I only list the subset I might mess with.}
]]

function love.conf(t)
	t.console = true -- Attach a console (boolean, Windows only)

	t.window.resizable = true -- Let the window be user-resizable (boolean)
	t.window.minwidth = 300 -- Minimum window width if the window is resizable (number)
	t.window.minheight = 100 -- Minimum window height if the window is resizable (number)
--[[
	t.window.fullscreen = false -- Enable fullscreen (boolean)
	t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)

	t.window.vsync = 1 -- Vertical sync mode (number)
	t.window.msaa = 0 -- The number of samples to use with multi-sampled antialiasing (number)
	t.window.depth = nil -- The number of bits per sample in the depth buffer
	t.window.stencil = nil -- The number of bits per sample in the stencil buffer
	t.window.display = 1 -- Index of the monitor to show the window in (number)
	t.window.highdpi = false -- Enable high-dpi mode for the window on a Retina display (boolean)
	t.window.usedpiscale = true -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
]]
	-- prefs for working on the 24" P2416D screen 
	t.window.x = 1100 -- The x-coordinate of the window's position in the specified display (number)
	t.window.y = 400 -- The y-coordinate of the window's position in the specified display (number)
end
