-- Reset Joined Players.
Joined = nil

-- Insantly go to DDR Wheel.
return Def.ActorFrame {
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():SetNextScreenName("DDRSelectMusic"):StartTransitioningScreen("SM_GoToNextScreen")
	end
};
