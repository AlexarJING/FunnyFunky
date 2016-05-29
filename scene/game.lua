local scene = gamestate.new()

local skeleton,skeletonData,state,stateData

function scene:init()
	skeleton,skeletonData,state,stateData = spine.newActor("boy",500,300,0,0.3)
	state:setAnimationByName(0, "idle", true)
	
end 

function scene:enter()
	
end

function scene:leave()
	
end


function scene:draw()
	love.graphics.setColor(255, 255, 255)
	skeleton:draw()
end
jumpSpeed=0
function scene:update(dt)
	if jumpSpeed<10 then
		skeleton.y=skeleton.y+jumpSpeed
		jumpSpeed=jumpSpeed+0.5
	end
	scene:keyDown()
	state:update(dt)
	state:apply(skeleton)
	skeleton:updateWorldTransform()
end 

local currentState="idle"

function scene:keyDown()
	local anydown=false
	if love.keyboard.isDown("a") then
		skeleton.x=skeleton.x-2
		skeleton.flipX=true
		anydown=true
	end
	if love.keyboard.isDown("d") then
		skeleton.x=skeleton.x+2
		skeleton.flipX=false
		anydown=true
	end
	if  love.keyboard.isDown("w") then
		skeleton.y=skeleton.y-2
		anydown=true
	end
	if  love.keyboard.isDown("s") then
		skeleton.y=skeleton.y+2
		anydown=true
	end


	if anydown then
		if currentState~="walk" then
			state:setAnimationByName(0, "walk", true)
			currentState="walk"
		end
	else
		if currentState~="idle" then
			state:setAnimationByName(0, "idle", true)
			currentState="idle"
		end
	end
end


function scene:keypressed(key)
	if key=="space" then
		state:setAnimationByName(0, "jump", false)
		jumpSpeed=-10
	end
end


return scene