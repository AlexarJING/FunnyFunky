local object = require "cls/object"
local property= class("property",object)

function property:init(stage,x,y,z,texture)
	property.super.init(self,stage,x,y,z,texture)
	
	self.tl=30
	
	self.aabbBody=stage.world:rectangle(
		self.x,self.y+self.z/4-self.th,
		self.tw,self.th)
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
	
	self.debug=true
end


function property:update(dt)

end


function property:draw()
	self.class.super.draw(self)
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabbBody:draw()
		self.aabbFoot:draw()
		self.aabbHead:draw()
	end
end

return property