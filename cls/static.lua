local object = require "cls/object"
local static= class("static",object)

function static:init(stage,x,y,z,texture)
	self.class.super.init(self,stage,x,y,z,texture)
	self.groundAline=true
	self.aabb=stage.world:rectangle(
		self.x-self.tw/2, self.y-self.th/2,
		self.tw,self.th)
	self.aabb.parent=self
	self.debug=true
end


function static:update(dt)

end


function static:draw()
	self.class.super.draw(self)
	if self.debug then
		love.graphics.setColor(255, 0, 0, 255)
		self.aabb:draw("line")
	end
end

return static