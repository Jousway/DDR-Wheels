local DiffColors={color("#88ffff"), color("#ffff88"), color("#ff8888"), color("#88ff88"), color("#8888ff"), color("#888888")}
local DiffNames={"Practice", "Basic", "Trick", "Maniac", "Extra", "Edit"}

local SongPos = 1
if not CurSong then CurSong = 1 end
if not Joined then Joined = {} end
local CurRow = 1
local DiffPos = {1,1}
local UnlockedInput = true
local DiffSelection = false

local function ChangeSelection(self,offset,Songs)
	local OldRow = CurRow
	CurRow = CurRow + offset
	if CurRow > 2 then CurRow = 1 end
	if CurRow < 1 then CurRow = 2 end
		
	for i = 1,7 do
		local sleep = i
		local pos = CurSong+i
		local i2 = i
		
		if offset < 0 then 
			sleep = (i - 7)*offset 
			pos = pos - 8
			i2 = i2 - 8
		end
		
		if pos > #Songs then pos = (CurSong+i2)-#Songs end
		if pos < 1 then pos = #Songs+(CurSong+i2) end
		
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):Load(Songs[pos][1]:GetBannerPath())
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):zoom(DDR.Resize(self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):GetWidth(),self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("Banner"):GetHeight(),128,40))
		if Songs[pos][1]:HasBanner() then
			self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(0):zoom(0)
			self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(0):zoom(0)
		else
			self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("FallbackBanner"):diffusealpha(1):zoomto(128,40)
			self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):diffusealpha(1):zoom(.5)
			self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):GetChild("BannerText"):settext(Songs[pos][1]:GetDisplayMainTitle())
		end		
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):sleep(sleep/8):linear(.5):x(0)
		self:GetChild("Banners"):GetChild(OldRow..i):GetChild("BannerCon"):sleep((sleep/8)+.4):x(1280)
		
		self:GetChild("SliderCon"):GetChild("Slider"..i):linear(0.2):x(SCREEN_CENTER_X+(1280*(offset*-1))):sleep(0.00001):diffusealpha(0):x(SCREEN_CENTER_X+(1280*offset)):diffusealpha(1)
		self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):Load(Songs[pos][1]:GetBannerPath())
		self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):zoom(DDR.Resize(self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):GetWidth(),self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("Banner"):GetHeight(),256,80))
		
		self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("CurSong"):settext(pos.."/"..#Songs);
		
		for i3 = 1,6 do
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("Feet"):diffusealpha(0)
			self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("level"):diffusealpha(0)
			
			if #Songs[pos] > i3 then
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("Feet"):diffuse(DiffColors[DDR.DiffTab[Songs[pos][i3+1]:GetDifficulty()]])
				self:GetChild("SliderCon"):GetChild("Slider"..i):GetChild("DiffCon"):GetChild("DiffDisplay"..i3):GetChild("level"):diffuse(DiffColors[DDR.DiffTab[Songs[pos][i3+1]:GetDifficulty()]]):settext(Songs[pos][i3+1]:GetMeter())
			end
		end			
	end	
	
	self:sleep((7/8)+.5):queuecommand("UnlockInput")
end

local function MoveSelection(self,offset,Songs)
	UnlockedInput = false
	for i = 1,7 do
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):linear(0.1):x(0):stopeffect()
	end
	
	SongPos = SongPos + offset
	if SongPos < -2 then SongPos = 4 ChangeSelection(self,-1,Songs) end
	if SongPos > 4 then SongPos = -2 ChangeSelection(self,1,Songs) end
	CurSong = CurSong + offset
	if CurSong > #Songs then CurSong = 1 end
	if CurSong < 1 then CurSong = #Songs end
	
	for i = 1,7 do
		self:GetChild("SliderCon"):GetChild("Slider"..i):linear(.1):x(SCREEN_CENTER_X+(256*((i-3)+(SongPos*-1))))
	end
		
	self:GetChild("Banners"):GetChild(CurRow..SongPos+3):GetChild("BannerCon"):linear(.1):x(32):effectclock("Beat"):glowshift()
	self:GetChild("Title"):settext(Songs[CurSong][1]:GetDisplayMainTitle())
	SOUND:StopMusic()
	SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
	self:sleep(.2):queuecommand("UnlockInput")
end

local function StartSelection(self,Songs)
	UnlockedInput = false
	local offset = 0
	for i = SongPos+3,7 do
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):sleep(offset/8):linear(.5):x(-1280)
		offset = offset + 1
	end
	offset = SongPos+3
	for i = 1,SongPos+3 do
		self:GetChild("Banners"):GetChild(CurRow..i):GetChild("BannerCon"):sleep(offset/8):linear(.5):x(-1280)
		offset = offset - 1
	end
	for i = 1,#Songs[CurSong]-1 do
		if i > 5 then break end
		for i2 = 1,9 do
			self:GetChild("Diffs"):GetChild("Feet"..i..i2):sleep(.5):linear(.5):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]]):diffusealpha(.5)
		end
		for i2 = 1,Songs[CurSong][i+1]:GetMeter() do
			if i2 > 9 then break end
			self:GetChild("Diffs"):GetChild("Feet"..i..i2):diffusealpha(1)
		end
		if Joined[PLAYER_1] then
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."1"):GetChild("DiffCon"):sleep(.5):linear(.5):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."1"):GetChild("DiffName"):sleep(.5):linear(.5):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]]):settext(DiffNames[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
		end
		if Joined[PLAYER_2] then
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."2"):GetChild("DiffCon"):sleep(.5):linear(.5):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
			self:GetChild("Diffs"):GetChild("DiffSelector"..i.."2"):GetChild("DiffName"):sleep(.5):linear(.5):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]]):settext(DiffNames[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
		end
	end	
	self:sleep(1):queuecommand("DiffSelection")
end

local function MoveDifficulty(self,offset,Songs)	
	local pn = 1
	if self.pn == PLAYER_2 then pn = 2 end
	if Joined[self.pn] then
		for i = 1,6 do 
			self:GetChild("Diffs"):GetChild("DiffSelector"..i..pn):stopeffect()
		end
		DiffPos[pn] = DiffPos[pn] + offset
		if DiffPos[pn] > #Songs[CurSong]-1 then DiffPos[pn] = 1 end
		if DiffPos[pn] < 1 then DiffPos[pn] = #Songs[CurSong]-1 end
		self:GetChild("Diffs"):GetChild("DiffSelector"..DiffPos[pn]..pn):effectclock("Beat"):glowshift()	
	end
end

return function(Style)

	local Songs = LoadModule("Songs.Loader.lua")(Style)
	local StartOptions = false
	
	local Slider = Def.ActorFrame{Name="SliderCon"}
	local Banners = Def.ActorFrame{Name="Banners"}
	local Diffs = Def.ActorFrame{Name="Diffs"}
	
	for i = 1,7 do	
		local pos = CurSong+i-4
		if pos > #Songs then pos = (CurSong+i-4)-#Songs end
		if pos < 1 then pos = #Songs+(CurSong+i-4) end
		if pos > #Songs then pos = 1 CurSong = 1 end
		
		local DiffDisplay = Def.ActorFrame{Name="DiffCon"}
		
		for i2 = 1,6 do
			DiffDisplay[#DiffDisplay+1] = Def.ActorFrame {
				Name="DiffDisplay"..i2,
				OnCommand=function(self)
					self:y(38)
				end,
				Def.Sprite{
					Name="Feet",
					Texture=THEME:GetPathG("","Feet.png"),
					OnCommand=function(self)
						self:zoom(.075):x(-56+(15*i2)):diffusealpha(0)
				
						if #Songs[pos] > i2 then
							self:diffuse(DiffColors[DDR.DiffTab[Songs[pos][i2+1]:GetDifficulty()]])
						end
					end
				},
				Def.BitmapText{
					Name="level",
					Font="Common Normal",
					OnCommand=function(self)
						self:zoom(.25):x(-49+(15*i2))
						
						if #Songs[pos] > i2 then
							self:diffuse(DiffColors[DDR.DiffTab[Songs[pos][i2+1]:GetDifficulty()]]):settext(Songs[pos][i2+1]:GetMeter())
						end
					end
				}
			}					
		end
		
		Slider[#Slider+1] = Def.ActorFrame{
			Name="Slider"..i,
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X+(256*(i-4)),SCREEN_CENTER_Y-56):diffusealpha(0):linear(.5):diffusealpha(1)
			end,
			Def.Sprite{
				Name="Banner",
				OnCommand=function(self)
					self:Load(Songs[pos][1]:GetBannerPath())
					self:zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),256,80))
				end
			},
			Def.Sprite{
				Texture=THEME:GetPathG("","DiffInfo.png"),
				OnCommand=function(self) 
					self:zoom(.5):y(32):diffuse(color("#88ff88"))
				end
			},
			Def.BitmapText{
				Font="Common Normal",
				Name="CurSong",
				Text=pos.."/"..#Songs,
				OnCommand=function(self) 
					self:zoom(.4):y(44):x(96):strokecolor(0,0,0,1)
				end
			},
			DiffDisplay
		}
		
		for i2 = 1,2 do
			Banners[#Banners+1] = Def.ActorFrame{
				Name=i2..i,
				InitCommand=function(self) self:rotationz(-45):xy(SCREEN_CENTER_X+(64*(i-4)),SCREEN_CENTER_Y+80) end,
				Def.ActorFrame{
					Name="BannerCon",
					OnCommand=function(self)
						local offset = i-4
						if i-4 < 1 then offset = offset*-1 end
						self:x(1280)
						if i2 == 1 then
							self:sleep(offset/8):linear(.5):x(0)
						
							if i-4 == 0 then 
								self:effectclock("Beat"):glowshift():x(32)
							end
						end
					end,
					Def.Sprite{
						Name="Banner",
						OnCommand=function(self)
							self:Load(Songs[pos][1]:GetBannerPath())
							self:zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),128,40))
						end
					},
					Def.Quad{
						Name="FallbackBanner",
						OnCommand=function(self)
							self:zoomto(128,40):diffuse(.5,.5,.5,1)
							if Songs[pos][1]:HasBanner() then
								self:diffusealpha(0):zoom(0)
							end
						end					
					},
					Def.BitmapText{
						Font="Common Normal",
						Name="BannerText",
						Text=Songs[pos][1]:GetDisplayMainTitle(),
						OnCommand=function(self) 
							self:maxwidth(250):strokecolor(0,0,0,1):zoom(.5)
							if Songs[pos][1]:HasBanner() then
								self:diffusealpha(0):zoom(0)
							end
						end
					}
				}
			}
		end
	end
	
	for i = 1,6 do
		for i2 = 1,2 do
			Diffs[#Diffs+1] = Def.ActorFrame{ 
				Name="DiffSelector"..i..i2,
				Def.Sprite{
					Name="DiffCon",
					Texture=THEME:GetPathG("","DiffCon.png"),
					OnCommand=function(self)
						self:zoom(.5):y(SCREEN_CENTER_Y+(i*32)):x(SCREEN_CENTER_X+((i2-1.5)*224)):diffusealpha(0)
					end
				},
				Def.BitmapText{
					Font="Common Normal",
					Name="DiffName",
					Text="Practice",
					OnCommand=function(self)
						self:maxwidth(60):zoomy(.5):y(SCREEN_CENTER_Y+(i*32)):x(SCREEN_CENTER_X+((i2-1.5)*224)):diffusealpha(0)
					end
				}
			}
		end
		for i2 = 1,9 do
			Diffs[#Diffs+1] = Def.Sprite{
				Name="Feet"..i..i2,
				Texture=THEME:GetPathG("","Feet.png"),
				OnCommand=function(self)
					self:zoom(.125):y(SCREEN_CENTER_Y+(i*32)):x(SCREEN_CENTER_X+((i2-5)*16)):diffusealpha(0)
				end
			}
		end
	end
	
	return Def.ActorFrame{
		OnCommand=function(self) 
			SCREENMAN:GetTopScreen():AddInputCallback(DDR.Input(self))
			self:sleep(0.2):queuecommand("PlayCurrentSong")
		end,
		PlayCurrentSongCommand=function(self)
			SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
		end,
		MenuLeftCommand=function(self) if UnlockedInput then MoveSelection(self,-1,Songs) end if DiffSelection then MoveDifficulty(self,-1,Songs) end end,
		MenuRightCommand=function(self) if UnlockedInput then MoveSelection(self,1,Songs) end if DiffSelection then MoveDifficulty(self,1,Songs) end end,
		BackCommand=function(self)
			if DiffSelection then
				GAMESTATE:UnjoinPlayer(PLAYER_1)
				GAMESTATE:UnjoinPlayer(PLAYER_2)
				Joined[PLAYER_1] = false
				Joined[PLAYER_2] = false
				SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen") 
			else
				if Joined[self.pn] then 
					if Joined[PLAYER_1] and Joined[PLAYER_2] then
						GAMESTATE:UnjoinPlayer(self.pn)
						Joined[self.pn] = false
					else
						GAMESTATE:UnjoinPlayer(self.pn)
						Joined[self.pn] = false
						SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen") 
					end
				end
			end	
		end,
		StartCommand=function(self)
			if DiffSelection then
				if StartOptions then
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
				end
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					GAMESTATE:SetCurrentStyle('versus')
					PROFILEMAN:SaveProfile(PLAYER_1)
					PROFILEMAN:SaveProfile(PLAYER_2)
					GAMESTATE:SetCurrentSteps(PLAYER_1,Songs[CurSong][DiffPos[1]+1])
					GAMESTATE:SetCurrentSteps(PLAYER_2,Songs[CurSong][DiffPos[2]+1])
				else
					GAMESTATE:SetCurrentStyle('single')
					PROFILEMAN:SaveProfile(self.pn)
					GAMESTATE:SetCurrentSteps(self.pn,Songs[CurSong][DiffPos[1]+1])
				end
				StartOptions = true
				self:sleep(0.5):queuecommand("StartSong")
			else
				if UnlockedInput then 
					if Joined[self.pn] then 
						GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
						GAMESTATE:SetCurrentSong(Songs[CurSong][1])
						StartSelection(self,Songs)
					else
						GAMESTATE:JoinPlayer(self.pn)
						GAMESTATE:LoadProfiles()
						Joined[self.pn] = true
					end	
				end
			end
		end,
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
		UnlockInputCommand=function() UnlockedInput = true end,
		DiffSelectionCommand=function(self) 
			DiffSelection = true 
			if Joined[PLAYER_1] then self:GetChild("Diffs"):GetChild("DiffSelector11"):effectclock("Beat"):glowshift() end
			if Joined[PLAYER_2] then self:GetChild("Diffs"):GetChild("DiffSelector12"):effectclock("Beat"):glowshift() end
		end,
		Slider,
		Banners,
		Diffs,
		Def.BitmapText{
			Font="Common Normal",
			Name="Title",
			Text=Songs[CurSong][1]:GetDisplayMainTitle(),
			OnCommand=function(self) 
				self:Center():diffuse(color("#88ff88")):strokecolor(0,0,0,1):zoom(.5)
			end
		}
	}
	
end