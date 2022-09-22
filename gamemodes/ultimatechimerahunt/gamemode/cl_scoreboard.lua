
for k, v in pairs(file.Find(GM.Folder .. "/gamemode/scoreboard/*.lua", "GAME")) do
	include("scoreboard/" .. v);
end

LocalPlayer().Scoreboard = nil;


function SetCenteredPosition(panel, x, y)
	
	local w, h = panel:GetSize();
	panel:SetPos((x - (w * .5)), (y - (h * .5)));
	
end


function GM:ScoreboardShow()
	
	local ply = LocalPlayer();
	
	if (!ply.Scoreboard) then
		CreateScoreboard();
	end
	
	gui.EnableScreenClicker(true);
	ply.Scoreboard:SetVisible(true);
	
	UpdateScoreboard(ply.Scoreboard);
	
end


function GM:ScoreboardHide()
	
	if (GetState() == STATE_VOTING && CurTime() < GetGlobalFloat("VoteStartTime")) then
		return;
	end
	
	local ply = LocalPlayer();
	
	if (ply.Scoreboard) then
		ply.Scoreboard:SetVisible(false);
	end
	
	gui.EnableScreenClicker(false);
	
end


function CreateScoreboard()
	
	local ply = LocalPlayer();
	
	if (!ply.Scoreboard) then
		
		ply.Scoreboard = vgui.Create("UCScoreboard");
		UpdateScoreboard(ply.Scoreboard);
		
	end
	
end
