local object=class("object")

function object:init(stage,x,y,z,texture)
	self.x=x
	self.y=y
	self.z= z
	self.r= 0
	self.sx=1
	self.sy =1
	self.texture = texture and love.graphics.newImage("res/img/"..texture..".png") 
	self.tw = texture and self.texture:getWidth()
	self.th = texture and self.texture:getHeight()
	self.stage= stage
	stage:addActor(self)
end

function object:update()

end

function object:destroy()
	self.stage:killActor(self)
end

function object:draw()
	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(255, 255, 255, 255)
	end
	if self.groundAline then
		love.graphics.draw(self.texture, self.x, self.y+0.5*self.z, self.r,
		 self.sx, self.sy, 
		 self.tw/2, self.th)
	else
		love.graphics.draw(self.texture, self.x, self.y+0.5*self.z, self.r,
		 self.sx, self.sy)
	end
end


return object