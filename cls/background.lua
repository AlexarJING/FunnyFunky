local object = require "cls/object"
local bg= class("background",object)

function bg:init(stage,x,y,texture)
	self.class.super.init(self,stage,x,y,0,texture)
end



return bg