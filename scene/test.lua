local scene = gamestate.new()
local stage = require "cls/stage"("test")
local bg = require "cls/background"
local static = require "cls/static"
local player = require "cls/player"

function scene:init()
	local cat =  bg(stage,0,0,"cat")
	local cat2 = static(stage, 300,0,300,"cat")
	local hero = player(stage, 500,0,300,"cat")
end 

function scene:enter()
	
end

function scene:leave()
	
end


function scene:draw()
	stage:draw()
end

function scene:update(dt)
	stage:update(dt)
end 



function scene:keyDown()

end


function scene:keypressed(key)
	
end


return scene