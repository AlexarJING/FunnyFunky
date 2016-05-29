require "lib/util"
coll=require "lib/HC"
--coll=require "lib/bump"
class=require "lib/middleclass"
spine=require "lib/spine-love.spine"
ui= require "lib/SUIT"
gamestate= require "lib/hump/gamestate"
tween= require "lib/tween"
delay= require "lib/delay"
input= require "lib/input"
stage= require "cls/stage"
Camera= require "lib/gamera"

function love.load() 
    state={}
    for _,name in ipairs(love.filesystem.getDirectoryItems("scene")) do
        state[name:sub(1,-5)]=require("scene."..name:sub(1,-5))
    end
    gamestate.registerEvents()
    gamestate.switch(state.test)
end

