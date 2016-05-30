local object = require "cls/object"
local player= class("player",object)

function player:init(stage,x,y,z,texture)
	self.class.super.init(self,stage,x,y,z,texture)
	local skeleton,skeletonData,state,stateData = spine.newActor(texture,500,300,0,0.3)
	self.skeleton=skeleton
	self.skeletonState=state
	self.tw=100
	self.th=200
	self.long=10
	self.aabbBody=stage.world:rectangle(
		self.x,self.y+self.z/4-self.th,
		self.tw,self.th)
	self.aabbBody.parent=self
	self.aabbBody.part="body"
	self.aabbHead=stage.world:rectangle(
		self.x,self.y+self.z/4-self.th-self.long,
		self.tw,self.long)
	self.aabbHead.parent=self
	self.aabbHead.part="head"

	self.aabbFoot=stage.world:rectangle(
		self.x,self.y+self.z/4-self.long,
		self.tw,self.long)
	self.aabbFoot.parent=self
	self.aabbFoot.part="foot"

	self.debug=true
	self.speed=300
	self.lastDownTime=0
	self.isRunning=false
	self.state="idle"
	self.dx=0
	self.dy=0
	self.dz=0
	self.ox=self.x
	self.oy=self.y
	self.oz=self.z
	self.speedy=0
	self.onGround=true
end

function player:collTest()
	

	for shape, delta in pairs(self.stage.world:collisions(self.aabbBody)) do
       	
       	if math.abs(shape.parent.z-self.z)<=60 and shape.part=="body" then
   			self:moveTo(self.x+self.dx,self.y,self.z)
       	end
    end
end

function player:checkOnGround()
	local test=false
	for shape, delta in pairs(self.stage.world:collisions(self.aabbFoot)) do
       	
       	if math.abs(shape.parent.z-self.z)<120 and shape.part=="foot" then
   			local offx=-self.dx
   			self:moveTo(self.x+(delta.x==0 and 0 or offx) ,self.y,self.z-(delta.y==0 and 0 or self.dz))
   			
   		end
       	if math.abs(shape.parent.z-self.z)<120 and shape.part=="head" and self.speedy>=0 then
       		if not self.onGround then
       			self:moveTo(self.x ,shape.parent.y-shape.parent.th,self.z)
       		end
   			test=true
       	end

    end

    if self.y==0 or test then 
    	self.onGround = true
    else
    	self.onGround = false
    end

end

local playerFilter = function(item, other)
  if other.name=="body" then return "slide"
  end
end

function player:applyToColl()

	self.aabbBody:moveTo(self.x+self.tw/2,self.y+self.z/4-self.th/2)
	self.aabbHead:moveTo(self.x+self.tw/2,self.y+self.z/4-self.th-self.long/2)
	self.aabbFoot:moveTo(self.x+self.tw/2,self.y+self.z/4-self.long/2)
end

function player:unpdateSkeletonState()
	if self.dx>0 then
		self.skeleton.flipX=false
	elseif self.dx<0 then
		self.skeleton.flipX=true
	end

	local changeState

	if self.dx==0 and self.dy==0 and self.dz==0 then
		changeState="idle"
		
	elseif not self.onGround then
		changeState="jump"

	elseif self.isRunning then
		changeState="run"
	else
		changeState="move"
	end

	if self.state~=changeState then
		if self.state=="fire" then
			self.skeletonState:addAnimationByName(0, changeState, false)
		else
			self.skeletonState:setAnimationByName(0, changeState, true)
			
		end
		self.state=changeState
	end

end

function player:unpdateSkeletonPos(dt)
	self.skeleton.x=self.x+self.tw/2
	self.skeleton.y=self.y+self.z/4
	self.skeletonState:update(dt)
	self.skeletonState:apply(self.skeleton)
	self.skeleton:updateWorldTransform()

end

function player:update(dt)
	self:keydown(dt)
	
	if self.onGround then
		self.speedy=0
	else
		self.speedy=self.speedy + 1.5 --重力
		self.y=self.y+self.speedy
		if self.y>0 then 
			self.y=0
			self.onGround=true
		end
		self:applyToColl()
	end

	self.dx=self.x-self.ox
	self.dy=self.y-self.oy
	self.dz=self.z-self.oz

	self:checkOnGround()

	
	
	self:unpdateSkeletonState()
	self:unpdateSkeletonPos(dt*2)
	self.ox=self.x
	self.oy=self.y
	self.oz=self.z
end

function player:move(dx,dy,dz)
	self.x=self.x+ (dx or 0)
	self.y=self.y+ (dy or 0)
	self.z=self.z+ (dz or 0)
	if self.z<0 then self.z=0 end
	self:applyToColl()
end

function player:moveTo(x,y,z)
	self.x=x
	self.y=y
	self.z=z
	self:applyToColl()
end



function player:jump()
	if not self.onGround then return end 
	self.speedy=-30
	self.onGround=false

end

function player:roate(dr)
	self.r=self.r+dr
	self.aabbB:setRotation(self.r)
end

function player:moveByStick(sx,sy)
	if sx==sy and sy==0 then return end
	if math.abs(sx)>0.5 or math.abs(sy)>0.5 then self.isRunning=true end
	
	self:move(
		self.speed* love.timer.getDelta()*sx*2,
		0,
		-self.speed* love.timer.getDelta()*sy*2)
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
			dx=dx*2
			dz=dz*2
			self.isRunning=true
		end
		self:move(dx,0,dz)

		self.lastDownKey = anydown
		
		if not self.isRunning then 
			self.lastDownTime = love.timer.getTime()
			self.lastKeyUp=false
		end
	else
		self.isRunning=math.abs(self.dx)>self.speed/60 or math.abs(self.dy)>self.speed/60
		if love.timer.getTime()-self.lastDownTime>0.2 then
			self.lastDownKey=nil
		end
		self.lastKeyUp=true
	end
	--print(self.isRunning)
end

function player:fire()
	self.state="hita1"
	self.skeletonState:setAnimationByName(1, "hita2", false)
end

function player:keypress(key)
	if key=="space" then self:jump() end
	if key=="f" then self:fire() end
end

function player:draw()
	love.graphics.setColor(255, 255, 255, 255)
	local text=string.format("%d, %d, %d",self.x,self.y,self.z)
	love.graphics.print(text,100,100)
	love.graphics.print(tostring(self.onGround),200,100)
	self.class.super.draw(self)
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabbBody:draw()
		self.aabbFoot:draw()
		self.aabbHead:draw()
	end
	self.skeleton:draw()

end

return player