local Wheels = {
	"DDR1st1.5Wheel",
	"DDR2ndMIXCLUBVERSiON2Wheel",
	"DDR3rdMixPlusWheel",
	"DDR4thMixPlusWheel"
}

if not Last then Last = 0 end

local function RandButNotLast()
	local Now
	while true do
		Now = math.random(1,4)
		if Now ~= Last then break end
	end
	Last = Now
	return Now
end

return Def.ActorFrame{
	LoadModule("Wheel."..Wheels[RandButNotLast()]..".lua")
}