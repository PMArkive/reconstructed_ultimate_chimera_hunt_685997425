
include("shared.lua")
include("cl_hud.lua")
include("cl_killnotices.lua")
include("cl_help.lua")
include("cl_scoreboard.lua")
include("cl_selectscreen.lua")
include("cl_splashscreen.lua")
include("cl_voice.lua")

include("vgui_vote.lua")

music = CreateClientConVar( "uch_music", "1" )

function Initialize()
	
	self.BaseClass:Initialize();
	
end

surface.CreateFont("FRETTA_HUGE", {font = "Trebuchet MS", size = 69, weight = 700, antialias = true, additive = false});
surface.CreateFont("FRETTA_HUGE_SHADOW", {font = "Trebuchet MS", size = 69, weight = 700, antialias = true, additive = false, shadow = true});
surface.CreateFont("FRETTA_LARGE", {font = "Trebuchet MS", size = 40, weight = 700, antialias = true, additive = false});
surface.CreateFont("FRETTA_LARGE_SHADOW", {font = "Trebuchet MS", size = 40, weight = 700, antialias = true, additive = false, shadow = true});
surface.CreateFont("FRETTA_MEDIUM", {font = "Trebuchet MS", size = 19, weight = 700, antialias = true, additive = false});
surface.CreateFont("FRETTA_MEDIUM_SHADOW", {font = "Trebuchet MS", size = 19, weight = 700, antialias = true, additive = false, shadow = true});
surface.CreateFont("FRETTA_SMALL", {font = "Trebuchet MS", size = 16, weight = 700, antialias = true, additive = false});

--Normal
local txtmat = surface.GetTextureID("uch/logo/logo1");
local tailmat = surface.GetTextureID("uch/logo/logo2");
local birdmat = surface.GetTextureID("uch/logo/logo3");
local btnmat = surface.GetTextureID("uch/logo/logo4");
local wingmat = surface.GetTextureID("uch/logo/logo5");
local expmat = surface.GetTextureID("uch/logo/logo6");
--Halloween
local htxtmat = surface.GetTextureID("uch/logo/halloween/logo1");
local htailmat = surface.GetTextureID("uch/logo/halloween/logo2");
local hwingmat = surface.GetTextureID("uch/logo/halloween/logo5");
--Christmas
local ctxtmat = surface.GetTextureID("uch/logo/christmas/logo1");
local ctailmat = surface.GetTextureID("uch/logo/christmas/logo2");
local cwingmat = surface.GetTextureID("uch/logo/christmas/logo5");

local sweat = Material("uch/effects/scared");
local speechbubble = Material("uch/effects/typing");

local waverot = 0;
local wavetime = (CurTime() + 6);


local function LogoThink()
	
	//waving (!)
	local t = (wavetime - CurTime());
	if (t < 0) then
		wavetime = (CurTime() + math.random(12, 24));
	end
	if (t > 1.25) then
		waverot = math.Approach(waverot, 0, (FrameTime() * 75));
	else
		local num = (16 * math.sin((CurTime() * 12)))
		waverot = math.Approach(waverot, num, (FrameTime() * 400));
	end
	
end
hook.Add("Think", "LogoThink", LogoThink);


function DrawLogo(x, y, size)
	
	local size = (size || 1); //size unspecified? default to 1
	
	surface.SetDrawColor(255, 255, 255, 255);
	
	local txtw = ((ScrH() * .8) * size);
	local txth = (txtw * .5);
	
	//Wing 1
	local w = (txth * .575);
	local h = w;
	
	local deg = 8;
	local sway = (deg * math.sin((CurTime() * 1.25)));
	local season = GetGlobalInt("SeasonalHUD");
	
	--Logo Wing Switch
	if (season == 1) then
		surface.SetTexture(hwingmat);
	elseif (season == 2) then
		surface.SetTexture(cwingmat);
	else
		surface.SetTexture(wingmat);
	end
	surface.DrawTexturedRectRotated((x - (txtw * .038)), (y - (txth * .205)), w, h, (-36 + sway));
	
	//Button
	local w = (txth * .116);
	local h = w;
	
	surface.SetTexture(btnmat);
	surface.DrawTexturedRect((x - (txtw * .0625)), (y - (txth * .27)), w, h);
	
	//Wing 2
	local w = (txth * .575);
	local h = w;
	
	local deg = 8;
	local sway = (deg * math.sin((CurTime() * 1)));
	
	--Logo Wing 2 Switch
	if (season == 1) then
		surface.SetTexture(hwingmat);
	elseif (season == 2) then
		surface.SetTexture(cwingmat);
	else
		surface.SetTexture(wingmat);
	end
	surface.DrawTexturedRectRotated((x - (txtw * .05)), (y - (txth * .21)), w, h, (-4 + sway));
	
	//Tail
	local w = (txtw * .14);
	local h = (w * 4);
	local deg = 6;
	local sway = (deg * math.sin((CurTime() * 2)));
	
	--Logo Tail Switch
	if (season == 1) then
		surface.SetTexture(htailmat);
	elseif (season == 2) then
		surface.SetTexture(ctailmat);
	else
		surface.SetTexture(tailmat);
	end
	surface.DrawTexturedRectRotated((x - (txtw * .255)), (y - (txth * .145)), w, h, (-6 + sway));
	
	//Bird
	local w = (txth * .28);
	local h = w;
	
	surface.SetTexture(birdmat);
	surface.DrawTexturedRect((x + (txtw * .146)), (y - (txth * .3575)), w, h);
	
	// (!)
	local w = (txth * .64);
	local h = w;
	
	surface.SetTexture(expmat);
	surface.DrawTexturedRectRotated((x + (txtw * .2425)), (y + (txth * .09)), w, h, waverot);
	
	//Text
	--Main Logo Switch
	if (season == 1) then
		surface.SetTexture(htxtmat);
	elseif (season == 2) then
		surface.SetTexture(ctxtmat);
	else
		surface.SetTexture(txtmat);
	end
	surface.DrawTexturedRect((x - (txtw * .5)), (y - (txth * .5)), txtw, txth);
	
end


function PositionScoreboard(ScoreBoard)
	
	ScoreBoard:SetSize(700, ScrH() - 100);
	ScoreBoard:SetPos((ScrW() - ScoreBoard:GetWide()) / 2, 50);
	
end


function PaintSplashScreen()
	DrawLogo((ScrW() * .5), (ScrH() * .15));
end


function GM:RenderScreenspaceEffects()
	
	DrawEffects();
	
	local ply = LocalPlayer();
	
	if (ply:IsGhost() && !ply:IsSpectating()) then
		DoGhostEffects();
	end
	
	local target = ply:GetObserverTarget();
	
	if (ply:NightVisionIsOn()) then
		DoNightVision(ply);
	elseif (IsValid(target) && target:NightVisionIsOn()) then
		DoNightVision(target);
	end
	
	for k, v in pairs(player.GetAll()) do
		
		v.skin, v.bgroup, v.bgroup2 = (v.skin || nil), (v.bgroup || nil), (v.bgroup2 || nil);
		
		if (v:Alive()) then
			v.skin = v:GetSkin();
			v.bgroup = v:GetBodygroup(1);
			v.bgroup2 = v:GetBodygroup(2);
		end
		
		rag = v:GetRagdollEntity();
		if (IsValid(rag)) then
			if (!v:IsUC()) then
				rag:SetSkin(v.skin or 1);
				if (v.bgroup != nil) then
					rag:SetBodygroup(1, v.bgroup);
					rag:SetBodygroup(2, v.bgroup2);
				end
				
				if (!rag.Flew && v.RagShouldFly) then
					rag.Flew = true;
					v.RagShouldFly = false;
					local uc = GetUC();
					if (!IsValid(uc)) then return end
					local dir = (uc:GetForward() + Vector(0, 0, .75));
					for i = 0, (rag:GetPhysicsObjectCount() - 1) do
						rag:GetPhysicsObjectNum(i):ApplyForceCenter((dir * 50000));
					end
					rag:EmitSound("uch/pigs/squeal_" .. tostring(math.random(1, 3)) .. ".mp3", 100, math.random(90, 105));
				end
				
			else
				rag:SetSkin(1);
				rag:SetBodygroup(1, 0);
			end
		end
		
		if (v:IsPancake()) then
			v:DoPancakeEffect();
		else
			v.PancakeNum = 1;
			local scale = Vector( 1,1,1 )
			local mat = Matrix();
			mat:Scale( scale );
			v:EnableMatrix( "RenderMultiply", mat );
		end
		
	end
	
end


function GM:PrePlayerDraw(ply)
	
	if ((ply:IsGhost() && (!LocalPlayer():IsGhost() || LocalPlayer():IsSpectating() || ply:IsSpectating() || ply:GetModel() != "models/uch/mghost.mdl")) || (ply:IsUC() && !ply:Alive())) then
		ply:DrawShadow(false);
		return true;
	end
	
	ply:DrawShadow(true);
	
end


function DrawEffects()
	
	local ply = LocalPlayer();
	
	for k, v in ipairs(player.GetAll()) do
		
		//pixel visible stuff
		if (!v.PixVis) then
			v.PixVis = util.GetPixelVisibleHandle();
		end
		
		if (!v.SpeechBubbleAlpha) then
			v.SpeechBubbleAlpha = 0;
		end
		
		if (!v.SweatAlpha) then
			v.SweatAlpha = 0;
		end
		
		local vis = util.PixelVisible(v:GetShootPos(), 16, v.PixVis);
		
		if (vis && vis != 0) then
			if (v:IsTyping()) then
				v.SpeechBubbleAlpha = math.Approach(v.SpeechBubbleAlpha, 250, (FrameTime() * 750));
			else
				v.SpeechBubbleAlpha = math.Approach(v.SpeechBubbleAlpha, 0, (FrameTime() * 1250));
			end
			if (v:IsScared()) then
				v.SweatAlpha = math.Approach(v.SweatAlpha, 250, (FrameTime() * 750));
			else
				v.SweatAlpha = math.Approach(v.SweatAlpha, 0, (FrameTime() * 1250));
			end
		end	
		
		if (v:Alive() || (ply:IsGhost() && !ply:IsSpectating() && !v:IsSpectating() && !v:IsUC())) then
			if (v.SpeechBubbleAlpha > 0) then
				cam.Start3D(EyePos(), EyeAngles())
					render.SetMaterial(speechbubble);
					local pos = (v:GetShootPos() + Vector(0, 0, 22));
					pos = (pos + (EyeAngles():Right():GetNormal() * 12));
					local clr = Color(255, 255, 255, v.SpeechBubbleAlpha);
					render.DrawSprite(pos, 16, 12, clr);
				cam.End3D()
			elseif (v.SweatAlpha > 0) then
				cam.Start3D(EyePos(), EyeAngles())
					render.SetMaterial(sweat);
					local pos = (v:GetShootPos() + Vector(0, 0, 22));
					pos = (pos + (EyeAngles():Right():GetNormal() * 12));
					local clr = Color(255, 255, 255, v.SweatAlpha);
					render.DrawSprite(pos, 16, 12, clr);
				cam.End3D()
			end
		end
		
	end
	
end


local function MakeRagFly()
	local ply = net.ReadEntity();
	ply.RagShouldFly = true;
end
net.Receive("UCMakeRagFly", MakeRagFly);


function GM:OnPlayerChat(player, strText, bTeamOnly, bPlayerIsDead)
	
	local tab = {};
	
	if (IsValid(player)) then
		if (player:IsGhost()) then
			table.insert(tab, Color(200, 200, 200));
			local str = (player:GetBodygroup(1) == 1 && "Fancy ") || "Spooky ";
			table.insert(tab, str .. player:GetName());
		else
			table.insert(tab, player);
		end
	else
		table.insert(tab, "Console");
	end
	table.insert(tab, Color(255, 255, 255));
	table.insert(tab, ": ");
	if (IsValid(player) && player:IsAdmin()) then
		table.insert(tab, Color(200, 230, 255));
	end
	table.insert(tab, strText);
	
	chat.AddText(unpack(tab));
	
	return true;
	
end


-- Map Voting --

local GMChooser = nil;


function GetVoteScreen()
	
	if (IsValid(GMChooser)) then return GMChooser end
	
	GMChooser = vgui.Create("VoteScreen");
	return GMChooser;
	
end


function ShowVoteScreen()
	
	local votescreen = GetVoteScreen();
	votescreen:ChooseMap(self);
	
	local ply = LocalPlayer();
	
	if (ply.Scoreboard) then
		ply.Scoreboard:SetVisible(false);
	end
	
end


function ShowMiddleText(text)
	color = Color(230, 30, 110, 255);
	duration = 7;
	fade = .5;
	local start = CurTime();
	
	local function DrawToScreen()
		local alpha = 255;
		local dtime = CurTime() - start;
		
		if (dtime > duration) then
			hook.Remove("HUDPaint", "UCHMiddleText");
			return;
		end
		
		if (fade - dtime > 0) then
			alpha = (fade - dtime) / fade;
			alpha = 1 - alpha;
			alpha = alpha * 255;
		end
		
		if (duration - dtime < fade) then
			alpha = (duration - dtime) / fade; -- 0 to 1
			alpha = alpha * 255;
		end
		color.a  = alpha;
		
		DrawNiceText(text, "UCH_KillFont", ScrW() * .5, ScrH() * .1, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, alpha);
	end
	hook.Add("HUDPaint", "UCHMiddleText", DrawToScreen);
	
end


local function PlayMusic()
	if (!timer.Exists("WaitingMusic") && music:GetBool()) then
		surface.PlaySound("uch/music/" .. net.ReadString() .. ".mp3");
	end
end
net.Receive("PlayMusic", PlayMusic);


function WaitingMusic(last)
	local musicnumber = math.random(1,27);
	if (musicnumber == last) then
		WaitingMusic(musicnumber);
		return;
	end
	local list = file.Read("gamemodes/ultimatechimerahunt/content/data/uch/music/waiting.txt", "GAME");
	local duration = string.Explode(";", list)[musicnumber];
	timer.Create("WaitingMusic", duration, 1, function() WaitingMusic(musicnumber) end);
	if (music:GetBool()) then
		surface.PlaySound("uch/music/waiting/" .. musicnumber .. ".mp3");
	end
end
