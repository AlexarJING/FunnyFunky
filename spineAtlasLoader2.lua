local loader={}


function loader.load(file)
	local raw={}
	for str in file:lines( ) do
		table.insert(raw,str)
	end
	loader.format(raw)
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

function loader.getIndex(str)
	local imageIndex=tonumber(string.sub(string.match(str,"/%d+"),2,-1))
	local spriteIndex=tonumber(string.sub(string.match(str,"%(%d+"),2,-1))
	return imageIndex,spriteIndex
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
			local imageIndex,spriteIndex=loader.getIndex(line)
			rtTable.images[imageIndex]=rtTable.images[imageIndex] or {}
			rtTable.images[imageIndex][spriteIndex]={}
			lastTable=rtTable.images[imageIndex][spriteIndex]
		end
	end
	print(table.save(rtTable))
	return rtTable
end


return loader