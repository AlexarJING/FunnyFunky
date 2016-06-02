local actionState=class("actionState")

function actionState:init(roleState,name,isDefault)
	self.relative={}
	self.roleState=roleState
	self.name=name
	self.role= self.roleState.role
	if isDefault then 
		self.roleState.default=name 
		self.roleState.currentState=self
	end
	self.roleState:addState(self)
end

function actionState:onEnter(from)


end

function actionState:onExit(to)

end

function actionState:keypress()


end

function actionState:keydown()

end

function actionState:act()
	
end

function actionState:react()
	
end

function actionState:update()
	self:react()
	self:checkCondition()
	self:act()
end

function actionState:checkCondition()
	local stateStack=self.roleState.stack
	for i,stateName in ipairs(self.relative) do
		if stateStack[stateName]:condition() then
			self.roleState:switch(self.name,stateName)
			return
		end
	end
	if self:condition() then return end
	self.roleState:switch(self.name,self.roleState.default)
end


function actionState:condition()
	return true
end


return actionState