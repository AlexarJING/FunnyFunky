local loader={}


function loader.load(file)
	local raw={}
	for str in file:lines( ) do
		table.insert(raw,str)
	end
	loader.format(raw)
end

function loader.replace(str)
	local rt
	local c= string.find(str,",")
	if c then
		local p=string.find(str,":")
		local w=string.sub(str,p+1,-1)
		rt=string.sub(str,1,p-1).." = {"..string.gsub(w,"(%a+)%s*%p*(%a+)", "\"%1\" ,\"%2\"").."},"
	else
		rt=string.gsub(str, "(%a+)(%d*)%s*","\"%1%2\"")
		rt=string.gsub(rt,":","=")..","
	end
	return rt
end



function loader.format(raw)

	local luaStr={}
	luaStr[1]="local tab={\natlas=\""..loader.replace(raw[2]).."\",\n"
	
	local tab=false
	for i=3,#raw do
		if string.sub(raw[i],1,2)=="  " then
			table.insert(luaStr, loader.replace(raw[i]).."\n")
			tab=true
		else
			if tab then
				table.insert(luaStr, "},\n")
			end
			
			if string.find(raw[i],"images") then
				local w=string.gsub(raw[i], "images/(%d+)%s%((%d+)%)",  "images_%1[%2]={\n" )
				table.insert(luaStr,w)
			else
				table.insert(luaStr, loader.replace(raw[i]).."\n")
			end
			
			tab=false
		end
		
	end
	table.insert(luaStr, "},\n")
	table.insert(luaStr, "}; return tab\n")
	local rtStr=""
	for i,v in ipairs(luaStr) do
		rtStr=rtStr..v
	end
	
	local tab=loadstring(rtStr)()

end

--
--string.replace("images/1 (1)", "images/(\d+)\s*\((\d+)\)", "images[\1][\2]")

return loader