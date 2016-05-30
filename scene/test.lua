local scene = gamestate.new()
local stage = require "cls/stage"("test")
local bg = require "cls/background"
local static = require "cls/static"
local player = require "cls/player"
local joystick = require "cls/joystick"
local Button = require "cls/button"
local buttonA = Button(500,500,100,80,"jump")
local buttonB = Button(650,500,100,80,"action")

function scene:init()
	local cat =  bg(stage,0,0,"cat")
	local cat2 = static(stage, 300,0,0,"cat")

	cat2 = static(stage, 100,0,300,"cat")
	hero = player(stage, 500,0,0,"mega")
	joystick:new()
	buttonA.onClick=function(b)
		hero:jump()
	end
	buttonB.onClick=function(b)
		hero:fire()
	end
end 

function scene:enter()
	
end

function scene:leave()
	
end


function scene:draw()
	stage:draw()
	joystick:draw()
	buttonA:draw()
	buttonB:draw()
end

function scene:update(dt)
	stage:update(dt)
	joystick:update()
	hero:moveByStick(joystick.vx,joystick.vy)
	buttonA:update()
	buttonB:update()
end 



function scene:keyDown()

end


function scene:keypressed(key)
	hero:keypress(key)
end


return scene