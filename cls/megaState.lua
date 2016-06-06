local states={}

states.idle={
	name="idle",
	relative={"walk","run","jump","attack_1","attack_2","attack_3"},
	onEnter = function(role) 
		role.skeletonState:setAnimationByName(0 ,"idle1", true)
 	end,
	condition = function(role) return not role.isMoving end 
}

states.walk={
	name="walk",
	relative={"run","jump","attack_1","attack_2","attack_3"},
	onEnter = function(role) 
		role.skeletonState:setAnimationByName(0 ,"move", true)
 	end,
	condition = function(role) 
		return role.isMoving and not role.isRunning
	end 
}

states.run={
	name="run",
	relative={"walk","jump"},
	onEnter = function(role) 
		role.skeletonState:setAnimationByName(0 ,"run", true)
 	end,
	condition = function(role) 
		return role.isRunning and role.isMoving
	end 
}

states.jump={
	name="jump",
	relative={},
	onEnter = function(role) 
		role.skeletonState:setAnimationByName(0 ,"jump", false)
 	end,
	condition = function(role) 
		return not role.onGround
	end 
}

states.attack_1={
	name="attack_1",
	relative={},
	onEnter = function(role) 
		role.skeletonState:setAnimationByName(0 ,"hita1", false).onEnd =function()
			role.isAttacking=false
		end
 	end,
	condition = function(role) 
		return role.isAttacking and role.attackLevel==1
	end	,
	onExit = function(role)
		role.attackLevel= 2
		if role.nextAttack then		
			role.isAttacking = true
		end
	end
}

states.attack_2={
	name="attack_2",
	relative={},
	onEnter = function(role) 
		role.skeletonState:setAnimationByName(0 ,"hitb1", false).onEnd =function()
			role.isAttacking=false
		end
		role.nextAttack=false
 	end,
	condition = function(role) 
		return role.isAttacking and role.attackLevel==2
	end,
	onExit = function(role)
		role.attackLevel= 3
		if role.nextAttack then
			role.isAttacking = true
		end
	end
}

states.attack_3={
	name="attack_3",
	relative={},
	onEnter = function(role) 
		role.skeletonState:setAnimationByName(0 ,"hitc1", false).onEnd =function()
			role.isAttacking=false
		end
		role.nextAttack=false
 	end,
	condition = function(role) 
		return role.isAttacking and role.attackLevel==3
	end,
	onExit = function(role)
		role.attackLevel= 1
		if role.nextAttack then		
			role.isAttacking = true
		end
	end
}
return states