local object = require "cls/object"
local player= class("player",object)

function player:init(stage,x,y,z,texture)
	self.class.super.init(self,stage,x,y,z,texture)
	self.centered=true
	self.aabb=stage.world:rectangle(self.x-self.tw/2,self.y-self.th,self.tw,self.th)
	self.aabb.parent=self
	self.groundAline=true
	self.debug=true
	self.speed=100
	self.lastDownTime=0
	self.isRunning=false
	self.state="idle"
end

function player:collTest()

	for shape, delta in pairs(self.stage.world:collisions(self.aabb)) do
       	if math.abs(shape.parent.z-self.z)<100 then
       		self:move(delta.x,delta.y)
       	end
    end
end


function player:update(dt)
	self:keydown(dt)
	self:collTest()
end

function player:move(dx,dz)
	self.x=self.x+dx
	self.z=self.z+dz
	if self.z<0 then self.z=0 end
	self.aabb:moveTo(self.x,self.y)
end

function player:jump()


end

function player:roate(dr)
	self.r=self.r+dr
	self.aabb:setRotation(self.r)
end

function player:keydown(dt)
	
	local anydown=false
	local dx=0;local dz=0
	if love.keyboard.isDown("a") then
		dx=-self.speed*dt
		anydown="a"
	end
	if love.keyboard.isDown("d") then
		dx=self.speed*dt
		anydown="d"
	end
	if  love.keyboard.isDown("w") then
		dz=-self.speed*dt
		anydown="w"
	end
	if  love.keyboard.isDown("s") then
		dz=self.speed*dt
		anydown="s"
	end

	if anydown then
		local doublePress
		if self.lastDownKey==anydown and self.lastKeyUp then
			doublePress=true
		else
			self.lastDownKey=nil
		end
		if  doublePress or self.isRunning then
			dx=dx*4
			dz=dz*4
			self.isRunning=true
		end
		self:move(dx,dz)

		self.lastDownKey = anydown
		
		if not self.isRunning then 
			self.lastDownTime = love.timer.getTime()
			self.lastKeyUp=false
		end
	else
		self.isRunning=false
		if love.timer.getTime()-self.lastDownTime>0.5 then
			self.lastDownKey=nil
		end
		self.lastKeyUp=true
	end
	--print(self.isRunning)
end

function player:keypress()


end

function player:draw()
	self.class.super.draw(self)
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabb:draw("line")
	end
end

return player