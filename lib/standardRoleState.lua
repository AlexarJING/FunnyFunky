local states={}

states.idle={
	name="idle",
	relative={"walk","run","jump","attack_1","attack_2","attack_3"},
	onEnter = function(role) 
		role:playAnim("idle1",true)
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
	relative={"run","jump","attack_1","attack_2","attack_3"},
	onEnter = function(role) 
		role:playAnim("move",true)
 	end,
	condition = function(role) 
		return role.isMoving and not role.isRunning
	end 
}

states.run={
	name="run",
	relative={"walk","jump","attack_runReady"},
	onEnter = function(role) 
		role:playAnim("run",true)
 	end,
	condition = function(role) 
		return role.isRunning and role.isMoving
	end 
}

states.jump={
	name="jump",
	relative={"fall"},
	onEnter = function(role) 
		role:playAnim("jump1")
 	end,
	condition = function(role) 
		return not role.onGround and role.dy>0
	end

}

states.fall={
	name="fall",
	relative={},
	onEnter = function(role) 
		spine.play(role.currentAnim, "jump3", 
		go.PLAYBACK_LOOP_FORWARD,0)
 	end,
	condition = function(role) 
		return not role.onGround and role.dy<=0
	end,

	onExit = function(role) 
		spine.play(role.currentAnim, "jump1", 
		go.PLAYBACK_ONCE_FORWARD,0)
 	end
}

states.attack_runReady={
	name="attack_runReady",
	relative={"attack_runKick","attack_runRoll"},
	onEnter = function(role) 
		spine.play(role.currentAnim, "hitrunready", 
		go.PLAYBACK_ONCE_FORWARD,0.1,function() 
			role.hitRunReady=false
		end)
		role.lastKey=nil
 	end,
	condition = function(role) 
		return role.isAttacking and role.hitRunReady==true
	end	,
	onExit = function(role)
		
	end,
	onInput = function(self, action_id, action)
		self.lastKey=self.inputStack[1]
	end
}



states.attack_runKick={
	name="attack_runKick",
	relative={"attack_runEnd"},
	onEnter = function(role) 
		spine.play(role.currentAnim, "hitkick", 
		go.PLAYBACK_ONCE_FORWARD,0.1,function()
			role.isAttacking=false 
			role.hitRunEnd=true
		end)
		role.isAttacking=true
		role.dx= role.facingRight and 50 or -50
 	end,
	condition = function(role) 
		return role.isAttacking and role.hitRunReady==false
			and role.lastKey==hash("pause")
	end	,
	onExit = function(role)
		
	end,
	onInput = function(self, action_id, action)
		
	end
}

states.attack_runRoll={
	name="attack_runRoll",
	relative={"attack_runEnd"},
	onEnter = function(role) 
		spine.play(role.currentAnim, "hitgun", 
		go.PLAYBACK_ONCE_FORWARD,0.1,function()
			role.isAttacking=false
			role.hitRunEnd=true
		end)
		role.isAttacking=true
		role.dx= role.facingRight and 50 or -50
 	end,
	condition = function(role) 
		return role.isAttacking and role.hitRunReady==false
			and role.lastKey~=hash("pause")
	end	,
	onExit = function(role)
		
	end,
	onInput = function(self, action_id, action)
		
	end
}

states.attack_runEnd={
	name="attack_runEnd",
	relative={},
	onEnter = function(role) 
		spine.play(role.currentAnim, "hitrunend", 
		go.PLAYBACK_ONCE_FORWARD,0,function()
			role.hitRunEnd=false 
		end)	
 	end,
	condition = function(role) 
		return role.hitRunEnd
	end	,
	onExit = function(role)
		
	end,
	onInput = function(self, action_id, action)
		
	end
}

states.attack_1={
	name="attack_1",
	relative={},
	onEnter = function(role) 
		role:playAnim("hita1")
 	end,
	condition = function(role) 
		return role.isAttacking and role.attackLevel==1
	end	,
	onExit = function(role)
		role.attackLevel= 2
		if role.nextAttack then		
			role:attack()
		end
	end,
	onInput = function(self, action_id, action)
		
	end
}

states.attack_2={
	name="attack_2",
	relative={},
	onEnter = function(role) 
		role:playAnim("hita2")
 	end,
	condition = function(role) 
		return role.isAttacking and role.attackLevel==2
	end,
	onExit = function(role)
		role.attackLevel= 3
		if role.nextAttack then
			role:attack()
		end
	end,
	onInput = function(self,action_id, action)
		if action.pressed then
			--self:keyToJump(action_id)
			--self:keyToAttck(action_id)
		else
			--self:keyToMove(action_id)	
		end	
	end
}

states.attack_3={
	name="attack_3",
	relative={},
	onEnter = function(role) 
		role:playAnim("hitc2")
		
		role.dx= role.facingRight and 10 or -10
 	end,
	condition = function(role) 
		return role.isAttacking and role.attackLevel==3
	end,
	onExit = function(role)
		role.attackLevel= 1
		if role.nextAttack then		
			role:attack()
		end
	end,
	onInput = function(self, action_id, action)
		if action.pressed then
			--self:keyToJump(action_id)
			--self:keyToAttck(action_id)
		else
			--self:keyToMove(action_id)	
		end	
	end
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