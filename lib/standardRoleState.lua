local states={}


----- role:playAnim(name,loop,add,delay,speed)
states.idle={
	name="idle",
	relative={"walk","run","jump","attack"},
	onEnter = function(role) 
		role:playAnim("idle1",true , true)
 	end,
	condition = function(role) return not role.isMoving end,
}

states.turn={
	name="turn",
	relative={},
	onEnter = function(role) 
		role:playAnim("idleturn")
 	end,
	condition = function(role) return role.isTurning end 
}

states.walk={
	name="walk",
	relative={"run","jump","attack"},
	onEnter = function(role) 
		role:playAnim("move",true)
 	end,
	condition = function(role) 
		return role.isMoving and not role.isRunning
	end 
}

states.run={
	name="run",
	relative={"runjerk","jump","attack_runReady"},
	onEnter = function(role) 
		role:playAnim("run",true)
 	end,
	condition = function(role) 
		return role.isRunning and role.isMoving
	end 
}

states.runjerk={
	name="runjerk",
	relative={"jump","attack_runReady"},
	onEnter = function(role) 
		role:playAnim("runjerk")
 	end,
	condition = function(role)
		local isTurning = role.dx>0 and role.dax<0 or role.dx<0 and role.dax>0
		return isTurning
	end 
}

states.jump={
	name="jump",
	relative={"fall","jumpAttack"},
	onEnter = function(role) 
		role:playAnim("jump1")
		role:playAnim("jump2",false,true,0,1)
 	end,
	condition = function(role) 
		return not role.onGround
	end

}

states.jumpAttack={
	name="jumpAttack",
	relative={},
	onEnter = function(role) 
		role:playAnim("hitjump")
		role.dy=-2
 	end,
	condition = function(role) 
		return not role.onGround and role.isAttacking
	end,
	onExit = function(role)
		role.isAttacking = false
	end
}


states.fall={
	name="fall",
	relative={"jumpAttack"},
	onEnter = function(role) 
		role:playAnim("jump3")
 	end,
	condition = function(role) 
		return not role.onGround and role.dy>0
	end,

	onExit = function(role) 
		role:playAnim("jump4")
 	end
}

states.attack_runReady={
	name="attack_runReady",
	relative={"attack_runKick","attack_runRoll","attack_runChan"},
	onEnter = function(role) 
		role:playAnim("hitrunready")
		role.currentAnim.onEnd= function()
			role.hitRunReady=false
		end
		role.canMove=false
 	end,
	condition = function(role) 
		return role.hitRunReady
	end
}

states.attack_runChan={
	name="attack_runChan",
	relative={"attack_runEnd"},
	onEnter = function(role) 
		role:playAnim("hitchan")
		role.currentAnim.onEnd= function()
			role.isAttacking=false 
			role.hitRunEnd=true
		end
		role.isAttacking=true
 	end,
	condition = function(role) 
		return role.isAttacking or role.hitRunReady==false
	end
}

states.attack_runKick={
	name="attack_runKick",
	relative={"attack_runEnd"},
	onEnter = function(role) 
		role:playAnim("hitkick")
		role.currentAnim.onEnd= function()
			role.isAttacking=false 
			role.hitRunEnd=true
		end
		role.isAttacking=true
 	end,
	condition = function(role) 
		return role.isAttacking or (role.hitRunReady==false and love.keyboard.isDown("w"))
	end
}

states.attack_runRoll={
	name="attack_runRoll",
	relative={"attack_runEnd"},
	onEnter = function(role) 
		role:playAnim("hitgun",true)
		role.currentAnim.onEnd= function()
			role.isAttacking=false 
			role.hitRunEnd=true
		end
		role.isAttacking=true
 	end,
	condition = function(role)
		if not love.keyboard.isDown("left") then
			role.hitRunEnd=true
			return true
		end
		return role.isAttacking  
		or (role.hitRunReady==false and love.keyboard.isDown("s"))
	end	,
}

states.attack_runEnd={
	name="attack_runEnd",
	relative={},
	onEnter = function(role) 
		role:playAnim("hitrunend")
		role.currentAnim.onEnd= function()
			role.hitRunEnd = false
		end
		role.canMove=true
 	end,
	condition = function(role) 
		return role.hitRunEnd
	end
}

states.attack={
	name="attack",
	relative={"attack_next"},
	onEnter = function(role) 
		if role.nextAttack then
			
			role.currentAnim.onEnd = function()
				role.nextAttack=false
				role:enableAttackZone(false)
				role.canMove = true
				role:attackLevelUp()
				role.canAttack = false
			end
			role:playAnim(role.attackSlot[role.attackLevel] or role.attackSlot[1])
		else
			role:playAnim(role.attackSlot[role.attackLevel] or role.attackSlot[1] )
		end
		role.currentAnim.onEnd= function()
			role.isAttacking=false
			role:enableAttackZone(false)
			role.canMove = true
			role.canAttack = true
		
			role:attackLevelUp()
		end
		role.isAttacking = true
		role.canAttack = false
		role.canMove = false
 	end,
	condition = function(role) 
		return role.isAttacking
	end,
}

states.attack_next={
	name="attack_next",
	relative={},
	onEnter = function(role)

		role:switchState("attack")
 	end,
	condition = function(role)
		return role.isAttacking and role.nextAttack and role.canAttack
	end	,
}



states.attacked_front_light={
	name="attacked_front_light",
	relative={},
	onEnter = function(role) 
		spine.play(role.currentAnim, "behit1", 
		go.PLAYBACK_ONCE_FORWARD,0,function()
			role.isAttacked=true 
		end)
 	end,
	condition = function(role) 
		return role.isAttacked
	end,
	
	onInput = function(self, action_id, action)
		
	end
}

states.attacked_front_Heavy={
	name="attacked_front_light",
	relative={},
	onEnter = function(role) 
		spine.play(role.currentAnim, "behit2", 
		go.PLAYBACK_ONCE_FORWARD,0,function()
			role.isAttacked=true 
		end)
 	end,
	condition = function(role) 
		return role.isAttacked
	end,
	
	onInput = function(self, action_id, action)
		
	end
}

states.attacked_back_light={
	name="attacked_back_light",
	relative={},
	onEnter = function(role) 
		spine.play(role.currentAnim, "behit4", 
		go.PLAYBACK_ONCE_FORWARD,0,function()
			role.isAttacked=true 
		end)
 	end,
	condition = function(role) 
		return role.isAttacked
	end,
	
	onInput = function(self, action_id, action)
		
	end
}

states.attacked_back_heavy={
	name="attacked_back_heavy",
	relative={},
	onEnter = function(role) 
		spine.play(role.currentAnim, "behit5", 
		go.PLAYBACK_ONCE_FORWARD,0,function()
			role.isAttacked=true 
		end)
 	end,
	condition = function(role) 
		return role.isAttacked
	end,
	
	onInput = function(self, action_id, action)
		
	end
}
return states