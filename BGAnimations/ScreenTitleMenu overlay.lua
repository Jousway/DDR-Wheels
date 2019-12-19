Joined = nil

return Def.ActorFrame {
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():SetNextScreenName("DDRSelectMusic"):StartTransitioningScreen("SM_GoToNextScreen")
	end
};
