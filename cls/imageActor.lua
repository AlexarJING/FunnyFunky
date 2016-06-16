local imageActor=class("imageActor")

function imageActor:init(stage,x,y,z,texture)
	self.x=x
	self.y=y
	self.z= z
	self.r= 0
	self.sx=1
	self.sy =1	
	self.stage= stage
	stage:addActor(self)
	self.name=texture
	local t,r =pcall(love.graphics.newImage,"res/img/"..texture..".png")
	self.texture = t and r
	self.tw = self.texture and self.texture:getWidth()
	self.th = self.texture and self.texture:getHeight()
	self.stage= stage
	stage:addActor(self)
end

function imageActor:update()end

function imageActor:draw()

	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(255, 255, 255, 255)
	end
	love.graphics.setBlendMode("multiply")
	if self.texture then
		love.graphics.draw(self.texture, self.x+self.tw/2, self.y+self.z/4-self.th/2, self.r,
	 	self.sx, self.sy,self.tw/2,self.th/2)
	end
	love.graphics.setBlendMode("alpha")
end


return imageActor