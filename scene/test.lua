local scene = gamestate.new()
local Stage = require "cls/stage"
local bg = require "cls/background"
local static = require "cls/static"
local player = require "cls/player"
local npc = require "cls/npc"
local joystick = require "cls/joystick"
local Button = require "cls/button"
local buttonA = Button(1100,500,100,80,"jump")
local buttonB = Button(1000,600,100,80,"action")

local debugfont  = love.graphics.newFont(12)

function scene:init()
	self.stage = Stage("test")
	local stage= self.stage
	local bg =  bg(stage,0,300,"rexue")
	--local cat2 = static(stage, 300,0,0,"cat")
	--cat2 = static(stage, 100,0,300,"cat")
	hero = player(stage, 600,0,0,"mega")
	self.stage:setCameraFocus(hero)
	
	local n1 = npc(stage, 200,0,200,"mega")


	joystick:new()
	buttonA.onClick=function(b)
		hero:jump()
	end
	buttonB.onClick=function(b)
		hero:attack()
	end
end 

function scene:enter()
	
end

function scene:leave()
	
end


function scene:draw()
	self.stage:draw()
	joystick:draw()
	buttonA:draw()
	buttonB:draw()
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.setFont(debugfont)
	love.graphics.print("Mega State: "..hero.state.current.name, 100,100)
	love.graphics.print("isAttacking: "..tostring(hero.isAttacking), 100,130)
	love.graphics.print("attack level: "..tostring(hero.attackLevel), 100,160)
end

function scene:update(dt)
	self.stage:update(dt)
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