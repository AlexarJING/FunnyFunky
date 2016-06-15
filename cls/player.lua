local role = require "cls/role"
local player= class("player",role)

function player:init(stage,x,y,z,texture,subname)
	player.super.init(self,stage,x,y,z,texture,subname)
end

function player:keydown()
	if self.stickWorking then return end
	if not self.canMove then return end

	if love.keyboard.isDown("a") then
		self.dax = -self.speed 
	elseif love.keyboard.isDown("d") then
		self.dax = self.speed 
	else
		self.dax = 0
	end
	if  love.keyboard.isDown("w") then
		self.daz =  -self.speed
	elseif  love.keyboard.isDown("s") then
		self.daz =  self.speed
	else
		self.daz = 0
	end

	if  love.keyboard.isDown("lshift") then
		self.isRunning = true
	else
		self.isRunning = false
	end
end



function player:keypress(key)
	if key=="space" then self:jump() end
	if key=="f" then self:attack() end
end


function player:moveByStick(sx,sy)
	self.stickWorking=false
	if not self.canMove then return end
	if sx==sy and sy==0 then return end
	self.stickWorking = true
	if math.abs(sx)>0.8 or math.abs(sy)>0.8 then self.isRunning=true end
	if math.abs(sx)<0.3 then sx=0 end
	if math.abs(sy)<0.3 then sy=0 end
	
	self.dax = self.speed * math.sign(sx)
	self.daz = -self.speed * math.sign(sy)
end

function player:update(dt)
	self:keydown()
	player.super.update(self,dt)
end

return player