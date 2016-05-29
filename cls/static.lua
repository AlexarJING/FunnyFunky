local object = require "cls/object"
local static= class("static",object)

function static:init(stage,x,y,z,texture)
	self.class.super.init(self,stage,x,y,z,texture)
	
	
	
	self.aabbBody=stage.world:rectangle(
		self.x,self.y+self.z/4-self.th,
		self.tw,self.th)
	self.aabbBody.parent=self
	self.aabbBody.part="body"
	self.aabbHead=stage.world:rectangle(
		self.x,self.y+self.z/4-self.th-30,
		self.tw,30)
	self.aabbHead.parent=self
	self.aabbHead.part="head"

	self.aabbFoot=stage.world:rectangle(
		self.x,self.y+self.z/4-30,
		self.tw,30)
	self.aabbFoot.parent=self
	self.aabbFoot.part="foot"
	
	self.debug=true
end


function static:update(dt)

end


function static:draw()
	self.class.super.draw(self)
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabbBody:draw()
		self.aabbFoot:draw()
		self.aabbHead:draw()
	end
end

return static