-- LoadModule is by default included in 5.3, If people use 5.1 load 5.3's version manualy.
if not LoadModule then 
	function LoadModule(ModuleName,...)
	
		local Path = THEME:GetCurrentThemeDirectory().."Modules/"..ModuleName
	
		if not FILEMAN:DoesFileExist(Path) then
			Path = "Appearance/Themes/_fallback/Modules/"..ModuleName
		end
	
		if ... then
			return loadfile(Path)(...)
		end
		return loadfile(Path)()
	end
end

-- We hate using globals, So use 1 global table.
DDR = {}

function Actor:ForParent(Amount)
	local CurSelf = self
	for i = 1,Amount do
		CurSelf = CurSelf:GetParent()
	end
	return CurSelf
end

-- Change Difficulties to numbers.
DDR.DiffTab = { 
	["Difficulty_Beginner"] = 1,
	["Difficulty_Easy"] = 2,
	["Difficulty_Medium"] = 3,
	["Difficulty_Hard"] = 4,
	["Difficulty_Challenge"] = 5,
	["Difficulty_Edit"] = 6
}

-- Resize function, We use this to resize images to size while keeping aspect ratio.
function DDR.Resize(width,height,setwidth,sethight)

	if height >= sethight and width >= setwidth then
		if height*(setwidth/sethight) >= width then
			return sethight/height
		else
			return setwidth/width
		end
	elseif height >= sethight then
		return sethight/height
	elseif width >= setwidth then
		return setwidth/width
	else 
		return 1
	end
end

-- TO WRITE DOC.
function DDR.CountingNumbers(self,NumStart,NumEnd,Duration)
	self:stoptweening()

	DDR.Cur = 1
	DDR.Count = {}
		
	local Length = (NumEnd - NumStart)/10
	if string.format("%.0f",Length) == "0" then Length = 1 end
	if string.format("%.0f",Length) == "-0" then Length = -1 end
	
	if not self:GetCommand("Count") then
		self:addcommand("Count",function(self) 
			self:settext(DDR.Count[DDR.Cur])
			DDR.Cur = DDR.Cur + 1 
		end)
	end
	
	for n = NumStart,NumEnd,string.format("%.0f",Length) do	
		DDR.Count[#DDR.Count+1] = string.format("%.0f",n)
		self:sleep(Duration/10):queuecommand("Count")
	end
	DDR.Count[#DDR.Count+1] = string.format("%.0f",NumEnd)
	self:sleep(Duration/10):queuecommand("Count")
end

-- Main Input Function.
-- We use this so we can do ButtonCommand.
-- Example: MenuLeftCommand=function(self) end.
function DDR.Input(self)
	return function(event)
		if not event.PlayerNumber then return end
		self.pn = event.PlayerNumber		
		if ToEnumShortString(event.type) == "FirstPress" or ToEnumShortString(event.type) == "Repeat" then
			self:queuecommand(event.GameButton)			
		end
		if ToEnumShortString(event.type) == "Release" then
			self:queuecommand(event.GameButton.."Release")	
		end
	end
end