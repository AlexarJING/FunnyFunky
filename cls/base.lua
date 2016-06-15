local base=class("base")

function base:init(stage,x,y,z,texture)
	self.x=x
	self.y=y
	self.z= z
	self.r= 0
	self.sx=1
	self.sy =1	
	self.stage= stage
	stage:addActor(self)
end

function base:update()
end

function base:destroy()
	self.stage:killActor(self)
end

function base:draw()
end


return base