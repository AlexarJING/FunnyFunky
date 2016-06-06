local stage=class("stage")
function stage:init(name)
	self.name=name
	self.objects={}
	self.world=coll(300)
	--self.world=coll.newWorld()
	self.camera=Camera.new(0,-900,2200,1200)
	self.camera:setPosition(0,0)
end

function stage:setCameraFocus(target)
	self.focusTarget=target
end


function stage:update(dt)
	if self.focusTarget then 
		self.camera:setPosition(self.focusTarget.x,self.focusTarget.y+self.focusTarget.z/2)
	end
	for i=#self.objects,1,-1 do
		local obj=self.objects[i]
		if not obj.destroyed then
			obj:update(dt)
		end
		if obj.destroyed then
			table.remove(self.objects, i)
		end
	end
end


function stage:draw()
	self:sort(self.objects)
	self.camera:draw(function()
		for _,obj in ipairs(self.objects) do
			obj:draw()
		end
		love.graphics.setColor(0,255,0,255)
		love.graphics.line(-500,0,500,0)
		love.graphics.line(0,-500,0,500)
	end)
end

function stage:onKeyDown()


end

function stage:onKeyPress(key)
	
end

function stage:sort(tab)
	table.sort( tab, function(a,b) return a.z<b.z end)
end

function stage:addActor(actor)
	table.insert(self.objects,actor)
end

function stage:killActor(actor)
	table.remove(self.objects,table.getIndex(actor))
end

return stage