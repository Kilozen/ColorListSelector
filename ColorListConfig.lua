--[[ ColorListConfig:
    Contains the configurable data to be used by --> ColorListSelector.lua

    
    ToDo: Figure out how much of the code comments to remove from the code 
    and move to external documentation. 

    This file is meant to contain just User-Configurable data and initial values. 
    [The library code (ColorListSelector.lua) may also insert other related 
    variables into these same data structures (such as the current position 
    of a scrolling menu), but the user should not need to be aware of that.]  

    The user app must "require "ColorListConfig", but rather than modifying this 
    file where it is, the user app would likely make a local copy of this file 
    somewhere convenient, and modify it and 'require()' that modified copy. 

    Two kinds of "Buttons" are mentioned:
    The Application/User-defined buttons, which trigger the Color Selector menu,
    and "remember" the current color choices.
    And the auto-generated buttons in the long color Selector List.
--]]

-- set the size/spacing of the Color buttons in the color List menu
local buttonHeight = 30 -- default 30
local buttonSpacing = 4 -- default 6.. maybe 4


local UIcanvasData = {
    --[[
        The "full screen" of the UI (small smartphone size by default) 
        Everything specified in ColorListConfig.lua is drawn on THIS canvas. 
        Normally, you'll just want to make this canvas the same dimensions 
        that your overall "app" window is.  It will be drawn on top of your app 
        (but its background is transparent, so your other content shows through.)
    ]]
    width = 640 * 1,
    height = 360 * 1,
    -- Normally the canvas background color should be left as transparent black,
    -- but sometimes it's useful set a slight color to be able to see the boundaries.
    -- bgColor = {0, 0, 1, 0.2},
    bgColor = { 0, 0, 0, 0 },
}

--[[ Note: values in these tables are an easy way to set initial static
    positions.  But often user code may need to overwrite these value 
    if the app window is resizable, etc. 
]]
local colorsCanvasData = { -- config for the colorsCanvas
    --[[
        Here you can set the position & width of the Color Selection window. 
    --]]
    xPos = 400, -- x position on the app screen
    yPos = 0, -- initial y position (this value will change when user scrolls the window)
    width = 200, -- ('height' is calculated based on list length)
    speed = 8, -- scroll speed for things like arrow keys
    -- Normally the canvas background color should be left as transparent black,
    -- but sometimes it's useful set a slight color to be able to see the boundaries.
    -- bgColor = { 0, 1, 0, 0.3 },
    bgColor = { 0, 0, 0, 0 },
}

--=========================================================================================--
--[[ Define User/Application buttons -- 
     which trigger the Color Selector menu, and "remember" the current color choices. 

     Below, you can define as many Buttons as you like, and add them to the button list. 
     Each button will trigger the Color Selector to appear. 
--]]

-- Trigger the color select menu to appear, and show the currently chosen color
-- They're just rectangle buttons with a text label.
local userButton1 = {
    text = "Primary", -- text label on the button
    -- kmk todo: specify font size, or compute it, or give user a hook to set it?
    x = 430,
    y = 10,
    width = 200,
    height = 60,
    color = { .6, .4, .4 } -- Starting color (can be anything)
    -- (incidentally, the "current" color selection is actually tracked
    -- by its list index number, in a field called "color_listNumber")
}

local userButton2 = {
    text = "Secondary",
    x = 430,
    y = 80,
    width = 200,
    height = 60,
    color = { .4, .4, .6 } -- Starting color
}



local userButton3 = {
    text = "Tertiary",
    x = 430,
    y = 150,
    width = 200,
    height = 60,
    color = { .4, .6, .4 } -- Starting color
}


-- list of User/App color-select Triggering buttons (rectangle objects) to place on screen
local buttonList = { userButton1, userButton2, userButton3 }


--=========================================================================================--
--[[ Note that the  'colorList' table  used at runtime uses named fields, to make the 
    operation of the code more readable, whereas the initial 'colorListData' definitions 
    in the config files have more of a simple flat format (CSV = comma separated values) 
    because it's usually easier to type in list data that way (or to edit in a 
    spreadsheet and export). 

    The runtime  'colorList'  table format ends up being an Array, with colorName & 'rgb' triples: 
    local colorList = { 
        { colorName = "red",  rgb = { 1, 0, 0 } },
        { colorName = "blue", rgb = { 0, 0, 1 } },
        etc... 
    }
    (The colorList table is an Array to preserve the order the user wants to display them in.) 
    (If your application needs to frequently access colors by Name, then you should create an 
    auxiliary hash table to map name to index number.)

    But the initial  'colorListData'  table can be basically any format you like, so long as 
    you customize the  formatColorList() conversion function.  By default we use a simple 
    "easy-entry" format which is basically a simple 'Flat' CSV list: 

    local colorListData = {
        'red',  1, 0, 0,
        'blue', 0, 0, 1,
        etc... 
    }
    This avoids having to type a lot of {}, and the CSV data can easily be exported from 
    a spreadsheet, or manipulated in a spreadsheet, etc. 
--]]


local colorList = { -- DEFAULT "test" color list... it's ok for later code to overwrite this.
    { colorName = "Test Colors", rgb = { 1, 1, 1 } },
    { colorName = "Red", rgb = { 1, 0, 0 } },
    { colorName = "Yellow", rgb = { 1, 1, 0 } },
    { colorName = "Magenta", rgb = { 1, 0, 1 } },
}
--[[ Above is the format the code actually uses internally, but it's 
    a pain to edit all that verbosity, so, below is an easier-to-type 
    format that is what I think people will prefer to use. 
    The function [CLS.]formatColorList() converts the format below 
    into the format above. 
--]]

local colorListData = { -- Flat list, 4 items per "line"
    "Test Colors", 1, 1, 1,
    "Red", 1, 0, 0,
    "Yellow", 1, 1, 0,
    "Magenta", 1, 0, 1,
    "Green", 0, 1, 0,
    "Cyan", 0, 1, 1,
    "Blue", 0, 0, 1,
    "dRed", .6, 0, 0,
    "dYellow", .6, .6, 0,
    "dMagenta", .6, 0, .6,
    "dGreen", 0, .6, 0,
    "dCyan", 0, .6, .6,
    "dBlue", 0, 0, .6,
}

--[[ Below is an example of a user's custom color list format. 
    To use a custom format, the user must define their own formatColorList() 
    to convert it to the libraries prescribed format. 
    It's a Flat list, 2 items per "line"
    Three (2 digit) hex values are stuck together: need to convert them to 3 RGB values. 
--]]
local colorHexList = {
    'FFFFFF', 'White',
    'F7F9F9', 'Snowflake',
    'EAEDEF', 'Whisp',
    'D0CFD7', 'Whale',
    'AFAFAF', 'Silver',
    '888F8D', 'Gravel',
    '9C8E8D', 'Felt',
    '6A7185', 'Bluesteel',
    '636268', 'Stone',
    '5A6050', 'Tin',
    '545365', 'Spirit',
    '595451', 'Gloom',
    '4C4C4C', 'Coal',
    '4D484F', 'Gabbro',
    '413C40', 'Asphalt',
    '3B3736', 'Ash',
    '332D25', 'Basalt',
    '302722', 'Scoria',
    '1A1A1B', 'Black',
    '0E1011', 'Pitch',
    '1F1A23', 'Night',
    '22263D', 'Depth',
    '471A43', 'Blackberry',
    '4C2A4F', 'Berry',
    '553348', 'Loulou',
    '6E235D', 'Lilac',
    '863290', 'Grape',
    '9778BE', 'Petal',
    '7F6195', 'Satin',
    '5C415D', 'Haunted',
    '735B77', 'Ghost',
    '8E7F9E', 'Lavender',
    'A794B2', 'Amethyst',
    'AA96A6', 'Dart',
    'E1CDFE', 'Pansy',
    'CCA4E0', 'Bubble',
    'DA4FFF', 'Plum',
    '9C50D3', 'Purple',
    '993BD1', 'Eggplant',
    '7930B5', 'Midnight',
    '5317B5', 'Urchin',
    '4D2C89', 'Jelly',
    '3F2B66', 'Smog',
    '0D0A5B', 'Sapphire',
    '2B0D88', 'Angler',
    '2D237A', 'Bluebell',
    '484AA1', 'Aster',
    '525195', 'Smoke',
    '4866D5', 'Uranus',
    '757ADB', 'Rain',
    '7895C1', 'Stream',
    '444F69', 'Harpy',
    '324BA9', 'Blue',
    '212B5F', 'Denim',
    '013485', 'Morpho',
    '023AE2', 'Raindrop',
    '1C51E7', 'Marine',
    '2F83FF', 'Ocean',
    '6394DD', 'Drip',
    '76A8FF', 'Cool',
    'AEC8FF', 'Sky',
    '89A4C0', 'Cloud',
    '556979', 'Aluminum',
    '2F4557', 'Iron',
    '263746', 'Dream',
    '0D1E25', 'Abyss',
    '0B2D46', 'Trench',
    '0A3D67', 'Twilight',
    '094869', 'Mountain',
    '2B768F', 'Azure',
    '0086CE', 'Shell',
    '00B4D5', 'Cerulean',
    'B3E1F1', 'Winter',
    '91FFF7', 'Glow',
    '00FFF1', 'Cyan',
    '3CA2A4', 'Turquoise',
    '3A8684', 'History',
    '8DBCB4', 'Spruce',
    '72C4C4', 'Water',
    '9AEAEF', 'Glass',
    'E2FFE6', 'Pistachio',
    'B3FFD8', 'Dolphin',
    '9AFFC7', 'Mint',
    'B2E2BD', 'Seafoam',
    'A6DBA7', 'Caterpillar',
    '61AB89', 'Jade',
    '148E67', 'Spearmint',
    '1F565D', 'Essence',
    '233253', 'Rainforest',
    '153F4B', 'Seaweed',
    '114D41', 'Algae',
    '1F483A', 'Forest',
    '005D48', 'Hydra',
    '20603F', 'Emerald',
    '236825', 'Shamrock',
    '66903C', 'Pear',
    '1E361A', 'Jungle',
    '1E2716', 'Swamp',
    '1F281D', 'Root',
    '425035', 'Snake',
    '51684C', 'Camo',
    '516760', 'Scale',
    '687F67', 'Ivy',
    '97AF8B', 'Mantis',
    'A7B08C', 'Micah',
    '9BFF9D', 'Pea',
    '03ff7d', 'Synthesizer',
    '87E34D', 'Malachite',
    '7ECE73', 'Fern',
    '7BBD5D', 'Stem',
    '629C3F', 'Green',
    '567C34', 'Grass',
    '8ECE56', 'Cactus',
    'A5E32D', 'Leaf',
    'C6FF00', 'Toxin',
    'CDFE6C', 'Uranium',
    '9FFF00', 'Corrosion',
    'E8FCB4', 'Peridot',
    'D1E572', 'Cabbage',
    'B4CD3D', 'Chartreuse',
    'A9A032', 'Prehistoric',
    '828335', 'Alligator',
    '697135', 'Olive',
    '4B4420', 'Murk',
    '7E7645', 'Bark',
    'C18E1B', 'Amber',
    'BEA55D', 'Sponge',
    'D1B045', 'Haze',
    'D1B300', 'Swallowtail',
    'FFE63B', 'Lemon',
    'F9E255', 'Wasp',
    'F7FF6F', 'Yolk',
    'FFEC80', 'Banana',
    'FDD68B', 'Honey',
    'FDE9AC', 'Squash',
    'EDE8B0', 'Sanddollar',
    'FFFDEA', 'Mellow',
    'FDF1E1', 'Lychee',
    'FFEFDC', 'Creme',
    'F7DEBF', 'Pelt',
    'FFD297', 'Ivory',
    'F6BF6C', 'Peanut',
    'F2AD0C', 'Gold',
    'FFB53C', 'Marigold',
    'FA912B', 'Apricot',
    'FF8500', 'Poppy',
    'FF984F', 'Yam',
    'FFA147', 'Orange',
    'FFB576', 'Peach',
    'FCC4AD', 'Silt',
    'F0B392', 'Sahara',
    'D5602B', 'Saffron',
    'B2560D', 'Bronze',
    'B24407', 'Sandstone',
    'FF5500', 'Carrot',
    'EF5C23', 'Fire',
    'FF6841', 'Pumpkin',
    'FF7360', 'Sunrise',
    'C15A39', 'Cinnamon',
    'C47149', 'Caramel',
    'B27749', 'Acorn',
    '9A7B4F', 'Tortilla',
    'C3996F', 'Hide',
    'CABBA2', 'Beige',
    '827A64', 'Pine',
    '6D675B', 'Soil',
    '564D48', 'Coffee',
    '3C3030', 'Cocoa',
    '766259', 'Chocolate',
    '977B6C', 'Cappuccino',
    'BFA18F', 'Beach',
    '8A6059', 'Gingerbread',
    '7A4D4D', 'Maple',
    '774840', 'Hazel',
    '6B3C34', 'Coconut',
    '603E3D', 'Clay',
    '57372C', 'Sable',
    '432711', 'Penny',
    '301E1A', 'Umber',
    '22110A', 'Brownie',
    '2F1B1B', 'Birch',
    '5A4534', 'Feldspar',
    '72573A', 'Walnut',
    '855B33', 'Grain',
    '91532A', 'Ginger',
    '90553A', 'Starfish',
    '8E5B3F', 'Brown',
    '563012', 'Slate',
    '7B3C1D', 'Auburn',
    'A44B28', 'Copper',
    '8B3220', 'Rust',
    'BA311C', 'Tomato',
    'E22D18', 'Vermillion',
    'CE000D', 'Pepper',
    'AA0024', 'Cherry',
    '850012', 'Crimson',
    '7A0E1E', 'Ruby',
    '581014', 'Garnet',
    '2D0102', 'Sanguine',
    '451717', 'Blood',
    '652127', 'Rose',
    '8C272D', 'Cranberry',
    'C1272D', 'Redwood',
    'DF3236', 'Strawberry',
    'fc6d68', 'Fruit',
    'B13A3A', 'Carmine',
    'A12928', 'Cerise',
    '9A534D', 'Brick',
    'CC6F6F', 'Coral',
    'FEA0A0', 'Blush',
    'FFE2E6', 'Macaron',
    'FFB7B4', 'Sakura',
    'FEA1B3', 'Flamingo',
    'FFE5E5', 'Peony',
    'FF839B', 'Ribbon',
    'c67a80', 'Charm',
    'EB799A', 'Candy',
    'FB5E79', 'Bubblegum',
    'DB518D', 'Watermelon',
    'E934AA', 'Magenta',
    'E7008B', 'Fuschia',
    'cb0381', 'Tulip',
    'aa004c', 'Rubellite',
    '8A024A', 'Raspberry',
    '4D0F28', 'Syrah',
    '9C4975', 'Mauve',
    'E77FBF', 'Gum',
    'E5A9FF', 'Quartz',
    'E8CCFF', 'Confetti',
    'FFD6F6', 'Petalite',
    'FBEDFA', 'Pearl',
}
--[[
    kmk: currently the canvas size of the list above is too big for android to handle! 
    I guess making a giant canvas is not very memory efficient. 

    Todo: re-implement it to generate the buttons dynamically as they scroll. 
    will take some effort... so do it later. 
    (implement it like side-scolling platformers do?)
    Determine what the max is for now. 
--]]



-- EXPORT Config data (for use by ColorListSelector.lua) --
--[[
    Store the Config Data needed externally (by ColorListSelector.lua) in a GLOBAL called 'CLSconfig' 
    (yeah, it's ugly to use a global, but I don't think Lua 5.1 could pass data as 
    extra arguments in require() calls yet.)
--]]
CLSconfig = { -- This is a GLOBAL var for now --
    UIcanvasData = UIcanvasData,
    colorsCanvasData = colorsCanvasData,
    buttonHeight = buttonHeight,
    buttonSpacing = buttonSpacing,
    buttonList = buttonList,
    colorList = colorList,
    colorListData = colorListData,
    colorHexList = colorHexList, -- (this Hex stuff is just an extra example.. not core content)
}


--[[ Return the module Data objects to be referenced by ColorListSelector:

    (This is in case future versions of Love2D use a later version of Lua that
    supports passing arguments in require() and this won't have to be a global anymore.)
--]]
return CLSconfig
