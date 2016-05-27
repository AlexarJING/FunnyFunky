local object = require "cls/object"
local bg= class("background",object)

function bg:init(stage,x,y,texture)
	self.x=x
	self.y=y
	self.z=0
	self.sx=1
	self.sy =1
	self.texture = texture and love.graphics.newImage("res/img/"..texture..".png") 

	self.stage= stage
	stage:addActor(self)

end

function bg:draw()
	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	love.graphics.draw(self.texture, self.x, self.y, 0,
		 self.sx, self.sy)
	
end

return bg