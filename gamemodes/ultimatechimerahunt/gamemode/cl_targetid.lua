
surface.CreateFont("UCH_TargetID_Name", {font = "AlphaFridgeMagnets ", size = ScreenScale(14), weight = 500, antialias = true, additive = false});
surface.CreateFont("UCH_TargetID_Rank", {font = "AlphaFridgeMagnets ", size = ScreenScale(10), weight = 500, antialias = true, additive = false});


function DrawTargetID()
	
	local target;
	local ply = LocalPlayer();
	local spectarget = ply:GetObserverTarget();
	if (!IsValid(spectarget)) then
		target = ply:GetEyeTrace().Entity;
	elseif (ply:GetObserverMode() == OBS_MODE_IN_EYE && !spectarget:IsUC()) then
		target = spectarget:GetEyeTrace().Entity;
	end
	
	ply.TargetAlpha = (ply.TargetAlpha || 0);
	ply.TargetInfo = (ply.TargetInfo || {});
	
	if (IsValid(target) && target:IsPlayer() && ((ply:Alive() && ply:Team() == TEAM_PIGS && target:Alive() && target:Team() == TEAM_PIGS) || (ply:IsGhost() && !target:IsSpectating() && (!IsValid(spectarget) || (target:Alive() && target:Team() == TEAM_PIGS))))) then
		
		if (ply.TargetAlpha != 255) then
			local dis = math.abs(255 - ply.TargetAlpha);
			ply.TargetAlpha = math.Approach(ply.TargetAlpha, 255, (FrameTime() * (dis * 9)));
		end
		
		ply.TargetInfo.ply = target;
		ply.TargetInfo.name = target:GetName();
		ply.TargetInfo.rank = target:GetRank();
		local r, g, b = target:GetRankColor();
		ply.TargetInfo.clr = Color(r, g, b, 255);
		if (target:IsGhost()) then
			if (target:GetBodygroup(1) == 1) then
				ply.TargetInfo.rank = "Fancy Ghostie";
			else
				ply.TargetInfo.rank = "Spooky Ghostie";
			end
			ply.TargetInfo.clr = Color(255, 255, 255, 255);
		elseif (target:IsUC()) then
			ply.TargetInfo.rank = "The Ultimate Chimera";
		end
		
	else
		
		if (ply.TargetAlpha != 0) then
			local dis = ply.TargetAlpha;
			ply.TargetAlpha = math.Approach(ply.TargetAlpha, 0, (FrameTime() * (dis * 9)));
		end
		
	end
	
	if (ply.TargetAlpha > 0) then
		ply.TargetInfo.clr.a = ply.TargetAlpha;
		surface.SetFont("UCH_TargetID_Rank");
		local _, h = surface.GetTextSize(ply.TargetInfo.rank);
		DrawNiceText(ply.TargetInfo.rank, "UCH_TargetID_Rank", (ScrW() * .5), (ScrH() * .55), ply.TargetInfo.clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, ply.TargetAlpha);
		DrawNiceText(ply.TargetInfo.name, "UCH_TargetID_Name", (ScrW() * .5), ((ScrH() * .55) + h), ply.TargetInfo.clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, ply.TargetAlpha);
	end
	
end
