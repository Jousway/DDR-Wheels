return function(Style)

	local AllCompSongs = {}
		
	for _, CurSong in pairs(SONGMAN:GetAllSongs()) do
		local DiffCon = {}
		local CurSongCon = {CurSong}		
		for i, CurStep in ipairs(CurSong:GetAllSteps()) do
			if string.find(CurStep:GetStepsType():lower(), Style) then
				DiffCon[tonumber(DDR.DiffTab[CurStep:GetDifficulty()])] = CurStep	
			end
		end
		
		local Keys = {}
		for k in pairs(DiffCon) do table.insert(Keys, k) end
		table.sort(Keys)
		
		for _, k in pairs(Keys) do
			if DiffCon[k] then
				CurSongCon[#CurSongCon+1] = DiffCon[k]
			end
		end
		
		if CurSongCon[2] then				
			AllCompSongs[#AllCompSongs+1] = CurSongCon
		end
	end	
	
	return AllCompSongs
end