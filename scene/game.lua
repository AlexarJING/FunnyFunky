local scene = gamestate.new()

local json = spine.SkeletonJson.new()
json.scale = 0.3
local skeletonData = json:readSkeletonDataFile("res/bone/boy/spineboy.json")
local stateTab={}
local stateIndex=1
for k,v in pairs(skeletonData.animations) do
	table.insert(stateTab, v.name)
end

local skeleton = spine.Skeleton.new("boy",skeletonData)

skeleton.x = love.graphics.getWidth() / 4
skeleton.y = love.graphics.getHeight() / 4 + 250
skeleton.flipX = false
skeleton.flipY = false
skeleton.debugBones = true -- Omit or set to false to not draw debug lines on top of the images.
skeleton.debugSlots = true
skeleton:setToSetupPose()

-- AnimationStateData defines crossfade durations between animations.
local stateData = spine.AnimationStateData.new(skeletonData)
stateData:setMix("walk", "jump", 0.2)
stateData:setMix("jump", "run", 0.2)

-- AnimationState has a queue of animations and can apply them with crossfading.
local boy={}
boy.state=spine.AnimationState.new(stateData)
local state = boy.state
-- state:setAnimationByName(0, "test")
state:setAnimationByName(0, "walk", true)


state.onStart = function (trackIndex)
	print(trackIndex.." start: "..state:getCurrent(trackIndex).animation.name)
end
state.onEnd = function (trackIndex)
	print(trackIndex.." end: "..state:getCurrent(trackIndex).animation.name)
end
state.onComplete = function (trackIndex, loopCount)
	print(trackIndex.." complete: "..state:getCurrent(trackIndex).animation.name..", "..loopCount)
end
state.onEvent = function (trackIndex, event)
	print(trackIndex.." event: "..state:getCurrent(trackIndex).animation.name..", "..event.data.name..", "..event.intValue..", "..event.floatValue..", '"..(event.stringValue or "").."'")
end


function scene:init()
	print("ok")
end 

function scene:enter()
	
end

function scene:leave()
	
end


function scene:draw()
	love.graphics.setColor(255, 255, 255)
	skeleton:draw()
end

function scene:update(dt)
	state:update(dt)
	state:apply(skeleton)
	skeleton:updateWorldTransform()
end 

function scene:keypressed(key)
	if key=="space" then
		stateIndex=stateIndex+1
		if stateIndex>#stateTab then stateIndex=1 end
		state:addAnimationByName(0, stateTab[stateIndex], true)
	end
end

return scene