local roleState=class("roleState")



function roleState:init()
	self.stack={}
	self.currentState="default"
end

function roleState:switch(from,to)
	from:onExit(to)
	self.currentState(to)
	to:onEnter(from)
end

function roleState:addState(newState)
	table.insert(self.stack, newState)
end


function roleState:update()
	self.currentState:update()
end


--[[
idle-----walk
		-run 
		-jump
		-attack1
		-attack2
		-defend
		-pick
		-fall
walk-----
		-run
		-jump
		-attack1
		-attack2
		-defend
		-pick
		-fall
		-turn#
run------stoppy
		-highJump  ==jump
		-rushAttack -- attack2_mid
		-push#
		-fall
jump-----fall
		-turn
		-wallStep
		-jumpAttack1
		-jumpAttack2
fall-----cushion#
		-wallStep ==jump
pick-----hold
		-lift
		-eat#
		-pocket#
		-use#
hold-----throw#
		-swing-----hold
lift-----throw#
		-drop#
attack1--attack1_mid#--attack1_fin#
attack2--attack2-prev#--attack2_mid#--attack2_fin#

]]


return roleState