local Debug = true --调试模式
local spineActorSize=1

----------------------------------------------libs----------------------------
local spineActor= class("spineActor")

-------------------------------------------func----------------------------


function spineActor:init(stage,x,y,z,name,subname)
	self:initProperties(x,y,z,stage)
	self:initAnim(name,subname,x,y,z)
	
	self:initAABB()
end

function spineActor:initAnim(texture,subname,x,y,z)
	local skeleton,skeletonData,state,stateData = spine.newActor(texture,subname,x,y,z,spineActorSize)
	self.skeleton=skeleton
	self.animState=state
end

function spineActor:initProperties(x,y,z,stage)
	self.x=x
	self.y=y
	self.z= z
	self.r= 0
	self.sx=1
	self.sy =1	
	self.stage= stage
	stage:addActor(self)
	self.w=200
	self.h=300
	self.l=20

	self.debug=Debug
end

function spineActor:initAABB()
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

end


function spineActor:playAnim(name,loop,add,delay,speed)
	if add then
		self.currentAnim.loop = false
		self.currentAnim = self.animState:addAnimationByName (0, name, loop, delay or 0)
	else
		self.currentAnim = self.animState:setAnimationByName (0, name, loop)
	end
	self.currentAnim.timeScale=speed or 1
end



function spineActor:gohit(attacker,isHeavy)
	print("ok")
end




function spineActor:updateSkeleton(dt)

	self.animState:update(dt)
	self.animState:apply(self.skeleton)
	self.skeleton:updateWorldTransform()
end




function spineActor:update(dt)
		
	self:updateSkeleton(dt)
	
end


function spineActor:draw()
	
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabbBody:draw()
		self.aabbFoot:draw()
		self.aabbHead:draw()
	end
		
	self.skeleton:draw()
	
end

return spineActor