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
return function (role)
	local state=require ("cls/roleState") (role)
	local Action = require "cls/actionState"
	
	role.state =state
	local idle = Action(state,"idle",true) -- state , name , isdefault
	idle.relative={"walk","run","jump"}
	idle.onEnter = function()
		role.skeletonState:setAnimationByName(0, "idle", true)
	end


	local walk = Action(state , "walk")
	walk.relative={"run", "jump" ,"fall"}
	walk.onEnter = function()
		role.skeletonState:setAnimationByName(0, "move", true)
	end

	walk.condition= function()
		return (role.dx~=0 and math.abs(role.dx)<=role.speed/40) or (role.dz~=0 and math.abs(role.dz)<=role.speed/40)
	end


	local run = Action(state ,"run")
	run.relative={ "jump","walk","fall"}
	run.onEnter= function()
		role.skeletonState:setAnimationByName(0, "run", true)
	end

	run.condition= function()
		return math.abs(role.dx)>role.speed/40 or math.abs(role.dz)>role.speed/40
	end

	local jump = Action(state ,"jump")
	jump.relative={"fall"}
	jump.onEnter= function()
		role.skeletonState:setAnimationByName(0, "jump", true)
	end
	jump.condition=function()
		return (not role.onGround) and role.dy<0
	end

	local fall = Action(state ,"fall")
	fall.relative={}
	fall.onEnter= function()
		--role.skeletonState:setAnimationByName(0, "jump", true)
	end
	fall.condition=function()
		return (not role.onGround) and role.dy>=0
	end
end