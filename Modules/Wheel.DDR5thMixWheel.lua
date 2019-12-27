local DisplayColor={1,.5,0,1}

-- Difficulty Colours
local DiffColors={
	color("#88ffff"), -- Difficulty_Beginner
	color("#ffff88"), -- Difficulty_Easy
	color("#ff8888"), -- Difficulty_Medium
	color("#88ff88"), -- Difficulty_Hard
	color("#8888ff"), -- Difficulty_Challenge
	color("#888888") -- Difficulty_Edit
}

-- Difficulty Names.
-- https://en.wikipedia.org/wiki/Dance_Dance_Revolution#Difficulty
local DiffNames={
	"PRACTICE", -- Difficulty_Beginner
	"BASIC", -- Difficulty_Easy
	"TRICK", -- Difficulty_Medium
	"MANIAC ", -- Difficulty_Hard
	"EXTRA", -- Difficulty_Challenge
	"EDIT" -- Difficulty_Edit
}

-- We define the curent song if no song is selected.
if not CurSong then CurSong = 1 end

-- The player joined.
if not Joined then Joined = {} end

-- Position on the difficulty select that shows up after we picked a song.
local DiffPos = {[PLAYER_1] = 1,[PLAYER_2] = 1}

local IncOffset = 1
local DecOffset = 13
local XOffset = 7

-- Move the wheel, We define the Offset using +1 or -1.
-- We parse the Songs also so we can get the amount of songs.
local function MoveSelection(self,offset,Songs)

	-- Curent Song + Offset.
	CurSong = CurSong + offset
	
	-- Check if curent song is further than Songs if so, reset to 1.
	if CurSong > #Songs then CurSong = 1 end
	-- Check if curent song is lower than 1 if so, grab last song.
	if CurSong < 1 then CurSong = #Songs end
	
	
	DecOffset = DecOffset + offset
	IncOffset = IncOffset + offset
	if DecOffset > 13 then DecOffset = 1 end
	if IncOffset > 13 then IncOffset = 1 end
	if DecOffset < 1 then DecOffset = 13 end
	if IncOffset < 1 then IncOffset = 13 end
	
	XOffset = XOffset + offset
	if XOffset > 13 then XOffset = 1 end
	if XOffset < 1 then XOffset = 13 end

	if offset ~= 0 then
	for i = 1,13 do	
		local transform = ((i - XOffset)*(i - XOffset))*3
		
		if DecOffset < i and DecOffset > XOffset then
			transform =	((13 - i + XOffset)*(13 - i + XOffset))*3
		end
		
		if IncOffset > i and DecOffset < XOffset then
			transform =	((13 + i - XOffset)*(13 + i - XOffset))*3
		end
		
		local pos = CurSong+(6*offset)
		
		if pos > #Songs then pos = (CurSong+(18*offset))-#Songs end
		if pos < 1 then pos = #Songs+(CurSong+(18*offset)) end
		
		self:GetChild("Wheel"):GetChild("Container"..i):linear(.1):x(transform):addy((offset*-45))
		if (i == IncOffset and offset == -1) or (i == DecOffset and offset == 1) then
			self:GetChild("Wheel"):GetChild("Container"..i):sleep(0):addy((offset*-45)*-13)
			self:GetChild("Wheel"):GetChild("Container"..i):GetChild("Title"):settext(Songs[pos][1]:GetDisplayMainTitle())
							
			self:GetChild("Wheel"):GetChild("Container"..i):GetChild("Title"):zoom(.7):y(-10):maxwidth(400)
			if Songs[pos][1]:GetDisplaySubTitle() ~= "" then 
				self:GetChild("Wheel"):GetChild("Container"..i):GetChild("Title"):zoom(.4):y(-12):maxwidth(650)
			end 	
			
			self:GetChild("Wheel"):GetChild("Container"..i):GetChild("SubTitle"):settext(Songs[pos][1]:GetDisplaySubTitle())
			self:GetChild("Wheel"):GetChild("Container"..i):GetChild("Artist"):settext("/"..Songs[pos][1]:GetDisplayArtist())
		end
	end
	end
	
	self:GetChild("BannerUnderlay"):Load(Songs[CurSong][1]:GetBannerPath())
	self:GetChild("BannerUnderlay"):zoom(DDR.Resize(self:GetChild("BannerUnderlay"):GetWidth(),self:GetChild("BannerUnderlay"):GetHeight(),256,80))
	
	self:GetChild("BannerOverlay"):diffusealpha(1):linear(.1):diffusealpha(0):sleep(0):queuecommand("Load"):diffusealpha(1)
	
	for i = 1,6 do
		self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffBG"):diffusealpha(0)
		self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffText"):settext("")
		
		self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffBG"):diffusealpha(0)
		self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffText"):settext("")
		
		for i2 = 1,9 do
			self:GetChild("Diffs"):GetChild("FeetCon"..i):GetChild("Feet"..i2):diffusealpha(0)
		end
	end
	
	for i = 1,#Songs[CurSong]-1 do
		if Joined[PLAYER_1] then
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffBG"):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffText"):settext(DiffNames[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
		end
		
		if Joined[PLAYER_2] then
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffBG"):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffText"):settext(DiffNames[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]])
		end
		
		for i2 = 1,9 do
			self:GetChild("Diffs"):GetChild("FeetCon"..i):GetChild("Feet"..i2):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][i+1]:GetDifficulty()]]):diffusealpha(.5)
		end
		
		for i2 = 1,Songs[CurSong][i+1]:GetMeter() do
			if i2 > 9 then break end
			self:GetChild("Diffs"):GetChild("FeetCon"..i):GetChild("Feet"..i2):diffusealpha(1)
		end
		
		if offset == 0 then
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):diffusealpha(0)
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):diffusealpha(0)
		end
		
		if Joined[PLAYER_1] then
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):diffusealpha(1)
		end
			
		if Joined[PLAYER_2] then
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):diffusealpha(1)
		end
		
		if DiffPos[PLAYER_1] ~= i then
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):stopeffect()
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffBG"):stopeffect()
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffText"):stopeffect()
		end
		
		if DiffPos[PLAYER_1] > #Songs[CurSong]-1 then
			DiffPos[PLAYER_1] = 1
		end
		if DiffPos[PLAYER_1] == i then
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):bounce():effectmagnitude(-20,0,0):effectperiod(.6)
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffBG"):glowshift():effectperiod(1.2)
			self:GetChild("Diffs"):GetChild("DiffName1P"..i):GetChild("DiffText"):glowshift():effectperiod(1.2)
		end
		
		if DiffPos[PLAYER_2] ~= i then
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):stopeffect()
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffBG"):stopeffect()
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffText"):stopeffect()
		end
		
		if DiffPos[PLAYER_2] > #Songs[CurSong]-1 then
			DiffPos[PLAYER_2] = 1
		end
		if DiffPos[PLAYER_2] == i then
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):bounce():effectmagnitude(20,0,0):effectperiod(.6)
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffBG"):glowshift():effectperiod(1.2)
			self:GetChild("Diffs"):GetChild("DiffName2P"..i):GetChild("DiffText"):glowshift():effectperiod(1.2)
		end
	end		
	
	if #Songs[CurSong]-1 > 3 then
		self:GetChild("Diffs"):zoomy(3/(#Songs[CurSong]-1)):y(SCREEN_CENTER_Y-45+#Songs[CurSong]-1)
	else
		self:GetChild("Diffs"):zoomy(1):y(SCREEN_CENTER_Y-45)
	end
	
	DDR.CountingNumbers(self:GetChild("BPM_AFT"):GetChild("BPM"),self:GetChild("BPM_AFT"):GetChild("BPM"):GetText(),string.format("%.0f",Songs[CurSong][1]:GetDisplayBpms()[2]),.1)
	
	-- Stop all the music playing, Which is the Song Music
	SOUND:StopMusic()
	-- Play Current selected Song Music.
	SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
end

-- We use this function to do an effect on the content of the music wheel when we switch to next screen.
local function StartSelection(self,Songs)
end

local function MoveDifficulty(self,offset,Songs)
	if Joined[self.pn] then
		DiffPos[self.pn] = DiffPos[self.pn] + offset
		if DiffPos[self.pn] < 1 then DiffPos[self.pn] = 1 end
		if DiffPos[self.pn] > #Songs[CurSong]-1 then DiffPos[self.pn] = #Songs[CurSong]-1 end
	
		MoveSelection(self,0,Songs)
	end 
end

-- This is the main function, Its the function that contains the wheel.
return function(Style)

	-- Load the songs from the Songs.Loader module.
	local Songs = LoadModule("Songs.Loader.lua")(Style)
	
	-- We define here is we load the Options menu when people double press,
	-- Because they need to double press it starts at false.
	local StartOptions = false
	
	local Wheel = Def.ActorFrame{Name="Wheel"}
	
	local Diffs = Def.ActorFrame{Name="Diffs"}
		
	for i = 1,13 do
		local offset = i - 7
		
		local pos = CurSong+i-7
		if pos > #Songs then pos = (CurSong+i-7)-#Songs end
		if pos < 1 then pos = #Songs+(CurSong+i-7) end
		if pos > #Songs then pos = 1 CurSong = 1 end
		
		Wheel[#Wheel+1] = Def.ActorFrame{
			Name="Container"..i,
			OnCommand=function(self) self:xy((offset*offset)*3,offset*45) end,
			Def.BitmapText{
				Name="Title",
				Font="_open sans 40px",
				Text=Songs[pos][1]:GetDisplayMainTitle(),
				OnCommand=function(self) self:zoom(.7):halign(0):y(-10):maxwidth(400)
					:diffuse(DisplayColor[1],DisplayColor[2],DisplayColor[3],DisplayColor[4])
					if Songs[pos][1]:GetDisplaySubTitle() ~= "" then 
						self:zoom(.4):y(-12):maxwidth(650)
					end 				
				end
			},
			Def.BitmapText{
				Name="SubTitle",
				Font="_open sans 40px",
				Text=Songs[pos][1]:GetDisplaySubTitle(),
				OnCommand=function(self) self:zoom(.3):halign(0):maxwidth(650)
					:diffuse(DisplayColor[1],DisplayColor[2],DisplayColor[3],DisplayColor[4])				
				end
			},
			Def.BitmapText{
				Name="Artist",
				Font="_open sans 40px",
				Text="/"..Songs[pos][1]:GetDisplayArtist(),
				OnCommand=function(self) self:zoom(.3):halign(0):y(10):maxwidth(650)
					:diffuse(DisplayColor[1],DisplayColor[2],DisplayColor[3],DisplayColor[4])
				end
			}		
		}	
	end
	
	for i = 1,6 do
	
		local Feet = Def.ActorFrame{Name="FeetCon"..i}
	
		for i2 = 1,9 do
			Feet[#Feet+1] = Def.Sprite{
				Name="Feet"..i2,
				Texture=THEME:GetPathG("","Feet"),
				InitCommand=function(self) 
					self:zoom(.15):diffuse(0,0,0,0):xy(15*i2,25*i)
				end
			}	
		end
		
		Diffs[#Diffs+1] = Feet
		
		Diffs[#Diffs+1] = Def.ActorFrame{
			Name="DiffName1P"..i,
			Def.Sprite{
				Name="DiffBG",
				Texture=THEME:GetPathG("","DiffSel"),
				InitCommand=function(self) 
					self:zoom(.05):xy(-15,25*i)
				end
			},
			Def.BitmapText{
				Name="DiffText",
				Text="Diff",
				Font="_open sans 40px",
				InitCommand=function(self) 
					self:zoom(.2):diffuse(0,0,0,1):xy(-17,25*i):maxwidth(140)
				end
			}
		}
		
		Diffs[#Diffs+1] = Def.ActorFrame{
			Name="DiffName2P"..i,
			Def.Sprite{
				Name="DiffBG",
				Texture=THEME:GetPathG("","DiffSel"),
				InitCommand=function(self) 
					self:zoom(-.05):xy(165,25*i)
				end
			},
			Def.BitmapText{
				Name="DiffText",
				Text="Diff",
				Font="_open sans 40px",
				InitCommand=function(self) 
					self:zoom(.2):diffuse(0,0,0,1):xy(167,25*i):maxwidth(140)
				end
			}
		}
	end
	
	
	
	-- Here we return the actual Music Wheel Actor.
	return Def.ActorFrame{
		OnCommand=function(self) 
			-- We use a Input function from the Scripts folder.
			-- It uses a Command function. So you can define all the Commands,
			-- Like MenuLeft is MenuLeftCommand.
			SCREENMAN:GetTopScreen():AddInputCallback(DDR.Input(self))
			
			MoveSelection(self,0,Songs)
			
			-- Sleep for 0.2 sec, And then load the current song music.
			self:sleep(0.2):queuecommand("PlayCurrentSong")
		end,
		
		-- Play Music at start of screen,.
		PlayCurrentSongCommand=function(self)
			SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
		end,
		
		-- Do stuff when a user presses left on Pad or Menu buttons.
		MenuLeftCommand=function(self) MoveSelection(self,-1,Songs)
		end,
		
		-- Do stuff when a user presses Right on Pad or Menu buttons.
		MenuRightCommand=function(self) MoveSelection(self,1,Songs)
		end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuDownCommand=function(self) MoveDifficulty(self,1,Songs) end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuUpCommand=function(self) MoveDifficulty(self,-1,Songs) end,
		
		-- Do stuff when a user presses the Back on Pad or Menu buttons.
		BackCommand=function(self) 
			-- Check if User is joined.
			if Joined[self.pn] then
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					-- If both players are joined, We want to unjoin the player that pressed back.
					GAMESTATE:UnjoinPlayer(self.pn)
					Joined[self.pn] = false
					
					MoveSelection(self,0,Songs)
				else
					-- Go to the previous screen.
					SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen") 
				end
			end
		end,
		
		-- Do stuff when a user presses the Start on Pad or Menu buttons.
		StartCommand=function(self)
			-- Check if we want to go to ScreenPlayerOptions instead of ScreenGameplay.
			if StartOptions then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
			end
			-- Check if player is joined.
			if Joined[self.pn] then 
			
				--We use PlayMode_Regular for now.
				GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
				
				--Set the song we want to play.
				GAMESTATE:SetCurrentSong(Songs[CurSong][1])
				
				-- Check if 2 players are joined.
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
				
					-- If they are, We will use Versus.
					GAMESTATE:SetCurrentStyle('versus')
					
					-- Save Profiles.
					PROFILEMAN:SaveProfile(PLAYER_1)
					PROFILEMAN:SaveProfile(PLAYER_2)
					
					-- Set the Current Steps to use.
					GAMESTATE:SetCurrentSteps(PLAYER_1,Songs[CurSong][DiffPos[PLAYER_1]+1])
					GAMESTATE:SetCurrentSteps(PLAYER_2,Songs[CurSong][DiffPos[PLAYER_2]+1])
				else
				
					-- If we are single player, Use Single.
					GAMESTATE:SetCurrentStyle('single')
					
					-- Save Profile.
					PROFILEMAN:SaveProfile(self.pn)
					
					-- Set the Current Step to use.
					GAMESTATE:SetCurrentSteps(self.pn,Songs[CurSong][DiffPos[self.pn]+1])
				end
				
				-- We want to go to player options when people doublepress, So we set the StartOptions to true,
				-- So when the player presses Start again, It will go to player options.
				StartOptions = true
				
				-- Do the effects on actors.
				StartSelection(self,Songs)
				
				-- Wait 0.4 sec before we go to next screen.
				self:sleep(0.4):queuecommand("StartSong")
			else
				-- If no player is active Join.
				GAMESTATE:JoinPlayer(self.pn)
				
				-- Load the profles.
				GAMESTATE:LoadProfiles()
				
				-- Add to joined list.
				Joined[self.pn] = true
				
				MoveSelection(self,0,Songs)
			end			
		end,
		
		-- Change to ScreenGameplay.
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
				
		Def.Sprite{
			Texture=THEME:GetPathG("Info","Display"),
			OnCommand=function(self) 
				self:zoom(.5):xy(SCREEN_CENTER_X-200, SCREEN_CENTER_Y-60) 
					:diffuse(DisplayColor[1],DisplayColor[2],DisplayColor[3],DisplayColor[4])
			end
		},
		
		Def.Sprite{
			Texture=THEME:GetPathG("","DiffSel"),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-160, SCREEN_CENTER_Y-172):zoom(.05)
					:diffuse(DisplayColor[1]/1.5,DisplayColor[2]/1.5,DisplayColor[3]/1.5,DisplayColor[4])
			end
		},
		
		Def.BitmapText{
			Font="_open sans 40px",
			Text="BPM",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-165, SCREEN_CENTER_Y-172):zoom(.2):zoomx(.3)
					:diffuse(DisplayColor[1],DisplayColor[2],DisplayColor[3],DisplayColor[4])
			end
		},
		
		Def.ActorFrameTexture{
			Name="BPM_AFT",
			InitCommand=function(self)
				self:SetTextureName("Italic_BPM"):SetWidth(280):SetHeight(60):EnableAlphaBuffer(true):Create()
			end,
			Def.BitmapText{
				Name="BPM",
				Text=string.format("%.0f",Songs[CurSong][1]:GetDisplayBpms()[2]),
				Font="_open sans 40px",
				OnCommand=function(self) 
					self:xy(140,30)
				end
			}
		},
		
		Def.Sprite{
			Texture="Italic_BPM",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-172, SCREEN_CENTER_Y-142)
					:SetCustomPosCoords(10,0,0,0,0,0,10,0)
					:zoom(.7):zoomx(1.4):diffuse(0,0,0,.5):fadetop(1)
				
			end
		},
		
		Def.Sprite{
			Texture="Italic_BPM",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-175, SCREEN_CENTER_Y-145)
					:SetCustomPosCoords(10,0,0,0,0,0,10,0)
					:zoom(.7):zoomx(1.4):diffuse(1,1,0,1)
				
			end
		},
		
		Def.Sprite{
			Texture="Italic_BPM",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-175, SCREEN_CENTER_Y-145)
					:SetCustomPosCoords(10,0,0,0,0,0,10,0)
					:zoom(.7):zoomx(1.4):diffuse(1,.5,0,1):fadetop(1)
				
			end
		},

		Def.ActorFrameTexture{
			InitCommand=function(self)
				self:SetTextureName("Italic_bpm"):SetWidth(280):SetHeight(60):EnableAlphaBuffer(true):Create()
			end,
			Def.BitmapText{
				Text="bpm",
				Font="_open sans 40px",
				OnCommand=function(self) 
					self:xy(140,30)
				end
			}
		},
		
		Def.Sprite{
			Texture="Italic_bpm",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-105, SCREEN_CENTER_Y-140)
					:SetCustomPosCoords(20,0,0,0,0,0,20,0)
					:zoom(.3):diffuse(0,0,0,.5):fadetop(1)
				
			end
		},
		
		Def.Sprite{
			Texture="Italic_bpm",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-107, SCREEN_CENTER_Y-142)
					:SetCustomPosCoords(20,0,0,0,0,0,20,0)
					:zoom(.3):diffuse(1,1,0,1)
				
			end
		},
		
		Def.Sprite{
			Texture=THEME:GetPathG("","DiffSel"),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-300, SCREEN_CENTER_Y-164):zoom(.05):zoomx(.07)
					:diffuse(DisplayColor[1]/1.5,DisplayColor[2]/1.5,DisplayColor[3]/1.5,DisplayColor[4])
			end
		},
		
		Def.BitmapText{
			Font="_open sans 40px",
			Text="STAGE",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-305, SCREEN_CENTER_Y-164):zoom(.2):zoomx(.3)
					:diffuse(DisplayColor[1],DisplayColor[2],DisplayColor[3],DisplayColor[4])
			end
		},
		
		Def.ActorFrameTexture{
			InitCommand=function(self)
				self:SetTextureName("Italic_Stage"):SetWidth(280):SetHeight(60):EnableAlphaBuffer(true):Create()
			end,
			Def.BitmapText{
				Text=ToEnumShortString(GAMESTATE:GetCurrentStage()):upper(),
				Font="_open sans 40px",
				OnCommand=function(self) 
					self:diffuse(0,.5,0,1):strokecolor(0,.5,0,1):xy(140,30)
				end
			}
		},
		
		Def.Sprite{
			Texture="Italic_Stage",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-300, SCREEN_CENTER_Y-145):SetCustomPosCoords(10,0,0,0,0,0,10,0):zoom(.3):zoomx(.5)		
			end
		},
		
		Def.Sprite{
			Texture=THEME:GetPathG("","Dance"),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-68, SCREEN_CENTER_Y-150):zoom(.15)
			end
		},
		
		Def.Sprite{
			Name="BannerUnderlay",
			InitCommand=function(self)
				self:Load(Songs[CurSong][1]:GetBannerPath())
					:zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),256,80))
					:xy(SCREEN_CENTER_X-200, SCREEN_CENTER_Y-90)
			end
		},
		
		Def.Sprite{
			Name="BannerOverlay",
			InitCommand=function(self)
				self:Load(Songs[CurSong][1]:GetBannerPath())
					:zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),256,80))
					:xy(SCREEN_CENTER_X-200, SCREEN_CENTER_Y-90)
			end,
			LoadCommand=function(self) 
			self:Load(Songs[CurSong][1]:GetBannerPath())
				:zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),256,80))
			end
		},
		
		Def.Sprite{
			Texture=THEME:GetPathG("","DiffSel"),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-235, SCREEN_CENTER_Y-40):zoom(.038):zoomx(-.08)
					:diffuse(DisplayColor[1]/1.5,DisplayColor[2]/1.5,DisplayColor[3]/1.5,DisplayColor[4])
			end
		},
		
		Def.Sprite{
			Texture=THEME:GetPathG("","DiffSel"),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-175, SCREEN_CENTER_Y-40):zoom(.038):zoomx(.08)
					:diffuse(DisplayColor[1]/1.5,DisplayColor[2]/1.5,DisplayColor[3]/1.5,DisplayColor[4])
			end
		},
		
		Def.ActorFrameTexture{
			InitCommand=function(self)
				self:SetTextureName("Italic_P1"):SetWidth(60):SetHeight(60):EnableAlphaBuffer(true):Create()
			end,
			Def.BitmapText{
				Text="1P",
				Font="_open sans 40px",
				OnCommand=function(self) 
					self:diffuse(DisplayColor[1]/4,DisplayColor[2]/4,DisplayColor[3]/4,DisplayColor[4])
					:strokecolor(DisplayColor[1]/4,DisplayColor[2]/4,DisplayColor[3]/4,DisplayColor[4]):xy(30,30)
				end
			}
		},
		
		Def.Sprite{
			Texture="Italic_P1",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-335, SCREEN_CENTER_Y-37):SetCustomPosCoords(10,0,0,0,0,0,10,0):zoom(.2):zoomx(.3)		
			end
		},
		
		Def.ActorFrameTexture{
			InitCommand=function(self)
				self:SetTextureName("Italic_P2"):SetWidth(60):SetHeight(60):EnableAlphaBuffer(true):Create()
			end,
			Def.BitmapText{
				Text="2P",
				Font="_open sans 40px",
				OnCommand=function(self) 
					self:diffuse(DisplayColor[1]/4,DisplayColor[2]/4,DisplayColor[3]/4,DisplayColor[4])
					:strokecolor(DisplayColor[1]/4,DisplayColor[2]/4,DisplayColor[3]/4,DisplayColor[4]):xy(30,30)
				end
			}
		},
		
		Def.Sprite{
			Texture="Italic_P2",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-80, SCREEN_CENTER_Y-37):SetCustomPosCoords(10,0,0,0,0,0,10,0):zoom(.2):zoomx(.3)		
			end
		},
		
		Def.BitmapText{
			Font="_open sans 40px",
			Text="DIFFICULTY",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-205, SCREEN_CENTER_Y-40):zoom(.2):zoomx(.3)
					:diffuse(DisplayColor[1],DisplayColor[2],DisplayColor[3],DisplayColor[4])
			end
		},
		
		Diffs..{OnCommand=function(self) self:x(SCREEN_CENTER_X-280):valign(0) end},
				
		Wheel..{OnCommand=function(self) self:Center() end},
		
		Def.Sprite{
			Texture=THEME:GetPathG("","Selector"),
			OnCommand=function(self) 
				self:zoom(.65):xy(SCREEN_CENTER_X+140, SCREEN_CENTER_Y-2):faderight(1)
					:diffuseshift():effectcolor1(1,1,1,.9)
					:effectcolor2(DisplayColor[1],DisplayColor[2],DisplayColor[3],.5)
			end
		}
	}
end