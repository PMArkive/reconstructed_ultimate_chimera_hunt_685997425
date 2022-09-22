
include("cl_targetid.lua")

local sw, sh = ScrW(), ScrH();

local xhairtex = surface.GetTextureID("uch/hud/crosshair_main");
local glass = surface.GetTextureID("uch/hud/crosshair_glass");
local walking = surface.GetTextureID("uch/hud/counter_walking");
local running = surface.GetTextureID("uch/hud/counter_running");
local dead = surface.GetTextureID("uch/hud/counter_dead");
local saluting = surface.GetTextureID("uch/hud/counter_saluting");
local sitting = surface.GetTextureID("uch/hud/counter_sitting");
local stocktex = surface.GetTextureID("uch/logo/logo6");


local function TextSize(font, txt)
	surface.SetFont(font);
	local w, h = surface.GetTextSize(txt);
	return {w, h};
end


function DrawNiceText(txt, font, x, y, clr, alignx, aligny, dis, alpha)
	
	local tbl = {};
	tbl.pos = {};
	tbl.pos[1] = x;
	tbl.pos[2] = y;
	tbl.color = clr;
	tbl.text = txt;
	tbl.font = font;
	tbl.xalign = alignx;
	tbl.yalign = aligny;
	
	draw.TextShadow(tbl, dis, alpha);
	
end


local function DrawNiceBox(x, y, w, h, clr, dis)
	
	local clr2 = Color(clr.r, clr.g, clr.b, (clr.a * .5));
	
	draw.RoundedBox(4, (x - dis), (y - dis), (w + (dis * 2)), (h + (dis * 2)), clr);
	draw.RoundedBox(2, x, y, w, h, clr2);
	
end


function DrawInfoBox(txt, x, y, clr)
	
	local dis = (sh * .01);
	local bob = math.sin((CurTime() * 4));
	
	y = (y + (dis * bob));
	
	local tsize = TextSize("UCH_TargetID_Name", txt);
	local tw, th = tsize[1], tsize[2];
	local w, h = (tw + th), (th * 1.2);
	DrawNiceBox((x - (w * .5)), (y - (h * .5)), w, h, Color(10, 10, 10, 125), 4);
	
	DrawNiceText(txt, "UCH_TargetID_Name", x, y, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 250);
	
end


function DrawCrosshair()
	
	local ply = LocalPlayer();
	local xalpha = 100;
	
	ply.XHairAlpha = (ply.XHairAlpha || xalpha);
	local alpha = ply.XHairAlpha;
	
	if (alpha != xalpha) then
		ply.XHairAlpha = math.Approach(ply.XHairAlpha, xalpha, (FrameTime() * 150));
	end
	
	local r, g, b;
	local target = ply:GetObserverTarget();
	
	if (ply:IsGhost()) then
		if (!IsValid(target)) then
			r, g, b = 250, 250, 250;
		else
			r, g, b = target:GetRankColor();
		end
	else
		r, g, b = ply:GetRankColor();
	end
	
	local clr = Color(r, g, b, alpha);
	
	surface.SetTexture(xhairtex);
	surface.SetDrawColor(clr);
	surface.DrawTexturedRectRotated((sw * .5), (sh * .5), (sh * .04), (sh * .04), 0);
	
	if (ply:IsGhost() && !IsValid(target) && ply:GetBodygroup(1) == 1) then
		
		surface.SetTexture(glass);
		surface.SetDrawColor(Color(255, 255, 255, 160));
		surface.DrawTexturedRectRotated((sw * .515), (sh * .5), (sh * .028), (sh * .028), -12);
		
	end
	
end


local xx, yy, ww, hh = .28, .2725, .375, .12;


local function CCXX(ply, cmd, args)
	xx = tonumber(args[1]);
end
concommand.Add("xx", CCXX);


local function CCYY(ply, cmd, args)
	yy = tonumber(args[1]);
end
concommand.Add("y", CCYY);


local function CCWW(ply, cmd, args)
	ww = tonumber(args[1]);
end
concommand.Add("ww", CCWW);


local function CCHH(ply, cmd, args)
	hh = tonumber(args[1]);
end
concommand.Add("hh", CCHH);


--NormalHUD
local pigmat = surface.GetTextureID("uch/hud/main_pigs");
local pigCmat = surface.GetTextureID("uch/hud/main_pigs_colonel");
local pigEmat = surface.GetTextureID("uch/hud/main_pigs_ensign");
local ucmat = surface.GetTextureID("uch/hud/main_chimera");
--HalloweenHUD
local hpigEmat = surface.GetTextureID("uch/hud/halloween/main_pigs_ensign");
local hpigCmat = surface.GetTextureID("uch/hud/halloween/main_pigs_captain");
local hpigMmat = surface.GetTextureID("uch/hud/halloween/main_pigs_major");
local hpigCOmat = surface.GetTextureID("uch/hud/halloween/main_pigs_colonel");
local hucmat = surface.GetTextureID("uch/hud/halloween/main_chimera");
--ChristmasHUD
local cpigEmat = surface.GetTextureID("uch/hud/christmas/main_pigs_ensign");
local cpigCmat = surface.GetTextureID("uch/hud/christmas/main_pigs_captain");
local cpigMmat = surface.GetTextureID("uch/hud/christmas/main_pigs_major");
local cpigCOmat = surface.GetTextureID("uch/hud/christmas/main_pigs_colonel");
local cucmat = surface.GetTextureID("uch/hud/christmas/main_chimera");


function DrawHUD()
	
	local ply = LocalPlayer();
	
	if (ply:IsGhost()) then
		return;
	end
	
	local state = GetState();
	local counter;
	local winner = GetGlobalString( "Winningteam" );
	
	if (state == STATE_PLAYING) then
		if (team.AlivePlayers(TEAM_PIGS) > 1) then
			counter = walking;
		else
			counter = running;
		end
	elseif (state == STATE_INTERMISSION) then
		if (winner == "uc" || winner == "tie") then
			counter = dead;
		elseif (winner == "pigs") then
			counter = saluting;
		else
			counter = sitting;
		end
	elseif (state == STATE_VOTING) then
		if (winner == "uc" || winner == "tie") then
			counter = dead;
		else
			counter = sitting;
		end
	end
	
	local pcx, pcy = (sw * .9), (sh - (sw * .09));
	local pch = (sw * .07);
	
	if (counter != nil) then
		surface.SetTexture(counter);
		surface.SetDrawColor(Color(255, 255, 255, 255));
		surface.DrawTexturedRect(pcx, pcy, pch, pch);
		DrawNiceText(team.AlivePlayers(TEAM_PIGS), "UCH_TargetID_Name", (pcx + pch), (pcy + (pch * .4)), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 250);
	end
	
	local mat = pigmat;
	local season = GetGlobalInt("SeasonalHUD");
	
	if (ply:IsUC()) then
		--Seasonal UC HUD Switch
		if (season == 1) then
			mat = hucmat;
		elseif (season == 2) then
			mat = cucmat;
		else
			mat = ucmat;
		end
		
		local x, y = (sw * -.0385), (sh * .732);
		local w, h = (sh * .57), (sh * .285);
		
		local spx, spy = (x + (w * .285)), (y + (h * .58));
		local spw, sph = (w * .505), (h * .145);
		DrawSprintBar(spx, spy, spw, sph);
		
		local rrx, rry = (x + (w * .2825)), (y + (h * .43));
		local rrw, rrh = (w * .3775), (h * .115);
		DrawRoarMeter(rrx, rry, rrw, rrh);
		
		local tsx, tsy = (x + (w * .28)), (y + (h * .2725));
		local tsw, tsh = (w * .375), (h * .12);
		DrawSwipeMeter(tsx, tsy, tsw, tsh);
		
		surface.SetTexture(mat);
		surface.SetDrawColor(Color(255, 255, 255, 255));
		surface.DrawTexturedRect(x, y, w, h);
		
		local rsx1, rsx2 = (x + (w * .6)), (x + (w * .66));
		local rsy = (y + (h * .32));
		local rsw, rsh = (w * .18), (h * .36);
		
		local rsc1;
		local rsc2;
		local stock = ply:GetStock();
		if (stock >= 2) then
			rsc1, rsc2 = 255, 255;
		elseif (stock == 1) then
			rsc1, rsc2 = 255, 128;
		else
			rsc1, rsc2 = 128, 128;
		end
		
		surface.SetTexture(stocktex);
		surface.SetDrawColor(Color(rsc1, rsc1, rsc1, rsc1));
		surface.DrawTexturedRect(rsx1, rsy, rsw, rsh);
		surface.SetDrawColor(Color(rsc2, rsc2, rsc2, rsc2));
		surface.DrawTexturedRect(rsx2, rsy, rsw, rsh);
		
	else
		
		local x, y = (sw * -.035), (sh * .85);
		local w, h = (sh * .56), (sh * .14);
		
		local spx, spy = (x + (w * .286)), (y + (h * .35));
		local spw, sph = (w * .51), (h * .275);
		DrawSprintBar(spx, spy, spw, sph);
		
		local r, g, b = ply:GetRankColorSat();
		local rank = ply:GetRank();
		
		--Seasonal HUD Switch
		if (season == 1) then
			if (rank == "Ensign") then
				mat = hpigEmat;
				r, g, b = 255, 255, 255;
			elseif (rank == "Captain") then
				mat = hpigCmat
				r, g, b = 255, 255, 255;
			elseif (rank == "Major") then
				mat = hpigMmat
				r, g, b = 255, 255, 255;
			elseif (rank == "Colonel") then
				mat = hpigCOmat
				r, g, b = 255, 255, 255;
			end
		elseif (season == 2) then
			if (rank == "Ensign") then
				mat = cpigEmat;
			elseif (rank == "Captain") then
				mat = cpigCmat
			elseif (rank == "Major") then
				mat = cpigMmat
			elseif (rank == "Colonel") then
				mat = cpigCOmat
			end
		else
			if (rank == "Colonel") then
				mat = pigCmat;
			end
			
			if (rank == "Ensign") then
				mat = pigEmat;
			end
		end
		
		surface.SetTexture(mat);
		surface.SetDrawColor(Color(r, g, b, 255));
		surface.DrawTexturedRect(x, y, w, h);
		
	end
	
end


function GM:HUDPaint()
	
	local ply = LocalPlayer();
	
	//Draw HUD here!
	
	if (GetState() == STATE_WAITING) then
		
		local txt = nil;
		
		local waittime = GetGlobalInt("WaitTime");
		
		if (CurTime() < waittime + 1.2) then
			
			txt = "Starting in " .. tostring(math.Clamp(math.ceil(waittime + 1.2 - CurTime()), 0, waittime)) .. " second(s)...";
			
		elseif (!PlayersFrozen()) then
			
			txt = "Waiting for players...";
			
		else
			
			txt = "Starting...";
			
		end
		
		if (txt != nil) then
			
			DrawInfoBox(txt, (sw * .5), (sh * .185), Color(255, 255, 255, 255));
			
		end
		
	end
	
	local target = ply:GetObserverTarget();
	
	if (IsValid(target)) then
		local r, g, b = target:GetRankColor();
		DrawInfoBox("Spectating " .. target:Nick(), (sw * .5), (sh * .185), Color(r, g, b, 255));
	end
	
	if ((ply:Alive() && ply:Team() == TEAM_PIGS && !ply:IsTaunting() && !ply:IsScared()) || (ply:IsGhost() && (!IsValid(target) || (!target:IsUC() && ply:GetObserverMode() == OBS_MODE_IN_EYE)))) then
		DrawCrosshair();
	end
	
	DrawHUD();
	
	DrawKillNotices();
	DrawTargetID();
	DrawRoundTime();
	
	//self.BaseClass:HUDPaint();
	
end


function GM:HUDShouldDraw(name)
	
	local hud = {
		"CHudHealth",
		"CHudBattery",
		"CHudAmmo",
		"CHudSecondaryAmmo",
		"CHudCrosshair",
		"CHudWeapon"
	};
	
	for _, v in ipairs(hud) do
		if (name == v) then
			return false;
		end
	end
	
	return true;
	
end
