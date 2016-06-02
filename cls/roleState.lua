local roleState=class("roleState")



function roleState:init(role)
	self.role=role
	self.stack={}
	self.currentState=nil
end

function roleState:switch(from,to)
	if from == to then return end
	self.stack[from]:onExit(to)
	self.currentState=self.stack[to]
	self.stack[to]:onEnter(from)
end

function roleState:addState(newState)
	self.stack[newState.name]=newState
	newState.roleState=self
end


function roleState:update()
	self.currentState:update()
end


return roleState