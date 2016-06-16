local scene = gamestate.new()
local Stage = require "cls/stage"
local static = require "cls/spineActor"
local player = require "cls/player"
local npc = require "cls/role"
local img = require "cls/imageActor"

local joystick = require "cls/joystick"()
local Button = require "cls/button"
local buttonA = Button(1100,500,100,80,"jump")
local buttonB = Button(1000,600,100,80,"action")

local debugfont  = love.graphics.newFont(12)

function scene:init()
	self.stage = Stage("test")
	local stage= self.stage
	
	local inner = static(stage,100,0,0,"scene","beijing")
	local mid = static(stage,100,0,10,"scene","zhongjing")
	local grass = static(stage,100,0,11,"scene","caopings")
	local outer1 = static(stage,100,0,800,"scene","qianjing1")
	local outer2 = static(stage,100,0,900,"scene","qianjing2")
	local outer3 = static(stage,100,0,1000,"scene","qianjing3")
	--local cat = img(stage,1000,0,500,"c33")
	
	hero = player(stage, 600,0,0,"role","mega")
	self.stage:setCameraFocus(hero)
	
	local n1 = npc(stage, 200,0,200,"role","mega")
    
    
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
	joystick:update()
	hero:moveByStick(joystick.vx,joystick.vy)
	buttonA:update()
	buttonB:update()
	self.stage:update(dt)
end 



function scene:keyDown()

end


function scene:keypressed(key)
	hero:keypress(key)
end


return scene