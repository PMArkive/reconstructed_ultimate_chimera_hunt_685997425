
local meta = FindMetaTable("Player");


function meta:IsGhost()
	return ((!self:Alive() && self:Team() == TEAM_PIGS) || self:Team() == TEAM_SPECTATE);
end


function meta:IsSpectating()
	return (self:GetObserverMode() != OBS_MODE_NONE);
end


function GhostKeyPress(ply, key)
	
	local eyetarget = ply:GetEyeTrace().Entity;
	local mode = ply:GetObserverMode();
	local spectarget = ply:GetObserverTarget();
	
	if (key == IN_ATTACK) then
		if (eyetarget:IsPlayer() && eyetarget:Alive() && mode == OBS_MODE_NONE && ply:GetModel() == "models/uch/mghost.mdl") then
			ply:SetObserverMode(OBS_MODE_CHASE);
			ply:SpectateEntity(eyetarget);
		elseif (IsValid(spectarget)) then
			ply:UnSpectate();
			ply:SetPos(spectarget:GetPos());
		end
	end
	
	if (key == IN_ATTACK2) then
		if (mode == OBS_MODE_CHASE) then
			ply:SetObserverMode(OBS_MODE_IN_EYE);
		elseif (mode == OBS_MODE_IN_EYE) then
			ply:SetObserverMode(OBS_MODE_CHASE);
		else
			ply:ChatPrint("You are not currently focused on a player!");
		end
	end
	
end


function meta:GhostMove(move)
	
	if (!self:IsOnGround()) then
		
		local vel = self:GetVelocity();
		
		if (self:KeyDown(IN_JUMP)) then
			
			local num = math.Clamp((vel.z * -.18), 0, 75);
			num = (num * .1);
			
			vel.z = (vel.z + (32 + (5 * num)));
			
			vel.z = math.Clamp(vel.z, -250, 125);
			
		end
		
		/*local fwd, right = self:GetForward(), self:GetRight();
		
		fwd.z = 0;
		right.z = 0;
		fwd:Normalize();
		right:Normalize();
		
		local back, left = (fwd * -1), (right * -1);
		
		local ang = self:EyeAngles();
		
		if (self:KeyDown(IN_FORWARD) && ang:Forward():DotProduct(vel) < 250) then
			vel = (vel + (fwd * 250));
		end
		if (self:KeyDown(IN_BACK) && (ang:Forward() * -1):DotProduct(vel) < 250) then
			vel = (vel + (back * 250));
		end
		if (self:KeyDown(IN_MOVERIGHT) && ang:Right():DotProduct(vel) < 250) then
			vel = (vel + (right * 250));
		end
		if (self:KeyDown(IN_MOVELEFT) && (ang:Right() * -1):DotProduct(vel) < 250) then
			vel = (vel + (left * 250));
		end
		
		if ((self:KeyDown(IN_FORWARD) || self:KeyDown(IN_BACK)) && (self:KeyDown(IN_MOVERIGHT) || self:KeyDown(IN_MOVELEFT))) then
			local z = vel.z;
			vel = (vel * .5);
			vel.z = z;
		end*/
		
		
		if (self:KeyDown(IN_DUCK) && !self:KeyDown(IN_JUMP)) then
			
			vel.z = 5;
			
		end
		
		move:SetVelocity(vel);
		
	end
	
	return move;
	
end


if (CLIENT) then
	
	
	function DoGhostEffects()
		
		DrawColorModify{
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = (10 / 255) * 4,
			["$pp_colour_addb"] = (30 / 255) * 4,
			["$pp_colour_brightness"] = -.25,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = .32,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		};
		
	end
	
	
end
