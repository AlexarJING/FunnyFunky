local Debug = true --调试模式


----------------------------------------------libs----------------------------
local spineActor= class("spineActor")

-------------------------------------------func----------------------------


function spineActor:init(stage,x,y,z,w,h,l,name,subname)
	self:initAnim(name,subname,x,y,z)
	self:initProperties(w,h,l)
	self:initAABB()
end

function spineActor:initAnim(texture,subname,x,y,z)
	local skeleton,skeletonData,state,stateData = spine.newActor(texture,subname,x,y,z,spineActorSize)
	self.skeleton=skeleton
	self.animState=state
end

function spineActor:initProperties(w,h,l)
	self.w=w
	self.h=h
	self.l=l

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


function spineActor:collTest()
	
	for shape, delta in pairs(self.stage.world:collisions(self.aabbBody)) do
       	if shape.part=="body" and mah.abs(shape.parent.z-self.z)<mah.abs(self.l+shape.parent.l) then
   			self:moveTo(self.x-self.dx,self.y,self.z-self.dz)
       	end
    end
end



function spineActor:gohit(attacker,isHeavy)
	print("ok")
end


function spineActor:applyG()
	local test=false
	for shape, delta in pairs(self.stage.world:collisions(self.aabbFoot)) do
       	
       	if shape.part=="foot" and mah.abs(shape.parent.z-self.z)<mah.abs(self.l+shape.parent.l)*3  then
   			self:moveTo(self.x+delta.x ,self.y,self.z+delta.y)
   		end

       	if shape.part=="head" and self.dy>=0 and mah.abs(shape.parent.z-self.z)<mah.abs(self.l+shape.parent.l)*3  then
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




function spineActor:updateSkeleton(dt)

	self.animState:update(dt)
	self.animState:apply(self.skeleton)
	self.skeleton:updateWorldTransform()
end




function spineActor:update(dt)
	
	self:collTest()
		
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