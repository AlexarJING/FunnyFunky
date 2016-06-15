local joystick=class("joystick")

function joystick:init()
	self.working=false
	self.limit=50
	self.stickSize=30
end

function joystick:inBound()
	if  love.mouse.getX()< love.graphics.getWidth()/2 and
	 love.mouse.getY()> love.graphics.getHeight()/2 then
	 	return true
	end

end

function joystick:limitToRound()
	local dist=math.getDistance(self.cx,self.cy,self.sx,self.sy)
	if  dist>self.limit then
		local dx = (self.sx-self.cx)* self.limit/dist
		local dy = (self.sy-self.cy)* self.limit/dist
		self.sx= self.cx+(self.sx-self.cx)* self.limit/dist
		self.sy= self.cy+(self.sy-self.cy)* self.limit/dist
		self.cx=self.cx+(self.sx-self.cx)* self.limit/dist/10
		self.cy=self.cy+(self.sy-self.cy)* self.limit/dist/10
	end
end

function joystick:getValue()
	if self.working then 
		self.vx= (self.sx-self.cx)/self.limit
		self.vy= -(self.sy-self.cy)/self.limit
	else
		self.vx= 0
		self.vy= 0
	end

end

function joystick:update()
	

	if self.working then
		if not love.mouse.isDown(1) then
			self.cx=nil
			self.working=false
			return 
		end
		self.sx,self.sy = love.mouse.getPosition()
		self:limitToRound()
	else
		self.working=love.mouse.isDown(1) and self:inBound()
		if self.working  then	
			self.cx,self.cy = love.mouse.getPosition()
			self.sx,self.sy = self.cx, self.cy
		end
		
	end
	self:getValue()
end


function joystick:draw()
	if self.working then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.circle("line", self.cx, self.cy, self.limit)
		love.graphics.setColor(200, 200,200, 255)
		love.graphics.circle("fill", self.sx, self.sy, self.stickSize)
	end
	--love.graphics.print(string.format("axis x: %0.2f; axis y: %0.2f",self.vx,self.vy),100,100)
end

return joystick