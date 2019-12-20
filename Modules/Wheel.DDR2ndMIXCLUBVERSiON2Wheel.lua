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
	"EASY", -- Difficulty_Beginner
	"BASIC", -- Difficulty_Easy
	"ANOTHER", -- Difficulty_Medium
	"MANIAC ", -- Difficulty_Hard
	"EXTRA", -- Difficulty_Challenge
	"EDIT" -- Difficulty_Edit
}

-- Difficulty Chart Names based on Meter.
local DiffChartNames={
	"SIMPLE", -- 1 feet
	"MODERATE", -- 2 feet
	"ORDINARY", -- 3 feet
	"SUPERIOR", -- 4 feet
	"MARVELOUS", -- 5 feet
	"GENUINE", -- 6 feet
	"PARAMOUNT", -- 7 feet
	"EXORBITANT", -- 8 feet
	"CATASTROPHIC" -- 9 feet
}

-- We define the curent song if no song is selected.
if not CurSong then CurSong = 1 end

-- The player joined.
if not Joined then Joined = {} end

-- The Offset we use for the CD wheel.
local CDOffset = 1

-- The CD in front, That we want to Switch out.
-- This is half of the number of CDs
local CDSwitch = 19

-- Move the wheel, We define the Offset using +1 or -1.
-- We parse the Songs also so we can get the amount of songs.
local function MoveSelection(self,offset,Songs)

	-- Curent Song + Offset.
	CurSong = CurSong + offset
	
	-- Check if curent song is further than Songs if so, reset to 1.
	if CurSong > #Songs then CurSong = 1 end
	-- Check if curent song is lower than 1 if so, grab last song.
	if CurSong < 1 then CurSong = #Songs end
	
	-- CD Wheel offset + Offset.
	CDOffset = CDOffset + offset
	
	-- We want to rotate for every CD, So we grab the current Offset of the CD,
	-- And we Check if its beyond 37 and below 1.
	if CDOffset > 37 then CDOffset = 1 end
	if CDOffset < 1 then CDOffset = 37 end
	
	-- Same as above but for CDSwitch which is half of amount of CDs
	CDSwitch = CDSwitch + offset
	if CDSwitch > 37 then CDSwitch = 1 end
	if CDSwitch < 1 then CDSwitch = 37 end

	-- For every CD on the wheel, Rotate it by 360/37, 37 being the amount of CDs.
	for i = 1,37 do
		self:GetChild("CDCon"):GetChild("CD"..i):linear(.1):addrotationz(((360/37)*offset)*-1):y(SCREEN_CENTER_Y-80)
		-- Do a diffrent effect for the front most CD.
		if i == CDSwitch then
			self:GetChild("CDCon"):GetChild("CD"..i):y(SCREEN_CENTER_Y-60)
		end
	end
	
	-- We Define the ChangeOffset, Which is used to define the location the CDs change Images.
	local ChangeOffset = CDOffset
	
	-- An extra check that results the ChangeOffset is right when we go in reverse.
	if offset > 0 then ChangeOffset = ChangeOffset + -1 end
	
	-- Same as CDOffset, Stay withing limits.
	if ChangeOffset > 37 then CDOffset = 1 end
	if ChangeOffset < 1 then ChangeOffset = 37 end
	
	-- The Position of Current song, The Wheel is 37 cd's so we grab Half
	local pos = CurSong+(18*offset)
	
	-- The Position is checked if its withing Song limits.
	if pos > #Songs then pos = (CurSong+(18*offset))-#Songs end
	if pos < 1 then pos = #Songs+(CurSong+(18*offset)) end
	
	-- We check if the song has a banner, We use this for the CDs, If there is no banner, use white.png
	if Songs[pos][1]:HasBanner() then
		self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):Load(Songs[pos][1]:GetBannerPath())
	else
		self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):Load(THEME:GetPathG("","white.png")) 
	end
	
	-- We make it so that the slices are always w512 h160, and then resize the CD slices so they fit as part of the CD.
	self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):setsize(512,160):SetCustomPosCoords(self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2-23,0,self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2-9,-80,-self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2+9,-80,-self:GetChild("Con"):GetChild("CDSlice"..ChangeOffset):GetWidth()/2+23,0):zoom(.4):y(-20)
	
	-- Set the Centered Banner.
	self:GetChild("Banner"):Load(Songs[CurSong][1]:GetBannerPath())
	
	-- Resize the Centered Banner  to be w(512/8)*5 h(160/8)*5
	self:GetChild("Banner"):zoom(DDR.Resize(self:GetChild("Banner"):GetWidth(),self:GetChild("Banner"):GetHeight(),(512/8)*5,(160/8)*5))
	
	-- This is the same as Centered Banner, But for CDTitles.
	self:GetChild("CDTitle"):Load(Songs[CurSong][1]:GetCDTitlePath())
	
	-- Resize the CDTitles to be a max of w80 h80.
	self:GetChild("CDTitle"):zoom(DDR.Resize(self:GetChild("CDTitle"):GetWidth(),self:GetChild("CDTitle"):GetHeight(),80,80))
	
	-- Stop all the music playing, Which is the Song Music
	SOUND:StopMusic()
	-- Play Current selected Song Music.
	SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)	
end

-- We use this function to do an effect on the content of the music wheel when we switch to next screen.
local function StartSelection(self,Songs)

	-- For ever CD on the Wheel we send them fying away,
	-- Except for the front most one, We make it spin first.
	for i = 1,37 do
		-- Check if its the front most CD.
		if i == CDSwitch then
			self:GetChild("CDCon"):GetChild("CD"..i):GetChild("Container"):accelerate(1.5):addrotationz(-360):linear(.4):addy(-1280)
		else
			self:GetChild("CDCon"):GetChild("CD"..i):GetChild("Container"):sleep(1.5):linear(.4):y(-1280)
		end
	end
end

-- Define the start difficulty to be the 2nd selection,
-- Because the first selection is the entire Song,
-- And the second and plus versions are all difficulties.
local CurDiff = 2

local function MoveDifficulty(self,offset,Songs)	
	
	-- Move the current difficulty + offset.
	CurDiff = CurDiff + offset
	
	-- Stay withing limits, But ignoring the first selection because its the entire song.
	if CurDiff > #Songs[CurSong] then CurDiff = 2 end
	if CurDiff < 2 then CurDiff = #Songs[CurSong] end

	-- Run on every feet, A feet is a part of the Difficulty, We got a max of 9 feets.
	for i = 1,9 do
		self:GetChild("Diffs"):GetChild("Feet"..i):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]]):diffusealpha(0)
	end
	
	-- We get the Meter from the game, And make it so it stays between 8 which is the Max feets we support.
	local DiffCount = Songs[CurSong][CurDiff]:GetMeter()
	if DiffCount > 9 then  DiffCount = 9 end
	
	-- For every Meter value we got for the game, We show the amount of feets for the difficulty, And center them.
	for i = 1,DiffCount do
		self:GetChild("Diffs"):GetChild("Feet"..i):diffusealpha(1):x(25*(i-((DiffCount/2)+.5)))
	end
	
	-- Set the name of the Chart Difficulty.
	self:GetChild("DiffChart"):settext(DiffChartNames[DiffCount]):diffuse(DiffColors[DDR.DiffTab[Songs[CurSong][CurDiff]:GetDifficulty()]])
end

return function(Style)

	-- Load the songs from the Songs.Loader module.
	local Songs = LoadModule("Songs.Loader.lua")(Style)
	
	-- We define here is we load the Options menu when people double press,
	-- Because they need to double press it starts at false.
	local StartOptions = false
	
	-- All the CDs on the Wheel.
	local CDs = Def.ActorFrame{Name="CDCon"}
	
	-- All the Slices of the CDs on the Wheel.
	local CDslice = Def.ActorFrame{Name="Con"}
	
	-- Here we generate all the CDs for the wheel
	for i = 1,37 do
	
		-- Position of current song, We want the cd in the front, So its the one we change.
		local pos = CurSong+i-19
		if pos > #Songs then pos = (CurSong+i-19)-#Songs end
		if pos < 1 then pos = #Songs+(CurSong+i-19) end
		if pos > #Songs then pos = 1 CurSong = 1 end
		
		-- We load a Banner once, We use ActorProxy to copy it, This is lighter than loading the Banner for every Slice. 
		CDslice[#CDslice+1] = Def.Sprite{
			Name="CDSlice"..i,
			-- Load the Banner.
			Texture=Songs[pos][1]:GetBannerPath(),
			OnCommand=function(self)
				-- If the banner doesnt exist, Load white.png.
				if not Songs[pos][1]:HasBanner() then self:Load(THEME:GetPathG("","white.png")) end
				
				-- Resize the Banner to the size of the slice.
				self:setsize(512,160):SetCustomPosCoords(self:GetWidth()/2-23,0,self:GetWidth()/2-9,-80,-self:GetWidth()/2+9,-80,-self:GetWidth()/2+23,0):zoom(.4):y(-20)
			end
		}
				
		-- The CDHolder, This contains all the slices, And at start the CD Background.
		local CDHolder = Def.ActorFrame{
			Name="CDHolder",
			Def.ActorProxy {
				Name="CDBG",
				InitCommand=function(self)
					self:SetTarget(self:ForParent(5):GetChild("CDBGCon"):GetChild("CDBG")):zoom(.23)
				end
			}
		}
		
		-- We use 18 slices for the CDs.
		for i2 = 1,18 do
			CDHolder[#CDHolder+1] = Def.ActorFrame{
				OnCommand=function(self)
					self:rotationz((360/18)*i2)
				end,
				-- The ActorProxy's that contain all the CD Slices.
				Def.ActorProxy {
					InitCommand=function(self)
						self:SetTarget(self:ForParent(6):GetChild("Con"):GetChild("CDSlice"..i))
					end
				}
			}
		end
				
		-- The CD's for the music wheel.
		CDs[#CDs+1] = Def.ActorFrame{ 
			Name="CD"..i,
			OnCommand=function(self)
				-- We set FOV/Field Of Vision to get a dept effect.
				self:rotationz((180-((360/37)*(i-19)))*-1):CenterX():y(SCREEN_CENTER_Y-80):rotationx(-52):SetFOV(80)
				if CDSwitch == i then 
					self:y(SCREEN_CENTER_Y-60)
				end
			end,
			-- The Container of the Slices.
			Def.ActorFrame{
				Name="Container",
				OnCommand=function(self) self:y(-220):zoom(.4) end,
				CDHolder
			}
		}
	end
	
	-- The Left and Right Arrows that change when you press Left or Right.
	local TriSel = Def.ActorFrame {}
	
	-- We make the arrows out of Triangles, We need 2 images.
	for	i = 0,1 do
		TriSel[#TriSel+1] = Def.Sprite {
			Texture=THEME:GetPathG("","Triangle.png"),
			OnCommand=function(self) self:zoom(.06):y(18*i) end,
		}
	end
	
	-- The Difficulty Display.
	local Diff = Def.ActorFrame {Name="Diffs",}
	
	-- The amount of Feet we use to display the Difficulty using the Meter.
	for i = 1,9 do
		Diff[#Diff+1] = Def.Sprite {
			Name="Feet"..i,
			Texture=THEME:GetPathG("","Feet.png"),
			InitCommand=function(self) self:zoomx(-.3):zoomy(.3):x(30*(i-5)) end
		}
	end
	
	-- Here we return the actual Music Wheel Actor.
	return Def.ActorFrame{
		OnCommand=function(self) 
			-- We use a Input function from the Scripts folder.
			-- It uses a Command function. So you can define all the Commands,
			-- Like MenuLeft is MenuLeftCommand.
			SCREENMAN:GetTopScreen():AddInputCallback(DDR.Input(self))
			
			-- Sleep for 0.2 sec, And then load the current song music.
			self:sleep(0.2):queuecommand("PlayCurrentSong")
			
			-- Initalize the Difficulties.
			MoveDifficulty(self,0,Songs)
		end,
		
		-- Play Music at start of screen,.
		PlayCurrentSongCommand=function(self)
			SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
		end,
		
		-- Do stuff when a user presses left on Pad or Menu buttons.
		MenuLeftCommand=function(self) MoveSelection(self,-1,Songs) MoveDifficulty(self,0,Songs)
			self:GetChild("Left"):stoptweening()
			-- Play the colour effect 5 times.
			for i = 1,5 do
				self:GetChild("Left"):queuecommand("Colour")
			end
		end,
		
		-- Do stuff when a user presses Right on Pad or Menu buttons.
		MenuRightCommand=function(self) MoveSelection(self,1,Songs) MoveDifficulty(self,0,Songs)
			self:GetChild("Right"):stoptweening()
			-- Play the colour effect 5 times.
			for i = 1,5 do
				self:GetChild("Right"):queuecommand("Colour")
			end
		end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuDownCommand=function(self) MoveDifficulty(self,-1,Songs) end,
		
		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuUpCommand=function(self) MoveDifficulty(self,1,Songs) end,
		
		-- Do stuff when a user presses the Back on Pad or Menu buttons.
		BackCommand=function(self) 
			-- Check if User is joined.
			if Joined[self.pn] then
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					-- If both players are joined, We want to unjoin the player that pressed back.
					GAMESTATE:UnjoinPlayer(self.pn)
					Joined[self.pn] = false
					
					-- A Player left, Change bakc to Single.
					self:GetChild("Style"):settext("SINGLE")
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
					GAMESTATE:SetCurrentSteps(PLAYER_1,Songs[CurSong][CurDiff])
					GAMESTATE:SetCurrentSteps(PLAYER_2,Songs[CurSong][CurDiff])
				else
				
					-- If we are single player, Use Single.
					GAMESTATE:SetCurrentStyle('single')
					
					-- Save Profile.
					PROFILEMAN:SaveProfile(self.pn)
					
					-- Set the Current Step to use.
					GAMESTATE:SetCurrentSteps(self.pn,Songs[CurSong][CurDiff])
				end
				
				-- We want to go to player options when people doublepress, So we set the StartOptions to true,
				-- So when the player presses Start again, It will go to player options.
				StartOptions = true
				
				-- Do the effects on actors.
				StartSelection(self,Songs)
				
				-- Wait 0.4 sec before we go to next screen.
				self:sleep(2):queuecommand("StartSong")
			else
				-- If no player is active Join.
				GAMESTATE:JoinPlayer(self.pn)
				
				-- Load the profles.
				GAMESTATE:LoadProfiles()
				
				-- Add to joined list.
				Joined[self.pn] = true
				
				-- Set Style Text to VERSUS when 2 Players.
				if Joined[PLAYER_1] and Joined[PLAYER_2] then
					self:GetChild("Style"):settext("VERSUS")
				end
			end			
		end,	
		
		-- Change to ScreenGameplay.
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
		
		-- The CD Background.
		Def.ActorFrame {
			Name="CDBGCon",
			-- We define the zoom as 0 to hide the CD Background,
			-- Because we use an ActorProxy to display it.
			OnCommand=function(self) self:zoom(0) end,
			Def.Sprite {
				Name="CDBG",
				Texture=THEME:GetPathG("","CDCon.png")
			}
		},
		CDslice, -- Load CD Slices.
		CDs, -- Load CDs.
		
		-- Load the Global Centered Banner.
		Def.Sprite{
			Name="Banner",
			Texture=Songs[CurSong][1]:GetBannerPath(),
			OnCommand=function(self)
				self:CenterX():y(SCREEN_CENTER_Y-80):zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),(512/8)*5,(160/8)*5))
			end				
		},
		
		-- Load the CDTitles.
		Def.Sprite{
			Name="CDTitle",
			Texture=Songs[CurSong][1]:GetCDTitlePath(),
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X+80,SCREEN_CENTER_Y+30):zoom(DDR.Resize(self:GetWidth(),self:GetHeight(),80,80))
			end
		},
		
		-- Load the HARD text.
		Def.BitmapText{
			Text="HARD",
			Font="_open sans 40px",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X-120,SCREEN_CENTER_Y-140):strokecolor(0,0,1,1):zoom(.3):zoomx(.4)
			end			
		},
		
		-- Load the Current Stage (1ST, 2ND, FINAL, EVENT)
		Def.BitmapText{
			Text=ToEnumShortString(GAMESTATE:GetCurrentStage()):upper(),
			Font="_open sans 40px",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X+50,SCREEN_CENTER_Y-140):diffuse(1,0,0,1):strokecolor(1,1,1,1):zoom(.5)
			end			
		},
		
		-- Load the STAGE text.
		Def.BitmapText{
			Text="STAGE",
			Font="_open sans 40px",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X+120,SCREEN_CENTER_Y-140):strokecolor(0,0,0,1):zoom(.4):zoomx(.5)
			end			
		},
		
		-- Load the arrow for the Left size
		TriSel..{
			Name="Left", 
			OnCommand=function(self) self:xy(SCREEN_CENTER_X-110,SCREEN_CENTER_Y+110):rotationz(-90):diffuse(1,0,0,1) end,
			ColourCommand=function(self) self:sleep(0.02):diffuse(0,0,1,1):sleep(0.02):diffuse(1,1,1,1):sleep(0.02):diffuse(1,0,0,1) end
		},
		
		-- Load the arrow for the Right size.
		TriSel..{
			Name="Right", 
			OnCommand=function(self) self:xy(SCREEN_CENTER_X+110,SCREEN_CENTER_Y+110):rotationz(90):diffuse(1,0,0,1) end,
			ColourCommand=function(self) self:sleep(0.02):diffuse(0,0,1,1):sleep(0.02):diffuse(1,1,1,1):sleep(0.02):diffuse(1,0,0,1) end
		},
		
		-- The Difficulty Feet Meter.
		Diff..{OnCommand=function(self) self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+150) end},
		
		
		-- The Difficulty Chart Names based on Meter.
		Def.BitmapText{
			Name="DiffChart",
			Font="_open sans 40px",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+180):strokecolor(0,0,0,1):zoom(.7):zoomy(.5)
			end
		},
		
		-- Load the Syle Text.
		Def.BitmapText{
			Name="Style",
			Text="SINGLE",
			Font="_open sans 40px",
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+220):diffuse(1,0,0,1):strokecolor(1,1,0,1):zoom(.8)
			end
		}
	}
end