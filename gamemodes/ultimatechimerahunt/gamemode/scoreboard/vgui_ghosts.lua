
local ghosts = {};

local ghostmatL = surface.GetTextureID("uch/scoreboard/ghost_spooky_left");
local ghostmatR = surface.GetTextureID("uch/scoreboard/ghost_spooky_right");

local ghostmatwineL = surface.GetTextureID("uch/scoreboard/ghost_fancy_left");
local ghostmatwineR = surface.GetTextureID("uch/scoreboard/ghost_fancy_right");

local sw, sh = ScrW(), ScrH();

local PANEL = {};


function PANEL:Init()
	
end


function PANEL:UpdatePlayerData()
	
	local num, num2 = team.NumPlayers(TEAM_SPECTATE), team.NumPlayers(TEAM_UNASSIGNED);
	
	if ((num + num2) <= 0) then
		ghosts = {};
	end
	
	for k, v in pairs(team.GetPlayers(TEAM_SPECTATE)) do
		if (!table.HasValue(ghosts, v)) then
			table.insert(ghosts, v);
		end
	end
	
	for k, v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do
		if (!table.HasValue(ghosts, v)) then
			table.insert(ghosts, v);
		end
	end
	
	for k, v in pairs(ghosts) do
		
		if ((!v:IsValid() || v:Team() == TEAM_PIGS || v:Team() == TEAM_UC) && ghosts[k] != nil) then
			ghosts[k] = nil;
			return;
		else
		
			if (v:IsValid()) then
				if (!ghosts[k].pos) then
					ghosts[k].pos = math.random(0, sw);
				end
				if (!ghosts[k].dir) then
					ghosts[k].dir = (math.random(1, 2) == 1 && "left" || "right");
				end
				if (!ghosts[k].speed) then
					ghosts[k].speed = math.Rand(1.75, 2.5);
				end
				if (!ghosts[k].bob) then
					ghosts[k].bob = math.Rand(1.5, 3);
				end
			end
			
		end
		
	end
		
end


function PRINTGHOSTS()
	PrintTable(ghosts);
end


function PANEL:DrawGhost(x, y, k)
	
	local ply = ghosts[k];
	
	if (!ply:IsValid()) then
		return;
	end
	
	if (!ply.pos) then
		ply.pos = math.random(0, sw);
	end
	if (!ply.dir) then
		ply.dir = (math.random(1, 2) == 1 && "left" || "right");
	end
	if (!ply.speed) then
		ply.speed = math.Rand(1.75, 2.5);
	end
	if (!ply.bob) then
		ply.bob = math.Rand(1.5, 3);
	end
	
	local pos, dir = ply.pos, ply.dir;
	local speed = ((ply.speed * .2) * (sw / 640));
	local bob = ((ply.bob * .62) * (sw / 640));
	
	local max = (sw * .075);
	
	if (dir == "left") then
		
		if (pos < -max) then
			ply.dir = "right";
		else
			ply.pos = (pos - speed);
		end
		
	else
		
		if (pos > (sw + max)) then
			ply.dir = "left";
		else
			ply.pos = (pos + speed);
		end
		
	end
	
	local mat = (ply.dir == "left" && ghostmatwineL) || (ply.dir == "right" && ghostmatwineR);
	local w, h = (sh * .175), (sh * .175);
	
	if (ply:GetBodygroup(1) != 1) then
		mat = (ply.dir == "left" && ghostmatL) || (ply.dir == "right" && ghostmatR);
		w = (w * .5);
	end
	
	bob = math.sin((CurTime() * bob));
	local center = (self:GetTall() * .8);
	
	local x, y = (x + ply.pos), ((y + center) + (10 * bob));
	
	surface.SetTexture(mat);
	surface.SetDrawColor(255, 255, 255, 255);
	surface.DrawTexturedRectRotated(x, y, w, h, 0);
	
	if (ply:GetBodygroup(1) == 1) then
		local offset = (ScrH() * .0232);
		x = (x + ((dir == "left" && offset) || -offset));
	end
	
	DrawNiceText(ply:GetName(), "UCH_TargetID_Rank", x, (y - (h * .475)), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 255);
	
end


function PANEL:Paint(w, h)
	return;
end


function PANEL:PaintStuff(x, y)
	
	if (#ghosts <= 0) then
		return;
	end
	
	for k, v in pairs(ghosts) do
		
		self:DrawGhost(x, y, k);
		
	end
	
end


vgui.Register("Ghosties", PANEL, "Panel");
