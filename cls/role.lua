local Debug = true --调试模式
local RoleSize = 0.3 --人物比例尺
local RoleHeight = 120 --人物高度
local RoleWidth = 70 --人物宽度
local RoleLenth = 10 --人物厚度
local RoleSpeed = 0.5 --人物加速度
local RoleMaxSpeed = 8
local RoleWalkSpeed = 5


local AttackZoneWidth = 50 --攻击区域宽度
local AttackComboCD =0.5 --攻击连击冷却
local DamagedCD =0.3 --连续受击间隔

local SCENE_WIDTH=2000 --场景宽度
local SCENE_HEIGHT=2000 --场景高度
local SCENE_LENTH=500 --场景深度

local attackOrder={
	{"hita1","hita2","hitc2"},
	{"hitb1","hitb1","hitb1"},
	{"hita2","hita2","hitc3"},
	{"hita1","hita1","hitc1"}
}

----------------------------------------------libs----------------------------
local SpineActor = require "cls/spineActor"
local role= class("role",SpineActor)
local stateSystem = require "lib/roleStateSystem"
local states = require "lib/standardRoleState"
-------------------------------------------func----------------------------


function role:init(stage,x,y,z,name,subname)

	self:initAnim(name,subname,x,y,z)
	self:initProperties(x,y,z,stage)
	self:initState()
	self:initAABB()
end

function role:initAnim(name,subname,x,y,z)
	local skeleton,skeletonData,state,stateData = spine.newActor(name,subname,x,y,z,RoleSize)
	self.skeleton=skeleton
	self.animState=state
	self.currentAnim=self.animState:setAnimationByName (0, "idle1", true)
end

function role:initProperties(x,y,z,stage)
	self.x=x
	self.y=y
	self.z= z
	self.r= 0
	self.sx=1
	self.sy =1	
	self.stage= stage
	stage:addActor(self)


	self.w=RoleWidth
	self.h=RoleHeight
	self.l=RoleLenth

	self.debug=Debug
	self.comboCD = AttackComboCD

	self.speed=RoleSpeed
	self.dx=0
    self.dy=0
    self.dz=0
	self.dax=0
	self.daz=0
	self.day=0

	self.isRunning=false
	self.onGround=true

	self.comboTimer = self.comboCD
	self.attackLevel = 1
	self.comboStyle = 1
	self.attackOrder = attackOrder
	self.attackSlot= attackOrder[self.comboStyle]


	self.canMove = true
	self.canAttack = true
	self.canJump = true
end

function role:initState()
	self.stateSystem = stateSystem
	self.state = stateSystem.init(self)
	for name,action in pairs(states) do
		self.state:reg(action,name=="idle")
	end
	self:switchState("idle")
end

function role:initAABB()
	local stage = self.stage
	self.aabbBody=stage.world:rectangle(
		self.x,self.y+self.z/4-self.h-self.l,
		self.w,self.h-self.l)
	self.aabbBody.parent=self
	self.aabbBody.part="body"
	self.aabbHead=stage.world:rectangle(
		self.x,self.y+self.z/4-self.h-self.l,
		self.w,self.l)
	self.aabbHead.parent=self
	self.aabbHead.part="head"

	self.aabbFoot=stage.world:rectangle(
		self.x,self.y+self.z/4-self.l,
		self.w,self.l)
	self.aabbFoot.parent=self
	self.aabbFoot.part="foot"

	self.aabbLeft=stage.world:rectangle(
		self.x-self.w/2-AttackZoneWidth/2,self.y-self.h,AttackZoneWidth,self.h)
	self.aabbLeft.parent=self
	self.aabbLeft.part="left"
	self.aabbLeft.enabled = false

	self.aabbRight=stage.world:rectangle(
		self.x+self.w/2+AttackZoneWidth/2,self.y-self.h,AttackZoneWidth,self.h)
	self.aabbRight.parent=self
	self.aabbRight.part="right"
	self.aabbRight.enabled = false
end


function role:playAnim(name,loop,add,delay,speed)
	--print(name,loop,add)
	if add then
		self.currentAnim.loop = false
		self.currentAnim = self.animState:addAnimationByName (0, name, loop, delay or 0)
	else
		self.currentAnim = self.animState:setAnimationByName (0, name, loop)
	end
	self.currentAnim.timeScale=speed or 1
	self.currentAnim.onEvent = function(track,event)
		self:attackTiming(event.data.name)
	end
end


function role:collTest()
	--[[
	for shape, delta in pairs(self.stage.world:collisions(self.aabbBody)) do
       	if shape.part=="body" and math.abs(shape.parent.z-self.z)<math.abs(self.l+shape.parent.l) then
   			self:moveTo(self.x-self.dx,self.y,self.z-self.dz)
       	end
    end]]
end

function role:hitTest()
	if not self.isAttacking then return end

	if self.aabbLeft.enabled then
		for shape, delta in pairs(self.stage.world:collisions(self.aabbLeft)) do
	       	if shape.parent~=self and shape.part=="body" and 
	       		math.abs(shape.parent.z-self.z)<math.abs(self.l+shape.parent.l) then
	  			shape.parent:gotHit(self,false) 
	       	end
	    end
	end

	if self.aabbRight.enabled then
		for shape, delta in pairs(self.stage.world:collisions(self.aabbRight)) do
	       	if shape.parent~=self and shape.part=="body" and 
	       		math.abs(shape.parent.z-self.z)<math.abs(self.l+shape.parent.l) then
	  			shape.parent:gotHit(self,true) --isheavy
	       	end
	    end
	end

end

function role:gotHit(attacker,isHeavy)
	print("ok")
end


function role:applyG()
	local test=false
	for shape, delta in pairs(self.stage.world:collisions(self.aabbFoot)) do
       	
       --[[
       	if shape.part=="foot" and math.abs(shape.parent.z-self.z)<math.abs(self.l+shape.parent.l)*3  then
   			self:moveTo(self.x+delta.x ,self.y,self.z+delta.y)
   		end]]

       	if shape.part=="head" and self.dy>=0 and math.abs(shape.parent.z-self.z)<math.abs(self.l+shape.parent.l)*3  then
       		if not self.onGround then
       			self:moveTo(self.x ,shape.parent.y-shape.parent.h,self.z)
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


function role:applyToColl()
	self.aabbBody:moveTo(self.x+self.w/2,self.y+self.z/4-self.h/2-self.l/2)
	self.aabbHead:moveTo(self.x+self.w/2,self.y+self.z/4-self.h-self.l/2)
	self.aabbFoot:moveTo(self.x+self.w/2,self.y+self.z/4-self.l/2)
	self.aabbLeft:moveTo(self.x-AttackZoneWidth/2,self.y+self.z/4-self.h/2)
	self.aabbRight:moveTo(self.x+self.w+AttackZoneWidth/2,self.y+self.z/4-self.h/2)
end

function role:updateSkeleton(dt)
	self.skeleton.flipX = not self.facingRight
	self.skeleton.x=self.x+self.w/2
	self.skeleton.y=self.y+self.z/4
	self.animState:update(dt)
	self.animState:apply(self.skeleton)
	self.skeleton:updateWorldTransform()
end

function role:translate()
	if self.isRunning then
		self.dx = self.dx + self.dax
		self.dz = self.dz + self.daz
		
		if math.abs(self.dx)>RoleMaxSpeed then
			self.dx = math.sign(self.dx)*RoleMaxSpeed
		end

		if math.abs(self.dz)>RoleMaxSpeed then
			self.dz = math.sign(self.dz)*RoleMaxSpeed
		end
	else
		if math.abs(self.dx)>RoleWalkSpeed then
			self.dx=self.dx*0.97
		else
			self.dx = math.sign(self.dax)*RoleWalkSpeed
		end

		if math.abs(self.dz)>RoleWalkSpeed then
			self.dz=self.dz*0.97
		else
			self.dz = math.sign(self.daz)*RoleWalkSpeed
		end
	end

	if math.abs(self.dx)>RoleWalkSpeed or math.abs(self.dz)>RoleWalkSpeed then
		self.isRunning =true
	else
		self.isRunning = false
	end

	self:applyG()

	

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

	self:applyToColl()
end



function role:moveTo(x,y,z)
	self.x=x
	self.y=y
	self.z=z
	self:applyToColl()
end

function role:jump()
	if not self.canJump then return end
	if self.isRunning then
		self.dy = -10
	else
		self.dy = -8
	end
	
	self.onGround=false
	self.standingOnObject=false
end

function role:attackTiming(name)
	if name=="hittime" then
		self:enableAttackZone()
		self.canAttack = false
	elseif name=="chuangetime" then
		self.canAttack = true
	elseif name=="hittimeend" then
		self:enableAttackZone(false)
	end
end

function role:enableAttackZone(enable)
	if self.facingRight then
		self.aabbRight.enable=enable
		self.aabbLeft.enable=false
	else
		self.aabbRight.enable=false
		self.aabbLeft.enable=enable
	end
end



function role:attackCombo(dt)
	if self.isAttacking then
		self.comboTimer = self.comboCD
	else
		self.comboTimer = self.comboTimer - dt
		if self.comboTimer < 0 then
			self.attackLevel=1
		end
	end
end

function role:attackLevelUp()
	self.attackLevel = self.attackLevel + 1
	if not self.attackSlot[self.attackLevel] then
		self.attackLevel = 0
	end

end

function role:attack()
	if self.isRunning then
		self.hitRunReady=true
		return
	end
	if self.isAttacking then	
		self.nextAttack = true		
	else
		self.isAttacking = true
	end
	
end

function role:switchState(stateName)
	self.state:switch(nil , self.state.stack[stateName])
end


function role:update(dt)
	self:attackCombo(dt)

	self:translate()
		
	self:hitTest()
	self:collTest()
		
	self:updateSkeleton(dt)
	self.state:update()

	self.dax=0
	self.daz=0
end


function role:draw()
	
	role.super.draw(self)
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabbBody:draw()
		self.aabbFoot:draw()
		self.aabbHead:draw()
		self.aabbRight:draw()
		self.aabbLeft:draw()
	end
	self.skeleton:draw()

end

return role