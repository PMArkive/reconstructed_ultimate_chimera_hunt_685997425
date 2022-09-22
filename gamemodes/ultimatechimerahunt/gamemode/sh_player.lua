
AddCSLuaFile("sh_ranks.lua");
AddCSLuaFile("sh_sprinting.lua");
AddCSLuaFile("sh_animation_controller.lua");
AddCSLuaFile("sh_uccontrol.lua");
AddCSLuaFile("sh_scared.lua");
AddCSLuaFile("sh_pancake.lua");

include("sh_ply_extensions.lua")
include("sh_ranks.lua")
include("sh_sprinting.lua")
include("sh_animation_controller.lua")
include("sh_ghost.lua")
include("sh_uccontrol.lua")
include("sh_scared.lua")
include("sh_pancake.lua")


function FreezePlayers(b)
	local state = GetState();
	for k, v in ipairs(player.GetAll()) do
		if (v:Team() != TEAM_SPECTATE || state == STATE_VOTING) then
			v:Freeze(b);
		end
	end
	SetGlobalBool("PlayersFrozen", b);
end


function PlayersFrozen()
	return (GetGlobalBool("PlayersFrozen"));
end


function GetUC()
	return GetGlobalEntity("UltimateChimera");
end


function GM:PlayerFootstep(ply, pos, foot, sound, volume, players)
	
	if (!ply:Alive() || ply:Team() != TEAM_PIGS) then
		return true;
	end
	
end


function RestartAnimation(ply)
	
	ply:AnimRestartMainSequence();
	
	net.Start("UC_RestartAnimation")
		net.WriteEntity(ply);
	net.Send(player.GetAll())
	
end


if (SERVER) then
	
	
	function GM:KeyPress(ply, key)
		
		if (ply:Alive() && ply:Team() == TEAM_PIGS) then
			
			SprintKeyPress(ply, key);
			
		end
		
		if (ply:IsGhost()) then
			
			GhostKeyPress(ply, key);
			
		end
		
		if (ply:IsUC()) then
			UCKeyPress(ply, key);
		end
		
		if (key == IN_ATTACK2 && ply:CanTaunt()) then
			
			local t, num = "taunt", 1.1;
			
			if (ply:GetRankNum() == 4) then
				t, num = "taunt2", 1;
			end
			
			ply:Taunt(t, num);
			
		end
		
		if (key == IN_USE || key == IN_ATTACK) then
			
			ply.LastPressAttempt = (ply.LastPressAttempt || 0);
			
			if (CurTime() < ply.LastPressAttempt) then
				return;
			end
			
			ply.LastPressAttempt = (CurTime() + .1);
			
			if (ply:Alive() && ply:Team() == TEAM_PIGS) then
				
				if (ply:CanPressButton()) then
					
					local uc = GetUC();
					
					uc:EmitSound("uch/chimera/button.mp3", 80, math.random(94, 105));
					
					uc.Pressed = true;
					uc.Presser = ply;
					
					ply:RankUp();
					uc:Kill();
					
					ply:AddFrags(1);
					
				end
				
			end
			
		end
		
	end
	
	
	function GM:Move(ply, move)
		
		if (ply:IsGhost()) then
			
			local move = ply:GhostMove(move);
			
			return move;
			
		else
			
			if (ply:IsTaunting() || ply:IsBiting() || ply:IsRoaring() || (ply:IsUC() && !ply:Alive())) then
				ply:SetLocalVelocity(Vector(0, 0, 0));
				
				if (ply.LockTauntAng == nil) then
					ply.LockTauntAng = ply:EyeAngles();
				end
				
				ply:SetEyeAngles(ply.LockTauntAng);
				
				return true;
				
			else
				
				ply.LockTauntAng = nil;
				return self.BaseClass:Move(ply, move);
				
			end
			
		end
		
	end
	
	
	function GM:PlayerSwitchFlashlight(ply, SwitchOn)
		if (ply:Alive()) then
			if (ply:IsUC()) then
				ply:ToggleNightVision();
			elseif (ply:Team() == TEAM_PIGS) then
				net.Start("SwitchLight")
					net.WriteEntity(ply);
				net.Send(player.GetAll())
			end
		end
		return ((ply:Alive() && ply:Team() == TEAM_PIGS) || !SwitchOn);
	end
	
	
	function GM:CanPlayerSuicide(ply)
		
		if (!ply:Alive() || ply:Team() != TEAM_PIGS) then
			return false;
		end
		
		if (Playing()) then
			ply:ResetRank();
		end
		ply.Suicide = true;
		ply:Kill();
		
		return false;
		
	end
	
	
	function GM:OnPlayerChangedTeam(ply, oldteam, newteam)
		
		self.BaseClass:OnPlayerChangedTeam(ply, oldteam, newteam);
		
	end
	
	
	function ResetPlayers()
		StopMusic();
		local state = GetState();
		for k, v in ipairs(player.GetAll()) do
			if (v:Team() != TEAM_SPECTATE) then
				if (state == STATE_PLAYING) then
					v:SetDead(false);
				else
					v:SetDead(true);
					v:SendLua("timer.Create(\"WaitingMusic\", 4, 1, WaitingMusic)");
				end
				v:Spawn();
			end
			v:PlaySpawnSound();
		end
		FreezePlayers(false);
	end
	
	
	function UpdateHull(ply)
		
		if (ply:IsUC()) then
			
			ply:SetHull(Vector(-25, -25, 0), Vector(25, 25, 55));
			ply:SetHullDuck(Vector(-25, -25, 0), Vector(25, 25, 55));
			
			ply:SetViewOffset(Vector(0, 0, 68));
			ply:SetViewOffsetDucked(Vector(0, 0, 68));
			
		else
			
			ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 55));
			ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 40));
			
			ply:SetViewOffset(Vector(0, 0, 48));
			ply:SetViewOffsetDucked(Vector(0, 0, (48 * .75)));
			
			if (ply:IsGhost()) then
				
				ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 55));
				ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 55));
				
				ply:SetViewOffset(Vector(0, 0, 55));
				ply:SetViewOffsetDucked(Vector(0, 0, 55));
				
			end
			
		end
		
		timer.Simple(.1, function()
			net.Start("UpdateHulls")
				net.WriteEntity(ply);
			net.Send(player.GetAll())
		end);
		
	end
	
	
	function SetUC(ply)
		if (!ply:IsUC()) then
			SetGlobalEntity("UltimateChimera", ply);
			ply.UCChance = -1;
		end
	end
	
	
	function RemoveUC()
		SetGlobalEntity("UltimateChimera", NULL);
	end
	
	
	function NewUC()
		
		local uc = GetUC();
		
		RemoveUC();
		
		local tbl, plys = {}, player.GetAll();
		for k, v in ipairs(plys) do
			
			v.UCChance = (v.UCChance || 1);
			
			if (v != uc && v.UCChance > 0 && v:Team() == TEAM_PIGS) then
				
				for i = 1, v.UCChance do
					table.insert(tbl, v);
				end
				
			end
			
		end
		
		if (#tbl < 1) then
			return;
		end
		
		local ply = table.Random(tbl);
		
		SetUC(ply);
		NotifyPlayers(ply:Name() .. " is the new Ultimate Chimera!");
		
	end
	
	
	function NotifyPlayers(txt)
		BroadcastLua("ShowMiddleText(\"" .. txt .. "\")")
		chat.AddText(Color(255, 255, 255), txt);
	end
	
	
	function GM:PlayerUse(ply, ent)
		
		return (!ply:IsGhost());
		
	end
	
	
	function GM:EntityTakeDamage(ent, dmginfo)
		
		local amount = dmginfo:GetDamage();
		if (ent:IsPlayer()) then
			if (!ent:Alive() || ent:Team() != TEAM_PIGS || (ent:Health() - amount) <= 0) then
				
				if (ent:IsUC() && amount > 100) then
					ent:Kill();
				end
				if (ent:Alive() && ent:Team() == TEAM_PIGS && (ent:Health() - amount) <= 0) then
					ent:Kill();
				end
				
				dmginfo:ScaleDamage(0);
				
			end
		end
		
	end
	
	
	function GM:PlayerDeathSound()
		return true;
	end
	
	
	local function GetFallDamage(ply, vel)
		
		if (!ply:Alive() || ply:Team() != TEAM_PIGS) then
			return 0;
		end
		
	end
	hook.Add("GetFallDamage", "GetFallDamage", GetFallDamage);
	
	
else
	
	
	function GM:KeyPress(ply, key)
		
		if (!ply:IsGhost() && (key == IN_ATTACK || key == IN_USE)) then
			LocalPlayer().XHairAlpha = 242;
		end
		
	end
	
	
	local function TauntAngSafeGuard(ply)
		if (ply.TauntAng == nil) then
			local ang = ply:EyeAngles();
			ang.p = 45;
			ply.TauntAng = ang;
		end
	end
	
	
	function GM:ShouldDrawLocalPlayer()
		
		local ply = LocalPlayer();
		
		return ((ply:IsUC() && ply:Alive()) || ply:IsTaunting() || ply:IsScared());
		
	end
	
	
	function GM:InputMouseApply(cmd, x, y, ang)
		
		local ply = LocalPlayer();
		
		if (ply:IsTaunting() || ply:IsRoaring()) then
			
			TauntAngSafeGuard(ply);
			
			local ang = ply.TauntAng;
			
			local y = (x * -GetConVar("m_yaw"):GetFloat());
			
			ang.y = (ang.y + y)
			//ang = ang:GetAngle();
			
			ang.p = 16;
			
			ply.TauntAng = ang;
			
			return true;
			
		end
		
		if (ply:IsBiting() || (ply:IsUC() && !ply:Alive())) then
			return true;
		end
		
	end
	
	
	local function ThirdPersonCamera(ply, pos, ang, fov, dis)
		
		local view = {};
		
		local dir = ang:Forward();
		
		local tr = util.QuickTrace(pos, (dir * -dis), player.GetAll());
		
		local trpos = tr.HitPos;
		
		if (tr.Hit) then
			trpos = (trpos + (dir * 20));
		end
		
		view.origin = trpos;
		
		view.angles = (ply:GetShootPos() - trpos):Angle();
		
		view.fov = fov;
		
		return view;
		
	end
	
	
	function GM:CalcView(ply, pos, ang, fov)
		
		if (ply:IsTaunting() || ply:IsRoaring()) then
			
			TauntAngSafeGuard(ply);
			
			local tang = ply.TauntAng;
			
			local view = {};
			
			local dir = tang:Forward();
			
			local tr = util.QuickTrace(pos, (dir * -115), player.GetAll());
			
			local trpos = tr.HitPos;
			
			if (tr.Hit) then
				trpos = (trpos + (dir * 20));
			end
			
			view.origin = trpos;
			
			view.angles = (ply:GetShootPos() - trpos):Angle();
			
			view.fov = fov;
			
			return view;
			
		else
			
			local tang = ply.TauntAng;
			
			if (tang != nil) then
				
				if (!ply:IsUC()) then
					tang.p = 0;
				end
				
				tang.r = 0;
				ply:SetEyeAngles(tang);
				
				ply.TauntAng = nil;
				
			end
			
			if (ply:IsScared()) then
				return ThirdPersonCamera(ply, pos, ang, fov, 100);
			end
			
			if (ply:IsGhost()) then
				
				local num = 3;
				
				local view = {};
				
				local bob = (math.sin((CurTime() * num)) * 2);
				
				view.origin = Vector(pos.x, pos.y, (pos.z + bob));
				view.angles = ang;
				view.fov = fov;
				return view;
				
			end
			
		end
		
		if (ply:IsUC()) then
			
			if (ply:Alive()) then
				
				return ThirdPersonCamera(ply, pos, ang, fov, 125);
				
			else
				
				local followang = ang;
				
				local rag = ply:GetRagdollEntity();
				GAMEMODE.UCRagdoll = rag;
				if (IsValid(rag)) then
					local pos = (ply:GetPos() - (ply:GetForward() * 800));
					followang = ((rag:GetPos() - Vector(0, 0, 100)) - pos):Angle();
				end
				
				local view = {};
				view.origin = (pos + Vector(0, 0, 25));
				view.angles = followang;
				view.fov = fov;
				
				return view;
				
			end
			
		end
		
		return {ply, pos, ang, fov};
		
	end
	
	
	local function RestartAnimation()
		
		local ply = net.ReadEntity();
		
		if (ply:IsValid()) then
			ply:AnimRestartMainSequence();
		end
		
	end
	net.Receive("UC_RestartAnimation", RestartAnimation);
	
	
	local function UpdateHulls()
		
		local ply = net.ReadEntity();
		
		if (!ply:IsValid()) then
			return;
		end
		
		if (ply:IsUC()) then
			
			ply:SetHull(Vector(-25, -25, 0), Vector(25, 25, 55));
			ply:SetHullDuck(Vector(-25, -25, 0), Vector(25, 25, 55));
			
			ply:SetViewOffset(Vector(0, 0, 68));
			ply:SetViewOffsetDucked(Vector(0, 0, 68));
			
		else
			
			ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 55));
			ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 40));
			
			ply:SetViewOffset(Vector(0, 0, 48));
			ply:SetViewOffsetDucked(Vector(0, 0, (48 * .75)));
			
			if (ply:IsGhost()) then
				
				ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 55));
				ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 55));
				
				ply:SetViewOffset(Vector(0, 0, 55));
				ply:SetViewOffsetDucked(Vector(0, 0, 55));
				
			end
			
		end
		
	end
	net.Receive("UpdateHulls", UpdateHulls);
	
	
end
