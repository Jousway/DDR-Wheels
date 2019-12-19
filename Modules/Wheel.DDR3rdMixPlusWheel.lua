local DiffColors={color("#88ffff"), color("#ffff88"), color("#ff8888"), color("#88ff88"), color("#8888ff"), color("#888888")}
local DiffNames={"Easy", "Basic", "Another", "Maniac", "Extra", "Edit"}

local WheelOffset = 302.4

if not CurSong then CurSong = 1 end
if not Joined then Joined = {} end
local CDOffset = 1
local CDSwitch = 11

local function MoveSelection(self,offset,Songs)
	CurSong = CurSong + offset
	if CurSong > #Songs then CurSong = 1 end
	if CurSong < 1 then CurSong = #Songs end
	
	CDOffset = CDOffset + offset
	if CDOffset > 21 then CDOffset = 1 end
	if CDOffset < 1 then CDOffset = 21 end
		
	CDSwitch = CDSwitch + offset
	if CDSwitch > 21 then CDSwitch = 1 end
	if CDSwitch < 1 then CDSwitch = 21 end
	
	local CDMoveBack = CDSwitch
	CDMoveBack = CDMoveBack + (offset*-1)
	if CDMoveBack > 21 then CDMoveBack = 1 end
	if CDMoveBack < 1 then CDMoveBack = 21 end
		
	for i = 1,21 do
			self:GetChild("CDCon"):GetChild("CD"..i):linear(.1):addrotationz((WheelOffset/21)*offset):y(SCREEN_CENTER_Y-80):diffusealpha(1)
		if i == CDSwitch then
				self:GetChild("CDCon"):GetChild("CD"..i):addrotationz((WheelOffset/21)*2*offset):diffusealpha(0)
		end
		if i == CDMoveBack then
			self:GetChild("CDCon"):GetChild("CD"..i):addrotationz((WheelOffset/21)*2*offset)
		end
	end
	
	self.CDSwitch = CDSwitch
	
	self:GetChild("CDSel"):GetChild("CDHolder2"):GetChild("CD"):SetTarget(self:GetChild("CDCon"):GetChild("CD"..CDSwitch):GetChild("Container"):GetChild("CDHolder"))
	self:GetChild("CDSel"):GetChild("CDHolder1"):linear(0.1):y(-100)
	self:GetChild("CDSel"):GetChild("CDHolder2"):linear(0.1):y(0)
	self:sleep(.1):queuecommand("ChangeCD")
	self:GetChild("CDSel"):GetChild("CDHolder1"):sleep(0.000001):y(0)
	self:GetChild("CDSel"):GetChild("CDHolder2"):sleep(0.000001):y(-100)
		
	CDMoveBack = CDMoveBack + offset*2
	
	local ChangeOffset = CDOffset
	if offset > 0 then ChangeOffset = ChangeOffset + -1 end
	if ChangeOffset > 21 then CDOffset = 1 end
	if ChangeOffset < 1 then ChangeOffset = 21 end
	
	local pos = CurSong+(10*offset)
	if pos > #Songs then pos = (CurSong+(10*offset))-#Songs end
	if pos < 1 then pos = #Songs+(CurSong+(10*offset)) end
	
	if Songs[pos][1]:HasBanner() then
		self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):Load(Songs[pos][1]:GetBannerPath())
	else
		self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):Load(THEME:GetPathG("","white.png")) 
	end
	self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):setsize(512,160):SetCustomPosCoords(self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2-23,0,self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2-9,-80,-self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2+9,-80,-self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2+23,0):zoom(.4):y(-20)
	self:GetChild("Banner"):Load(Songs[CurSong][1]:GetBannerPath())
	self:GetChild("Banner"):zoom(DDR.Resize(self:GetChild("Banner"):GetWidth(),self:GetChild("Banner"):GetHeight(),(512/8)*5,(160/8)*5))
	
	self:GetChild("CDTitle"):Load(Songs[CurSong][1]:GetCDTitlePath())
	self:GetChild("CDTitle"):zoom(DDR.Resize(self:GetChild("CDTitle"):GetWidth(),self:GetChild("CDTitle"):GetHeight(),80,80))
	
	SOUND:StopMusic()
	SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
end

local function StartSelection(self,Songs)
	self:GetChild("CDSel"):GetChild("CDHolder1"):linear(.8):diffusealpha(0)
	self:GetChild("CDBGCon"):GetChild("CDBG"):linear(.8):diffusealpha(0)
	for i = 1,21 do
		if i == CDSwitch then
			self:GetChild("Con"):GetChild("CDSlice"..i):linear(.8):diffusealpha(0)
		else
			self:GetChild("CDCon"):GetChild("CD"..i):GetChild("Container"):GetChild("CDHolder"):linear(.8):y(-2560)
		end
	end
end


local CurDiff = 2

local function MoveDifficulty(self,offset,Songs)	
	
	CurDiff = CurDiff + offset
	
	if CurDiff > #Songs[CurSong] then CurDiff = 2 end
	if CurDiff < 2 then CurDiff = #Songs[CurSong] end


	for i = 1,8 do
		self:GetChild("Diffs"):GetChild("Feet"..i):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]]):diffusealpha(0)
	end
	
	local DiffCount = Songs[CurSong][CurDiff]:GetMeter()
	if DiffCount > 8 then  DiffCount = 8 end
	
	for i = 1,DiffCount do
		self:GetChild("Diffs"):GetChild("Feet"..i):diffusealpha(1):x(25*(i-((DiffCount/2)+.5)))
	end
	
	self:GetChild("Difficulty"):settext(DiffNames[DDR.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]])
end

return function(Style)

	local Songs = LoadModule("Songs.Loader.lua")(Style)
	local StartOptions = false
	
	local CDs = Def.ActorFrame{
		Name="CDCon"
	}
	
	local CDslice = Def.ActorFrame{
		Name="Con"
	}
	
	local CDSel = Def.ActorFrame{
		Name="CDSel"
	}
	
	for i = 1,21 do
		local pos = CurSong+i-11
		if pos > #Songs then pos = (CurSong+i-11)-#Songs end
		if pos < 1 then pos = #Songs+(CurSong+i-11) end
		
		CDslice[#CDslice+1] = Def.Sprite{
			Name="CDSlice"..i,
			Texture=Songs[pos][1]:GetBannerPath(),
			OnCommand=function(self)
				if not Songs[pos][1]:HasBanner() then self:Load(THEME:GetPathG("","white.png")) end
				self:setsize(512,160):SetCustomPosCoords(self:GetWidth()/2-23,0,self:GetWidth()/2-9,-80,-self:GetWidth()/2+9,-80,-self:GetWidth()/2+23,0):zoom(.4):y(-20)
			end
		}
		
		local ActiveCD = 11

		local CDHolder = Def.ActorFrame{
			Name="CDHolder",
			Def.ActorProxy {
				Name="CDBG",
				InitCommand=function(self)
					self:SetTarget(self:GetParent():GetParent():GetParent():GetParent():GetParent():GetChild("CDBGCon"):GetChild("CDBG")):zoom(.09)
				end
			}
		}
		
		for i2 = 1,18 do
			CDHolder[#CDHolder+1] = Def.ActorFrame{
				OnCommand=function(self)
					self:rotationz((360/18)*i2)
				end,
				Def.ActorProxy {
					InitCommand=function(self)
						self:SetTarget(self:GetParent():GetParent():GetParent():GetParent():GetParent():GetParent():GetChild("Con"):GetChild("CDSlice"..i)):zoom(0.4)
					end
				}
			}
		end
		CDs[#CDs+1] = Def.ActorFrame{ 
			Name="CD"..i,
			OnCommand=function(self)
				self:rotationz(180-((WheelOffset/21)*(i-11))):CenterX():y(SCREEN_CENTER_Y-80):rotationx(-52):SetFOV(80)
				if ActiveCD > i then self:addrotationz((WheelOffset/21)*2) end
				if ActiveCD < i then self:addrotationz((-WheelOffset/21)*2) end
			end,
			Def.ActorFrame{
				Name="Container",
				OnCommand=function(self) self:y(-220) end,
				CDHolder
			}
		}
	end

	for i = 0,1 do
		CDSel[#CDSel+1] = Def.ActorFrame{
			Name="CDHolder"..i+1,
			OnCommand=function(self) self:y(-100*i) end,
			Def.Quad{
				Name="CDQuad",
				OnCommand=function(self) self:zoomto(20,20):diffuse(0,0,0,1) end
			},
			Def.ActorProxy{
				Name="CD",
				InitCommand=function(self)
					self:SetTarget(self:GetParent():GetParent():GetParent():GetChild("CDCon"):GetChild("CD".. 11):GetChild("Container"):GetChild("CDHolder"))				
				end
			}
		}
		
	end

	local ArSel = Def.ActorFrame {
		Def.Sprite {
			Name="Inside",
			Texture=THEME:GetPathG("","ArrowIn.png"),
			ColourCommand=function(self) self:sleep(0.02):diffuse(0,0,1,.5):sleep(0.02):diffuse(1,1,1,.5):sleep(0.02):diffuse(1,0,0,.5) end
		}
	}
	
	for i = 0,1 do
		ArSel[#ArSel+1] = Def.Sprite {
			Texture=THEME:GetPathG("","ArrowOut.png"),
			OnCommand=function(self) self:xy(-10*i,-10*i):diffuse(i+.2,i+.2,i+.2,1) end
		}
	end	
	local Diff = Def.ActorFrame {
		Name="Diffs",
	}
	
	for i = 1,8 do
		Diff[#Diff+1] = Def.Sprite {
			Name="Feet"..i,
			Texture=THEME:GetPathG("","Feet.png"),
			InitCommand=function(self) self:zoomx(-.3):zoomy(.3):x(25*(i-4.5)) end
		}
	end
	
	return Def.ActorFrame{
		OnCommand=function(self) 
			SCREENMAN:GetTopScreen():AddInputCallback(DDR.Input(self))
			self:sleep(0.2):queuecommand("PlayCurrentSong")
			MoveDifficulty(self,0,Songs)
		end,
		PlayCurrentSongCommand=function(self)
			SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
		end,
		MenuLeftCommand=function(self) MoveSelection(self,1,Songs) MoveDifficulty(self,0,Songs)
			self:GetChild("Left"):GetChild("Inside"):stoptweening()
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
		end,
		MenuRightCommand=function(self) MoveSelection(self,-1,Songs) MoveDifficulty(self,0,Songs)
			self:GetChild("Right"):GetChild("Inside"):stoptweening()
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
			:queuecommand("Colour")
		end,
		MenuDownCommand=function(self) MoveDifficulty(self,1,Songs) end,
		MenuUpCommand=function(self) MoveDifficulty(self,-1,Songs) end,
		BackCommand=function(self) 
			if Joined[self.pn] then
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					GAMESTATE:UnjoinPlayer(self.pn)
					Joined[self.pn] = false
				else
					SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen") 
				end
			end
		end,
		StartCommand=function(self)
			if StartOptions then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
			end
			if Joined[self.pn] then 
				GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
				GAMESTATE:SetCurrentSong(Songs[CurSong][1])
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					GAMESTATE:SetCurrentStyle('versus')
					PROFILEMAN:SaveProfile(PLAYER_1)
					PROFILEMAN:SaveProfile(PLAYER_2)
					GAMESTATE:SetCurrentSteps(PLAYER_1,Songs[CurSong][CurDiff])
					GAMESTATE:SetCurrentSteps(PLAYER_2,Songs[CurSong][CurDiff])
				else
					GAMESTATE:SetCurrentStyle('single')
					PROFILEMAN:SaveProfile(self.pn)
					GAMESTATE:SetCurrentSteps(self.pn,Songs[CurSong][CurDiff])
				end
				StartOptions = true
				StartSelection(self,Songs)
				self:sleep(1):queuecommand("StartSong")
			else
				GAMESTATE:JoinPlayer(self.pn)
				GAMESTATE:LoadProfiles()
				Joined[self.pn] = true
			end			
		end,
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
		
		ChangeCDCommand=function(self)
			self:GetChild("CDSel"):GetChild("CDHolder1"):GetChild("CD"):SetTarget(self:GetChild("CDCon"):GetChild("CD"..self.CDSwitch):GetChild("Container"):GetChild("CDHolder"))
		end,
		
		Def.ActorFrame {
			Name="CDBGCon",
			OnCommand=function(self) self:zoom(0) end,
			Def.Sprite {
				Name="CDBG",
				Texture=THEME:GetPathG("","CDCon.png")
			}
		},
		CDslice..{OnCommand=function(self) self:zoom(0) end},
		CDs,
		CDSel..{OnCommand=function(self) self:zoom(6):CenterX():y(SCREEN_CENTER_Y+80) end},
		Def.Sprite{
			Name="Banner",
			Texture=Songs[CurSong][1]:GetBannerPath(),
			OnCommand=function(self)
				self:CenterX():y(SCREEN_CENTER_Y-60):zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),(512/8)*5,(160/8)*5))
			end				
		},
		Def.Sprite{
			Name="CDTitle",
			Texture=Songs[CurSong][1]:GetCDTitlePath(),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X+80,SCREEN_CENTER_Y+30):zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),80,80))
			end
		},
		Def.BitmapText{
			Name="Difficulty",
			Font="Common Normal",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-110)
			end
		},
		ArSel..{Name="Left", OnCommand=function(self) 
			self:xy(SCREEN_CENTER_X-160,SCREEN_CENTER_Y+50):rotationz(25):rotationx(-50):SetFOV(80):zoom(.2):GetChild("Inside"):diffuse(1,0,0,.5)
		end},
		ArSel..{Name="Right", OnCommand=function(self) 
			self:xy(SCREEN_CENTER_X+160,SCREEN_CENTER_Y+50):rotationz(-25):rotationx(-50):SetFOV(80):zoom(.2):zoomx(-.2):GetChild("Inside"):diffuse(1,0,0,.5)
		end},
		Diff..{OnCommand=function(self) self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+150) end}
	}
end