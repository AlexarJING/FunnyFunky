local loader={}


function loader.load(name)
	local file=love.filesystem.newFile("res/bone/"..name.."/"..name..".atlas", "r")
	loader.projName=name
	local raw={}
	for str in file:lines( ) do
		table.insert(raw,str)
	end
	local data=loader.format(raw)
	local batch=loader.batch(data)
	return data,batch
end

function loader.getKV(str)
	local p=string.find(str,":")
	local left=string.sub(str,1,p-1)
	local right=string.sub(str,p+1,-1)
	local key=string.match(left,"%w+")
	local eachRight={}
	for v in string.gmatch(right,"%w+") do
		if tonumber(v) then v=tonumber(v)
		elseif v=="true" then v=true 
		elseif v=="false" then v=false
		end
		table.insert(eachRight, v)
	end
	local value
	if #eachRight==1 then
		value=eachRight[1]
	else
		value=eachRight
	end
	return key,value
end

function loader.getFileName(str)
	return string.sub(str,string.find(str,"/")+1,-1)
end

function loader.format(raw)
	local lastTable
	local rtTable={}
	rtTable.images={}
	for i,line in ipairs(raw) do

		if string.find(line,"  ") then
			local key,value=loader.getKV(line)
			lastTable[key]=value
		elseif string.find(line,":") then
			local key,value=loader.getKV(line)
			rtTable[key]=value
		elseif string.find(line,".png") then
			rtTable.atlas=line
		elseif string.find(line,"%w") then
			local name=loader.getFileName(line)
			rtTable.images[name]={}
			lastTable=rtTable.images[name]
		end
	end
	return rtTable
end

function loader.batch(data)
	local batchData={}
	batchData.batch = love.graphics.newSpriteBatch(
		love.graphics.newImage("res/bone/"..loader.projName.."/"..data.atlas), 1000, "static")
	local sizex,sizey=unpack(data.size)
	batchData.sprite={}
	for name,v in pairs(data.images) do
		batchData.sprite[name]={
			quad = love.graphics.newQuad(v.xy[1], v.xy[2], v.size[1], v.size[2], sizex, sizey),
			rotate = v.rotate
		}	
	end
	return batchData
end

return loader