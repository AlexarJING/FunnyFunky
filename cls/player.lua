local object = require "cls/object"
local player= class("player",object)
local stateSystem = require "lib/roleState"
local states = require "cls/megaState"

local function getSlotPos(slot,s)
	local attachment = slot.attachment
	local ax,ay = attachment.x or 0,attachment.y or 0
	local ar = attachment.rotation or 0
	local asx = attachment.scaleX or 1
	local asy = attachment.scaleY or 1
	local x = slot.bone.worldX + ax* slot.bone.m00 + ay * slot.bone.m01
	local y = slot.bone.worldY + ax * slot.bone.m10 + ay * slot.bone.m11
	local rotation = slot.bone.worldRotation + ar
	local xScale = slot.bone.worldScaleX + asx - 1
	local yScale = slot.bone.worldScaleY + asy - 1
	if s.flipX then
		xScale = -xScale
		rotation = -rotation
	end
	if s.flipY then
		yScale = -yScale
		rotation = -rotation
	end
	return s.x +x ,s.y-y
end


function player:init(stage,x,y,z,texture)
	self.class.super.init(self,stage,x,y,z,texture)
	local skeleton,skeletonData,state,stateData = spine.newActor(texture,500,300,0,0.3)
	self.skeleton=skeleton
	self.skeletonState=state

	self.tw=70
	self.th=120
	self.tl=10
	
	self.debug=true
	self.speed=1

	self.comboCD = 2

	self.attackCD=0
	self.stateSystem = require "cls/megaState"
	
	self:initProperties()
	self:regState()
	self:aabbInit()
end

function player:initProperties()
	self.dx=0
    self.dy=0
    self.dz=0
	self.dax=0
	self.daz=0
	self.dag=0
	self.isRunning=false
	self.lastDownTime=0
	self.onGround=true
	self.comboTimer = self.comboCD
	self.attackLevel = 1
end

function player:regState()
	self.state = stateSystem.init(self)
	for name,action in pairs(states) do
		self.state:reg(action,name=="idle")
	end
	self.state:switch(nil , self.state.stack["idle"])
end


function player:aabbInit()
	local stage = self.stage
	self.aabbBody=stage.world:rectangle(
		self.x,self.y+self.z/4-self.th-self.tl,
		self.tw,self.th-self.tl)
	self.aabbBody.parent=self
	self.aabbBody.part="body"
	self.aabbHead=stage.world:rectangle(
		self.x,self.y+self.z/4-self.th-self.tl,
		self.tw,self.tl)
	self.aabbHead.parent=self
	self.aabbHead.part="head"

	self.aabbFoot=stage.world:rectangle(
		self.x,self.y+self.z/4-self.tl,
		self.tw,self.tl)
	self.aabbFoot.parent=self
	self.aabbFoot.part="foot"

	self.handLeft = self.skeleton:findSlot("62")
	local x,y=getSlotPos(self.handLeft,self.skeleton)
	self.aabbPunchLeft=stage.world:rectangle(x,y,50,50)
	self.aabbPunchLeft.parent=self
	self.aabbPunchLeft.part="pleft"
	self.aabbPunchLeft.enabled = false

	self.handRight = self.skeleton:findSlot("6")
	local x,y=getSlotPos(self.handRight,self.skeleton)
	self.aabbPunchRight=stage.world:rectangle(x,y,50,50)
	self.aabbPunchRight.parent=self
	self.aabbPunchRight.part="pright"
	self.aabbPunchLeft.enabled = false
end



function player:collTest()
	
	for shape, delta in pairs(self.stage.world:collisions(self.aabbBody)) do
       	if shape.part=="body" and math.abs(shape.parent.z-self.z)<math.abs(self.tl+shape.parent.tl) then
   			self:moveTo(self.x-self.dx,self.y,self.z-self.dz)
       	end
    end
end

function player:hitTest()
	if not self.isAttacking then return end

	if self.aabbPunchLeft.enabled then
		for shape, delta in pairs(self.stage.world:collisions(self.aabbPunchLeft)) do
	       	if shape.parent~=self and shape.part=="body" and 
	       		math.abs(shape.parent.z-self.z)<math.abs(self.tl+shape.parent.tl) then
	  			shape.parent:gotHit(self,false) 
	       	end
	    end
	end

	if self.aabbPunchRight.enabled then
		for shape, delta in pairs(self.stage.world:collisions(self.aabbPunchRight)) do
	       	if shape.parent~=self and shape.part=="body" and 
	       		math.abs(shape.parent.z-self.z)<math.abs(self.tl+shape.parent.tl) then
	  			shape.parent:gotHit(self,true) --isheavy
	       	end
	    end
	end

end

function player:gotHit(attacker,isHeavy)
	print("ok")
end


function player:applyG()
	local test=false
	for shape, delta in pairs(self.stage.world:collisions(self.aabbFoot)) do
       	
       	if shape.part=="foot" and math.abs(shape.parent.z-self.z)<math.abs(self.tl+shape.parent.tl)*3  then
   			self:moveTo(self.x+delta.x ,self.y,self.z+delta.y)
   		end

       	if shape.part=="head" and self.dy>=0 and math.abs(shape.parent.z-self.z)<math.abs(self.tl+shape.parent.tl)*3  then
       		if not self.onGround then
       			self:moveTo(self.x ,shape.parent.y-shape.parent.th,self.z)
       		end
   			test=true
       	end

    end

 
    if test then
    	self.onGround = true
    	self.dy = 0
    else
    	self.dy = self.dy + 0.5
    	if self.y + self.dy >= 0 then
    		self.y=0
    		self.dy=0
    		self.onGround=true
    	else
    		self.y=self.y+self.dy
    		self.onGround = false
    	end
    end

end


function player:applyToColl()
	self.aabbBody:moveTo(self.x+self.tw/2,self.y+self.z/4-self.th/2-self.tl/2)
	self.aabbHead:moveTo(self.x+self.tw/2,self.y+self.z/4-self.th-self.tl/2)
	self.aabbFoot:moveTo(self.x+self.tw/2,self.y+self.z/4-self.tl/2)
	
end



function player:unpdateSkeletonPos(dt)
	self.skeleton.flipX = not self.facingRight
	self.skeleton.x=self.x+self.tw/2
	self.skeleton.y=self.y+self.z/4
	self.skeletonState:update(dt)
	self.skeletonState:apply(self.skeleton)
	self.skeleton:updateWorldTransform()
	self.aabbPunchLeft:moveTo(getSlotPos(self.handLeft,self.skeleton))
	self.aabbPunchRight:moveTo(getSlotPos(self.handRight,self.skeleton))
end

function player:translate()
	local multiply = self.isRunning and 2 or 1
	
	self.dx = self.dx + self.dax*multiply
	self.dz = self.dz + self.daz*multiply
	
	self:applyG()

	self.dx=self.dx*0.8
	self.dz=self.dz*0.8

	if math.abs(self.dx)<0.1 then self.dx=0 end
	if math.abs(self.dz)<0.1 then self.dz=0 end
		

	if self.z+self.dz<=0 then 
		self.dz=0
		self.z = 0
	end

	if self.dx>0 then self.facingRight=true 
	elseif self.dx<0 then self.facingRight=false end


	if self.dx==0 and self.dy==0 and self.dz==0 then
		self.isMoving=false
	else
		self.isMoving=true
	end

	self.x = self.x + self.dx
	self.z = self.z + self.dz
	self.y = self.y + self.dy

	self.dax=0
	self.daz=0

	self:applyToColl()
end

function player:attackCombo(dt)
	if self.isAttacking then
		self.comboTimer = self.comboCD
	else
		self.comboTimer = self.comboTimer - dt
		if self.comboTimer < 0 then
			self.attackLevel=1
		end
	end
end

function player:update(dt)

	self:keydown(dt)
	self:attackCombo(dt)
		
	self:hitTest()
	self:collTest()
	self:translate()
	
	self:unpdateSkeletonPos(dt)
	self.state:update()
end



function player:moveTo(x,y,z)
	self.x=x
	self.y=y
	self.z=z
	self:applyToColl()
end



function player:jump()
	if not self.onGround then return end
	if self.isAttacking then return end
	if self.isRunning then
		self.dy = -12
	else
		self.dy = -8
	end
	
	self.onGround=false
	self.standingOnObject=false
end



function player:attack()	
	if self.isAttacking then			
		self.nextAttack = true
	else
		self.isAttacking = true
	end
	
end

function player:roate(dr)
	self.r=self.r+dr
	self.aabbB:setRotation(self.r)
end

function player:moveByStick(sx,sy)
	if sx==sy and sy==0 then return end
	if math.abs(sx)>0.5 or math.abs(sy)>0.5 then self.isRunning=true end
	
	
	self.dax = self.speed * math.sign(sx)
	self.daz = -self.speed * math.sign(sy)
	
end




function player:keydown(dt)
	
	
	if not self.isAttacking then

		if love.keyboard.isDown("a") then
			self.dax = -self.speed 
		end
		if love.keyboard.isDown("d") then
			self.dax = self.speed 
		end
		if  love.keyboard.isDown("w") then
			self.daz =  -self.speed
		end
		if  love.keyboard.isDown("s") then
			self.daz =  self.speed
		end

		if  love.keyboard.isDown("lshift") then
			self.isRunning = true
		else
			self.isRunning = false
		end

	end

end



function player:keypress(key)
	if key=="space" then self:jump() end
	if key=="f" then self:attack() end
end




function player:draw()
	
	self.class.super.draw(self)
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabbBody:draw()
		self.aabbFoot:draw()
		self.aabbHead:draw()
		self.aabbPunchRight:draw()
		self.aabbPunchLeft:draw()
	end
	self.skeleton:draw()

end

return player