
function AnimatePig(ply, velocity)
	
	local len2d = velocity:Length2D();
	
	if (ply:OnGround()) then
		
		if (len2d > 0) then
			
			if (ply:GetSprintingNW()) then
				ply.CalcSeqOverride = "run";
			else
				ply.CalcSeqOverride = "walk";				
			end
			
			if (ply:IsScared()) then
				ply.CalcSeqOverride = "run_scared";
			end
			
			if (ply:Crouching()) then
				ply.CalcSeqOverride = "crawl";
			end
			
		else
			
			if (ply:IsScared()) then
				ply.CalcSeqOverride = "idle_scared";
			end
			if (ply:Crouching()) then
				ply.CalcSeqOverride = "crouchidle";
			end
			
		end
		
	else
		
		ply.CalcSeqOverride = "jump";
		
	end
	
	if (ply:IsTaunting()) then
		
		local t = "taunt";
		
		if (ply:GetRankNum() == 4) then
			t = "taunt2";
		end
		
		ply.CalcSeqOverride = t;
		
	end
	
	if (ply:GetNWBool("Swimming")) then
		
		local vel = ply:GetVelocity();
		vel.z = 0;
		
		if (vel:Length() > 5) then
			
			ply.CalcSeqOverride = "swim";
			
		else
			
			ply.CalcSeqOverride = "swimidle";
			
		end
		
	end
	
	if (ply.SwitchLight != false && ply.SwitchLight != true) then
		ply.SwitchLight = false;
	end
	
	if (ply.SwitchLight) then
		ply.SwitchLight = false;
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_MELEE_ATTACK1, true);
	end
	
end


local function SwitchLight()
	local ply = net.ReadEntity();
	ply.SwitchLight = true;
end
net.Receive("SwitchLight", SwitchLight);


function AnimateUC(ply, velocity)
	
	ply:PlaybackReset();
	
	local len2d = velocity:Length2D();
	
	if (ply:OnGround()) then
		
		if (len2d > 0) then
			
			if (ply:GetSprintingNW()) then		
				ply.CalcSeqOverride = "run";
			else
				ply.CalcSeqOverride = "walk";
			end
			
		end
		
	else
		
		if (ply:CanDoubleJump() && ply:GetNWInt("DJumpNum") < 1) then
			ply.CalcSeqOverride = "jump2";
		else
			ply.CalcSeqOverride = "jump3";
		end
		
	end
	
	/*if (ply:WaterLevel() > 0) then
		
		if (!ply:IsOnGround() || ply:WaterLevel() > 2) then
			local vel = ply:GetVelocity();
			vel.z = 0;
			
			if (vel:Length() > 5) then
			
				ply.CalcSeqOverride = "swim";
				
			else
				
				ply.CalcSeqOverride = "swimidle";
				
			end
		end
		
	end*/
	
	if (ply:IsBiting()) then
		ply.CalcSeqOverride = "bite";
	end
	if (ply:IsRoaring()) then
		ply.CalcSeqOverride = "idle3";
	end
	
	if (ply.TailSwipe) then
		ply.TailSwipe = false;
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_MELEE_ATTACK1, true);
	end
	
end


local function TailSwipe()
	local ply = net.ReadEntity();
	ply.TailSwipe = true;
end
net.Receive("TailSwipe", TailSwipe);


function AnimateGhost(ply, velocity)
	
	local len2d = velocity:Length2D();
	
	local seq = "idle1";
	local cup = (ply:GetBodygroup(1) == 1);
	
	if (len2d > 0) then
		
		if (cup) then
			seq = "walk2";
		else
			seq = "walk";
		end
		
	else
		
		if (cup) then
			seq = "idle2";
		end
		
	end
	
	ply.LastSippyCup = (ply.LastSippyCup || 0);
	ply.LastOogly = (ply.LastOogly || 0);
	
	if (cup && CurTime() >= ply.LastSippyCup) then
		ply.LastSippyCup = (CurTime() + math.Rand(20, 40));
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_MELEE_ATTACK1, true);
	end
	
	if (CurTime() >= ply.LastOogly) then
		ply.LastOogly = (CurTime() + math.Rand(10, 20));
		ply:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_GESTURE_RANGE_ATTACK2, true);
	end
	
	if (CLIENT) then
		
		if (ply.PiggyWiggle) then
			ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_GESTURE_RANGE_ATTACK1);
		else
			ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_GESTURE_MELEE_ATTACK2);
		end
		
	end
	
	ply.CalcSeqOverride = seq;
	
end
