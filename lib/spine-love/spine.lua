-------------------------------------------------------------------------------
-- Spine Runtimes Software License
-- Version 2.3
-- 
-- Copyright (c) 2013-2015, Esoteric Software
-- All rights reserved.
-- 
-- You are granted a perpetual, non-exclusive, non-sublicensable and
-- non-transferable license to use, install, execute and perform the Spine
-- Runtimes Software (the "Software") and derivative works solely for personal
-- or internal use. Without the written permission of Esoteric Software (see
-- Section 2 of the Spine Software License Agreement), you may not (a) modify,
-- translate, adapt or otherwise create derivative works, improvements of the
-- Software or develop new applications using the Software or (b) remove,
-- delete, alter or obscure any trademarks or any copyright, trademark, patent
-- or other intellectual property or proprietary rights notices on or in the
-- Software, including any copy thereof. Redistributions in binary or source
-- form must include this license and terms.
-- 
-- THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------
local path = "lib/spine-lua/"
spine = {}

spine.utils = require (path.."utils")
spine.SkeletonJson = require (path.."SkeletonJson")
spine.SkeletonData = require (path.."SkeletonData")
spine.BoneData = require (path.."BoneData")
spine.SlotData = require (path.."SlotData")
spine.IkConstraintData = require (path.."IkConstraintData")
spine.Skin = require (path.."Skin")
spine.RegionAttachment = require (path.."RegionAttachment")
spine.MeshAttachment = require (path.."MeshAttachment")
spine.SkinnedMeshAttachment = require (path.."SkinnedMeshAttachment")
spine.Skeleton = require (path.."Skeleton")
spine.Bone = require (path.."Bone")
spine.Slot = require (path.."Slot")
spine.IkConstraint = require (path.."IkConstraint")
spine.AttachmentType = require (path.."AttachmentType")
spine.AttachmentLoader = require (path.."AttachmentLoader")
spine.Animation = require (path.."Animation")
spine.AnimationStateData = require (path.."AnimationStateData")
spine.AnimationState = require (path.."AnimationState")
spine.EventData = require (path.."EventData")
spine.Event = require (path.."Event")
spine.SkeletonBounds = require (path.."SkeletonBounds")
spine.BlendMode = require (path.."BlendMode")

spine.utils.readFile = function (fileName, base)
	local path = fileName
	if base then path = base .. '/' .. path end
	return love.filesystem.read(path)
end

local json = require "lib.spine-love.dkjson"
spine.utils.readJSON = function (text)
	return json.decode(text)
end

spine.Skeleton.failed = {} -- Placeholder for an image that failed to load.

spine.Skeleton.new_super = spine.Skeleton.new
function spine.Skeleton.new (name,skeletonData, group)
	
	local self = spine.Skeleton.new_super(skeletonData)

	-- createImage can customize where images are found.
	function self:createImage (attachment)
		return love.graphics.newImage("res/bone/"..name.."/"..attachment.name .. ".png")
	end

	-- updateWorldTransform positions images.
	local updateWorldTransform_super = self.updateWorldTransform
	function self:updateWorldTransform ()
		updateWorldTransform_super(self)
		self.skeletonBB:update (self, true)
		if not self.images then self.images = {} end
		local images = self.images

		if not self.meshes then self.meshes ={} end
		local meshes = self.meshes

		if not self.attachments then self.attachments = {} end
		local attachments = self.attachments

		for i,slot in ipairs(self.drawOrder) do
			local attachment = slot.attachment
			if not attachment then
				images[slot] = nil
			elseif attachment.type == spine.AttachmentType.region then
				local image = images[slot]
				if image and attachments[image] ~= attachment then -- Attachment image has changed.
					image = nil
				end
				if not image then -- Create new image.
					image = self:createImage(attachment)
					if image then
						local imageWidth = image:getWidth()
						local imageHeight = image:getHeight()
						attachment.widthRatio = attachment.width / imageWidth
						attachment.heightRatio = attachment.height / imageHeight
						attachment.originX = imageWidth / 2
						attachment.originY = imageHeight / 2
					else
						print("Error creating image: " .. attachment.name)
						image = spine.Skeleton.failed
					end
					images[slot] = image
					attachments[image] = attachment
				end
			elseif attachment.type == spine.AttachmentType.mesh or
				attachment.type == spine.AttachmentType.skinnedmesh then

				local meshData= meshes[slot]
				if meshData and attachments[meshData] ~= attachment then
					meshData=nil
				end
				if not meshData then
					meshData={attachment=attachment,texture=self:createImage(attachment)}
					
					local vertices={}
					for i,v in ipairs(attachment.triangles) do
				
						local vertIndexX=v*2+1
						local vertIndexY=v*2+2
						table.insert(vertices,{
							attachment.vertices[vertIndexX],attachment.vertices[vertIndexY],
							attachment.uvs[vertIndexX],attachment.uvs[vertIndexY],
							255,255,255,255
							})

					end
					
					meshData.mesh = love.graphics.newMesh(vertices, "triangles")
					meshData.mesh:setTexture(meshData.texture)
					meshes[slot] = meshData
					attachments[meshData] = attachment
					attachment.mesh = meshData.mesh
				else
					local vertices={}
					for i,v in ipairs(attachment.triangles) do
		
						local vertIndexX=v*2+1
						local vertIndexY=v*2+2
						table.insert(vertices,{
							attachment.vertices[vertIndexX],attachment.vertices[vertIndexY],
							attachment.uvs[vertIndexX],attachment.uvs[vertIndexY],
							255,255,255,255
							})

					end
					for i,v in ipairs(vertices) do
						attachment.mesh:setVertex(i,v)
					end
					
				end

			elseif attachment.type == spine.AttachmentType.skinnedmesh then

			end
		end
	end

	function self:draw()
		if not self.images then self.images = {} end
		local images = self.images

		local r, g, b, a = self.r * 255, self.g * 255, self.b * 255, self.a * 255

		for i,slot in ipairs(self.drawOrder) do
			
			local attachment = slot.attachment
			if attachment.type==spine.AttachmentType.region then
				local image = images[slot]
				if image and image ~= spine.Skeleton.failed then
					
					local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
					local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
					local rotation = slot.bone.worldRotation + attachment.rotation
					local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
					local yScale = slot.bone.worldScaleY + attachment.scaleY - 1
					if self.flipX then
						xScale = -xScale
						rotation = -rotation
					end
					if self.flipY then
						yScale = -yScale
						rotation = -rotation
					end
					love.graphics.setColor(r * slot.r, g * slot.g, b * slot.b, a * slot.a)
					
					love.graphics.setBlendMode(spine.BlendMode[slot.data.blendMode] or "alpha")
					
					love.graphics.draw(image, 
						self.x + x, 
						self.y - y, 
						-rotation * 3.1415927 / 180,
						xScale * attachment.widthRatio,
						yScale * attachment.heightRatio,
						attachment.originX,
						attachment.originY,
						attachment.shearX,
						attachment.shearY)
				end
			elseif attachment.type== spine.AttachmentType.mesh 
				or attachment.type == spine.AttachmentType.weightedmesh then
				local meshData = self.meshes[slot]
				if meshData and meshData ~= spine.Skeleton.failed then
					local attachment = slot.attachment
					local x = slot.bone.worldX 
					local y = slot.bone.worldY 
					local rotation = slot.bone.worldRotation 
					local xScale = slot.bone.worldScaleX
					local yScale = slot.bone.worldScaleY
					if self.flipX then
						xScale = -xScale
						rotation = -rotation
					end
					if self.flipY then
						yScale = -yScale
						rotation = -rotation
					end
				
					love.graphics.setColor(r * slot.r, g * slot.g, b * slot.b, a * slot.a)
					
					love.graphics.setBlendMode(spine.BlendMode[slot.data.blendMode] or "alpha")
					
					love.graphics.draw(meshData.mesh, 
						self.x + x, 
						self.y - y, 
						-rotation * 3.1415927 / 180,
						xScale ,
						-yScale
						)
			
				end
			elseif attachment== spine.AttachmentType.skinnedmesh then

			end
			
		end

		-- Debug bones.
		if self.debugBones then
			for i,bone in ipairs(self.bones) do
				local xScale
				local yScale
				local rotation = -bone.worldRotation

				if self.flipX then
					xScale = -1
					rotation = -rotation
				else 
					xScale = 1
				end

				if self.flipY then
					yScale = -1
					rotation = -rotation
				else
					yScale = 1
				end

				love.graphics.push()
				love.graphics.translate(self.x + bone.worldX, self.y - bone.worldY)
				love.graphics.rotate(rotation * 3.1415927 / 180)
				love.graphics.scale(xScale, yScale)
				love.graphics.setColor(255, 0, 0)
				love.graphics.line(0, 0, bone.data.length, 0)
				love.graphics.setColor(0, 255, 0)
				love.graphics.circle('fill', 0, 0, 3)
				love.graphics.pop()
			end
		end

		-- Debug slots.
		if self.debugSlots then
			love.graphics.setColor(0, 0, 255, 128)
			for i,slot in ipairs(self.drawOrder) do
				local attachment = slot.attachment
				if attachment and attachment.type == spine.AttachmentType.region then
					local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
					local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
					local rotation = slot.bone.worldRotation + attachment.rotation
					local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
					local yScale = slot.bone.worldScaleY + attachment.scaleY - 1
					if self.flipX then
						xScale = -xScale
						rotation = -rotation
					end
					if self.flipY then
						yScale = -yScale
						rotation = -rotation
					end
					love.graphics.push()
					love.graphics.translate(self.x + x, self.y - y)
					love.graphics.rotate(-rotation * 3.1415927 / 180)
					love.graphics.scale(xScale, yScale)
					love.graphics.rectangle('line', -attachment.width / 2, -attachment.height / 2, attachment.width, attachment.height)
					love.graphics.pop()
				end
			end
		end
	end

	return self
end

local loader= require "lib/spineAtlasLoader"




function spine.newActor(name,x,y,rot,scale)
	local json = spine.SkeletonJson.new()
	json.scale = scale
	local data,batch
	if love.filesystem.exists("res/bone/"..name.."/"..name..".atlas") then
		data,batch=loader.load(name)
	end
	local skeletonData = json:readSkeletonDataFile("res/bone/"..name.."/"..name..".json")

	local skeleton = spine.Skeleton.new(name,skeletonData,batch)

	skeleton.x = x
	skeleton.y = y

	skeleton:setToSetupPose()

	local stateData = spine.AnimationStateData.new(skeletonData)
	local state=spine.AnimationState.new(stateData)

	local bb = spine.SkeletonBounds.new ()
	skeleton.skeletonBB=bb
	return skeleton,skeletonData,state,stateData,bb
end

return spine
