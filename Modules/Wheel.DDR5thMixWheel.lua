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
			self:GetChild("Wheel"):GetChild("Container"..i):GetChild("Artist"):settext(Songs[pos][1]:GetDisplayArtist())
		end
	end
	
	-- Stop all the music playing, Which is the Song Music
	SOUND:StopMusic()
	-- Play Current selected Song Music.
	SOUND:PlayMusicPart(Songs[CurSong][1]:GetMusicPath(),Songs[CurSong][1]:GetSampleStart(),Songs[CurSong][1]:GetSampleLength(),0,0,true)
end

-- We use this function to do an effect on the content of the music wheel when we switch to next screen.
local function StartSelection(self,Songs)
end

local function MoveDifficulty(self,offset,Songs)	
end

-- This is the main function, Its the function that contains the wheel.
return function(Style)

	-- Load the songs from the Songs.Loader module.
	local Songs = LoadModule("Songs.Loader.lua")(Style)
	
	-- We define here is we load the Options menu when people double press,
	-- Because they need to double press it starts at false.
	local StartOptions = false
	
	local Wheel = Def.ActorFrame{Name="Wheel"}
		
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
					if Songs[pos][1]:GetDisplaySubTitle() ~= "" then 
						self:zoom(.4):y(-12):maxwidth(650)
					end 				
				end
			},
			Def.BitmapText{
				Name="SubTitle",
				Font="_open sans 40px",
				Text=Songs[pos][1]:GetDisplaySubTitle(),
				OnCommand=function(self) self:zoom(.3):halign(0):maxwidth(650) end
			},
			Def.BitmapText{
				Name="Artist",
				Font="_open sans 40px",
				Text=Songs[pos][1]:GetDisplayArtist(),
				OnCommand=function(self) self:zoom(.3):halign(0):y(10):maxwidth(650) end
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
					GAMESTATE:SetCurrentSteps(PLAYER_1,Songs[CurSong][2])
					GAMESTATE:SetCurrentSteps(PLAYER_2,Songs[CurSong][2])
				else
				
					-- If we are single player, Use Single.
					GAMESTATE:SetCurrentStyle('single')
					
					-- Save Profile.
					PROFILEMAN:SaveProfile(self.pn)
					
					-- Set the Current Step to use.
					GAMESTATE:SetCurrentSteps(self.pn,Songs[CurSong][2])
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
			end			
		end,
		
		-- Change to ScreenGameplay.
		StartSongCommand=function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,
		
		Def.Sprite{
			Texture=THEME:GetPathG("Info","Display"),
			OnCommand=function(self) self:zoom(.5):xy(SCREEN_CENTER_X-200, SCREEN_CENTER_Y-60) end
		},
		
		Wheel..{OnCommand=function(self) self:Center() end}
	}
end