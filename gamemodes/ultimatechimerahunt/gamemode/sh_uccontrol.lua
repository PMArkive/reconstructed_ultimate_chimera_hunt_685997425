
local roardistance = 450;
local roarcooldown = 12;

local meta = FindMetaTable("Player");


function meta:CanDoAction()
	
	self.LastAction = (self.LastAction || 0);
	return (self:Alive() && !self:IsBiting() && !self:IsRoaring() && CurTime() >= self.LastAction);
	
end


local function playerGetAllMinus(ent)
	local tbl = {};
	for k, v in pairs(player.GetAll()) do
		if (v != ent) then
			table.insert(tbl, v);
		end
	end
	return tbl;
end


function meta:FindThingsToBite()
	
	local tbl = {};
	
	local pos = self:GetShootPos();
	local fwd = self:GetForward();
	fwd.z = 0;
	fwd:Normalize();
	local vec = ((pos + Vector(0, 0, -16)) + (fwd * 60));
	local rad = 43;
	
	debugoverlay.Sphere(vec, rad);
	for k, v in pairs(ents.FindInSphere(vec, rad)) do
		
		if (!v:IsPlayer() || (v:Alive() && v:Team() == TEAM_PIGS)) then
			
			local pos = self:GetShootPos();
			local epos = (v:IsPlayer() && v:GetShootPos()) || v:GetPos();
			local tr = util.QuickTrace(pos, ((epos - pos) * 10000), playerGetAllMinus(v));
			debugoverlay.Line(pos, tr.HitPos, 3, Color(255, 0, 0))
			if (tr.Entity:IsValid() && tr.Entity == v) then
				table.insert(tbl, v);
			end
			
		end
		
		if (v:GetClass() == "func_breakable" || v:GetClass() == "func_breakable_surf") then
			table.insert(tbl, v);
		end
		
	end
	
	return tbl;
	
end


function meta:IsBiting()
	return (self:GetNWBool("IsBiting"));
end


function meta:IsRoaring()
	return (self:GetNWBool("IsRoaring"));
end


function meta:NightVisionIsOn()
	return (self:GetNWBool("NightVision"));
end


function meta:GetStock()
	return self:GetNWInt("RoarStock");
end


function meta:WithinRoarDistance(uc)
	local pos, ucpos = self:GetShootPos(), uc:GetShootPos();
	local dis = pos:Distance(ucpos);
	local tr = util.QuickTrace(ucpos, ((pos - ucpos) * 10000), playerGetAllMinus(self));
	if (dis <= roardistance) then
		if (tr.Entity:IsValid() && tr.Entity == self) then
			return true, dis;
		else
			return false, 0;
		end
	end
	return false, 0;
end


function meta:CreateBirdProp()
	local bird = ents.Create("prop_physics");
	bird:SetModel("models/uch/birdgib.mdl");
	
	local pos = self:GetPos();
	local fwd = self:GetForward();
	pos = ((pos + Vector(0, 0, 12)) + (fwd * 25));
	
	bird:SetPos(pos);
	
	bird:SetAngles(self:GetAngles());
	bird:Spawn();
	bird:SetCollisionGroup(COLLISION_GROUP_DEBRIS);
	GAMEMODE.BirdProp = bird;
end


function UCKeyPress(ply, key)
	
	if (ply:IsOnGround()) then
	
		if (key == IN_ATTACK) then  //bite
			ply:Bite();
		end
		
		if (key == IN_ATTACK2) then  //roar
			ply:Roar();
		end
		
	end
	
	if (key == IN_JUMP) then
		if (ply:IsOnGround()) then
			if (ply:CanSprint()) then
				local num = (ply:GetSprinting() && .075) || .025;
				local clamp = math.Clamp((ply:GetSprint() - num), 0, 1);
				ply:SetSprint(clamp);
			end
		else
			if (ply:CanDoubleJump() && ply:GetNWInt("DJumpNum") < 1) then
				ply:DoubleJump();
			end
		end
	end
	
	if (key == IN_RELOAD) then
		if (ply:CanDoTailSwipe()) then
			ply:DoTailSwipe();
		end
	end
end


LastUCThink = 0;
function UCThink()
	
	local uc = GetUC();
	
	if (!uc:IsValid()) then
		return;
	end
	
	if (uc:IsRoaring() && CurTime() >= LastUCThink) then
		LastUCThink = (CurTime() + .1);
		for k, v in pairs(player.GetAll()) do
			
			local b, dis = v:WithinRoarDistance(uc);
			if (b && v:Alive() && v:Team() == TEAM_PIGS) then
				
				if (!v:IsScared()) then
				
					local t = (3.2 * ((1 - (dis / roardistance)) * 1.8));
					
					v:Scare(t);
					
					uc:SetSprint((uc:GetSprint() + .05));
				
				end
				
			end
			
		end
	end
	
	uc.PlayStomp = (uc.PlayStomp || true);
	if (!uc:IsOnGround()) then
		if (!uc.PlayStomp) then
			uc.PlayStomp = true;
		end
		if (uc:CanDoubleJump() && uc:KeyDown(IN_JUMP) && uc:GetNWInt("DJumpNum") > 0) then
			uc:DoubleJump();
		end
	else
		uc.LastStomp = (uc.LastStomp || 0);
		uc.LastPos = uc.LastPos || uc:GetPos()
		if (uc.PlayStomp && CurTime() >= uc.LastStomp) then
			if (uc:MovementKeyDown() && uc:Alive() && !uc.LastPos:IsEqualTol(uc:GetPos(), 60)) then
				uc.LastPos = uc:GetPos()
				uc.LastStomp = (CurTime() + .5);
				uc.PlayStomp = false;
				uc:EmitSound("uch/chimera/step.mp3", 82, math.random(94, 105));
				net.Start("DoStompEffect")
					net.WriteVector(uc:GetPos());
				net.Send(player.GetAll())
			end
		end
		
		if (uc:GetNWBool("FirstTimeJump", true) != true) then
			uc:SetNWBool("FirstTimeJump", true);
		end
		if (uc:GetNWInt("DJumpNum") != 0) then
			uc:SetNWInt("DJumpNum", 0);
		end
		
	end
	
	if (uc.Swiping) then
		
		if (CurTime() >= uc.SwipeTime) then
			uc.Swiping = false;
		end
		uc:DoPigSwipe();
		
	else
		if (uc:GetSwipeMeter() != 1) then
			uc:SetSwipeMeter((uc:GetSwipeMeter() + .00375));
		end
	end
	
	local pig = uc:GetGroundEntity();
	if (pig:IsValid()) then
		if (pig:IsPlayer() && pig:Alive() && pig:Team() == TEAM_PIGS) then
			
			local vel = uc.StompVel;
			if (vel.z < -500) then
				pig:Pancake();
			end
			
		end
	else
		uc.StompVel = uc:GetVelocity();
	end
	
end


function meta:CanDoubleJump()
	
	local add = 36; //how much to increase the required z velocity per jump
	local numjumps = 1; //how many jumps you're allowed before increasing the required z velocity
	
	local num = -((150 - (add * numjumps)) + (add * (self:GetNWInt("DJumpNum"))));
	return (!self:IsOnGround() && (self:GetVelocity().z < num) || self:GetNWBool("FirstTimeJump", true));
	
end


function meta:DoubleJump()
	local vel = self:GetVelocity();
	if (self:GetSprint() <= .025) then
		vel.x = (vel.x * .5);
		vel.y = (vel.y * .5);
	end
	vel.z = (275);
	self:SetGroundEntity(nil);
	self:SetLocalVelocity(vel);
	
	self:SetSprint((self:GetSprint() - (DJump_Penalty * (1 + (self:GetNWInt("DJumpNum") * .66)))));
	
	self:SetNWBool("FirstTimeJump", false);
	self:EmitSound("uch/chimera/doublejump.mp3", 75, (100 - (self:GetNWInt("DJumpNum") * 2.5)));
	self:SetNWInt("DJumpNum", (self:GetNWInt("DJumpNum") + 1));
	
	RestartAnimation(self);
end


local swipedelay = .5;


function meta:SetSwipeMeter(num)
	num = math.Clamp(num, 0, 1);
	self:SetDTFloat(3, num);
end


function meta:GetSwipeMeter()
	return self:GetDTFloat(3);
end


function meta:CanDoTailSwipe()
	
	return (self:Alive() && CurTime() >= ((self.SwipeTime || 0) + .15) && self:GetSwipeMeter() >= .25);
	
end


function meta:FindSwipablePigs()
	
	local tbl = {};
	
	local pos = self:GetShootPos();
	local fwd = self:GetForward();
	fwd.z = 0;
	fwd:Normalize();
	local vec = (pos + ((fwd * -1) * 78));
	local rad = 80;
	
	debugoverlay.Sphere(vec, rad);
	for k, v in pairs(ents.FindInSphere(vec, rad)) do
		
		if (v:IsPlayer() && v:Alive() && v:Team() == TEAM_PIGS) then
			
			local pos = self:GetShootPos();
			local epos = (v:IsPlayer() && v:GetShootPos()) || v:GetPos();
			local tr = util.QuickTrace(pos, ((epos - pos) * 10000), playerGetAllMinus(v));
			debugoverlay.Line(pos, tr.HitPos, 3, Color(255, 0, 0))
			if (tr.Entity:IsValid() && tr.Entity == v) then
				table.insert(tbl, v);
			end
			
		end
		
	end
	
	return tbl;
	
end


function meta:DoTailSwipe()
	
	net.Start("TailSwipe")
		net.WriteEntity(self);
	net.Send(player.GetAll())
	self:EmitSound("uch/chimera/tailswipe.mp3", 75, math.random(90, 105));
	
	self.SwipePower = self:GetSwipeMeter();
	self:SetSwipeMeter(0);
	
	self.Swiping = true;
	self.SwipeTime = (CurTime() + swipedelay);
	
end


function meta:DoPigSwipe()
	
	if (!self.Swiping) then
		return;
	end
	
	local pigs = self:FindSwipablePigs();
	if (#pigs >= 1) then
		for k, v in pairs(pigs) do
			
			if (v.CanBeSwiped != true && v.CanBeSwiped != false) then
				v.CanBeSwiped = true;
			end
			
			if (v:GetMoveType() == MOVETYPE_LADDER) then
				v:SetJumpPower(2000);
				v:ConCommand("+jump");
				timer.Simple(.1, function()
					if (v:IsValid()) then
						v:ConCommand("-jump");
						v:SetJumpPower(242);
					end
				end)
			end
			
			if (!v:GetNWBool("Swiped") && v.CanBeSwiped) then
				
				v:SetNWBool("Swiped", true);
				v.CanBeSwiped = false;
				v:UpdateSpeeds();
				
				v:StopTaunting();
				
				local pos = self:GetPos();
				local epos = v:GetPos();
				pos.z = 0;
				epos.z = 0;
				local dir = (epos - pos):GetNormal();
				v:SetGroundEntity(nil);
				
				local vel = ((dir * 300) + Vector(0, 0, 340));
				local num = math.Clamp((self.SwipePower * 1.32), 0, 1);
				vel = (vel * num);
				vel.x = math.Clamp(vel.x, -340, 340);
				vel.y = math.Clamp(vel.y, -340, 340);
				vel.z = math.Clamp(vel.z, 0, 340);
				v:SetLocalVelocity(vel);
				
				timer.Simple(self.SwipePower, function()
					v:SetNWBool("Swiped", false);
				end);
				
				timer.Simple(1, function()
					v.CanBeSwiped = true;
				end);
				
			end
			
		end
	end
	
end


if (SERVER) then
	
	
	function meta:ResetUCVars()
		self:SetNWBool("IsBiting", false);
		self:SetNWBool("IsRoaring", false);
		self:NightVisionOff();
		self:ResetStock();
	end
	
	
	function meta:Roar()
		
		self.LastRoar = (self.LastRoar || 0);
		
		if (!self:CanDoAction() || CurTime() < self.LastRoar) then
			return;
		end
		
		if (self:GetStock() <= 0) then
			
			self:ChatPrint("You're not angry enough to roar!");
			
		else
			
			self:LoseStock();
			
			self.LastRoar = (CurTime() + roarcooldown);
			
			self:SetNWBool("IsRoaring", true);
			
			local seq = self:LookupSequence("idle3");
			self:ResetSequence(seq);
			
			local dur = self:SequenceDuration();
			
			RestartAnimation(self);
			
			self:EmitSound("uch/chimera/roar.mp3", 82, math.random(94, 105));
			util.ScreenShake(self:GetPos(), 5, 5, (dur * .96), (roardistance * 1.85));
			
			timer.Simple((dur * .96), function()
				if (self:IsValid()) then
					self:SetNWBool("IsRoaring", false);
					
					net.Start("UCRoared") //let the clientside meter know
						net.WriteFloat(self.LastRoar);
						net.WriteFloat(CurTime());
					net.Send(self)
				end
			end);
			
			self.LastAction = (CurTime() + (dur * 1.05));
			
		end
		
	end
	
	
	function meta:ResetStock()
		self:SetNWInt( "RoarStock", 2 );
	end
	
	
	function meta:GainStock()
		local stock = self:GetStock();
		self:SetNWInt( "RoarStock", stock + 1 );
	end
	
	
	function meta:LoseStock()
		local stock = self:GetStock();
		self:SetNWInt( "RoarStock", stock - 1 );
	end
	
	
	function meta:Bite()
		
		if (!self:CanDoAction()) then
			return;
		end
		
		self:SetNWBool("IsBiting", true);
		
		local seq = self:LookupSequence("bite");
		self:ResetSequence(seq);
		
		local dur = self:SequenceDuration();
		
		RestartAnimation(self);
		
		self:EmitSound("uch/chimera/bite.mp3", 80, math.random(94, 105));
		
		timer.Simple((dur * .98), function()
			self:SetNWBool("IsBiting", false);
		end);
		
		local tbl = self:FindThingsToBite();
		
		if (#tbl >= 1) then
			for k, v in pairs(tbl) do
				
				if (v:IsPlayer()) then
					v:Freeze(true);
					if (self:GetStock() < 2) then
						self:GainStock();
					end
				end
				
				timer.Simple(.32, function()
					if (self:IsValid() && v:IsValid()) then
						self:DoBiteThing(v);
					end
				end);
				
			end
		end
		
		self.LastAction = (CurTime() + (dur * 1.05));
		
	end
	
	
	function meta:DoBiteThing(v)
		
		if (v:IsPlayer() && !v:Alive()) then
			return;
		end
		
		if (!self:Alive() || !self:IsUC()) then
			if (v:IsPlayer()) then
				v:Freeze(false);
			end
			return;
		end
		
		if (v:IsPlayer()) then
			
			v.Bit = true;
			v:Kill();
			
			net.Start("UCMakeRagFly")
				net.WriteEntity(v);
			net.Send(player.GetAll())
			
			v:ResetRank();
			
		else
			
			local fwd = (v:GetPos() - self:GetPos());
			fwd.z = 0;
			fwd:Normalize();
			
			local phys = v:GetPhysicsObject();
			if (phys:IsValid()) then
				local dir = (fwd * 35000);
				phys:ApplyForceCenter((dir + Vector(0, 0, 16000)));
			end
			
			v:TakeDamage(1);
			if (v:Health() > 0) then
				v:Fire("break");
			end
			
		end
		
	end
	
	
	function meta:CanPressButton()
		
		local uc = GetUC();
		
		if (!uc:IsValid() || !uc:Alive() || self:IsScared() || self:IsGhost() || self:GetNWBool("Swiped")) then
			return false;
		end
		
		local pos = uc:GetShootPos();
		
		local fwd = uc:GetForward();
		fwd.z = 0;
		fwd:Normalize();
		
		pos = (pos + (fwd * -6));
		
		local target = self:GetEyeTrace().Entity;
		
		local dis = self:GetShootPos():Distance(pos);
		local tblbool = table.HasValue(uc:FindEnts(player.GetAll(), .42, -1), self);
		
		return (target == uc && ((dis <= 80 && !tblbool) || self:GetGroundEntity() == uc));
		
	end
	
	
	function meta:FindEnts(tbl, dis, num)
		
		local pos = self:GetPos()
		local forward = (self:GetForward() * num)
		
		local entitiesInFront = {}
		for i, e in ipairs(tbl) do
		//player.GetByID(1):ChatPrint(tostring(forward:Dot((pos - e:GetPos()):GetNormalized())));
			if (e != self and forward:Dot((e:GetPos() - pos):GetNormalized()) <= dis) then
				table.insert(entitiesInFront, e)
			end
		end
		return entitiesInFront;
		
	end
	
	
	function meta:ToggleNightVision()
		local sound;
		if (!self:NightVisionIsOn()) then
			self:SetNWBool("NightVision", true);
			sound = "on";
		else
			self:SetNWBool("NightVision", false);
			sound = "off";
		end
		for k, v in pairs(player.GetAll()) do
			local target = v:GetObserverTarget();
			if (self == v || self == target) then
				v:SendLua("surface.PlaySound(\"uch/chimera/nightvision_" .. sound .. ".mp3\")");
			end
		end
	end
	
	
	function meta:NightVisionOff()
		self:SetNWBool("NightVision", false);
	end
	
	
else
	
	
	local function UCRoared()
		
		local ply = LocalPlayer();
		ply.DrawRoar = true;
		
		local t1, t2 = net.ReadFloat(), net.ReadFloat();
		
		local t = CurTime();
		ply.RoarCalc = t1;
		ply.RoarT = t2;
		
		timer.Simple(((t1 - CurTime()) * .95), function()
			if (ply:IsUC()) then
				surface.PlaySound("uch/player/recharged.mp3");
			end
		end);
		
		ply.RoarMeterSmooth = 0;
		
	end
	net.Receive("UCRoared", UCRoared);
	
	
	local function DoStompEffect()
		
		local ply = LocalPlayer();
		
		if (ply:Alive() && ply:Team() == TEAM_PIGS) then
			util.ScreenShake(net.ReadVector(), 3, 3, .5, 1);
		end
		
	end
	net.Receive("DoStompEffect", DoStompEffect);
	
	
	local sw, sh = ScrW(), ScrH();
	
	local roarbar = surface.GetTextureID("uch/hud/sprintbar_chimera");
	
	
	function DrawRoarMeter(x, y, w, h)
		
		local ply = LocalPlayer();
		
		ply.RoarMeterSmooth = (ply.RoarMeterSmooth || 0);
		ply.RoarCalc = (ply.RoarCalc || 0);
		ply.RoarT = (ply.RoarT || 0);
		
		local mat = roarbar;
		
		local t = (CurTime() - ply.RoarT);
		local calc = math.Clamp((t / (ply.RoarCalc - ply.RoarT)), 0, 1);
		
		ply.RoarMeterSmooth = math.Approach(ply.RoarMeterSmooth, calc, (FrameTime() * 750));
		
		local season = GetGlobalInt("SeasonalHUD");
		
		--Roar Meter Bar Halloween BackDrop Recolor
		if (season == 0) then
			draw.RoundedBox(0, x, y, w, h, Color(130, 130, 130, 255));
		elseif (season == 1) then
			draw.RoundedBox(0, x, y, w, h, Color(30, 30, 30, 200));
		end
				
		surface.SetTexture(mat);
		--Roar Meter Bar Halloween Recolor
		if (season == 1) then
			surface.SetDrawColor(Color(100, 100, 100, 255));
		else
			surface.SetDrawColor(Color(200, 200, 200, 255));
		end
		surface.DrawTexturedRect(x, y, (w * ply.RoarMeterSmooth), h);
		
	end
	
	
	local swipebar = surface.GetTextureID("uch/hud/sprintbar_pigs");
	
	
	function DrawSwipeMeter(x, y, w, h)
		
		local ply = LocalPlayer();
		
		ply.SwipeMeterSmooth = (ply.SwipeMeterSmooth || 1);
		
		local mat = swipebar;
		
		local a = ply.SwipeMeterAlpha;
		local diff = math.abs((ply.SwipeMeterSmooth - ply:GetSwipeMeter()));
		
		ply.SwipeMeterSmooth = math.Approach(ply.SwipeMeterSmooth, ply:GetSwipeMeter(), (FrameTime() * (diff * 5)));
		
		local season = GetGlobalInt("SeasonalHUD");
		
		--Swipe Meter Bar Halloween BackDrop Recolor
		if (season == 0) then
			draw.RoundedBox(0, x, y, w, h, Color(130, 130, 130, 255));
			draw.RoundedBox(0, x, y, (w * .25), h, Color(100, 100, 100, 255));
		elseif (season == 1) then
			draw.RoundedBox(0, x, y, w, h, Color(30, 30, 30, 200));
		end
		
		surface.SetTexture(mat);
		surface.SetDrawColor(Color(250, 120, 5, 255));
		surface.DrawTexturedRect(x, y, (w * ply.SwipeMeterSmooth), h);
		
	end
	
	
	function DoNightVision(uc)
		
		local dlight = DynamicLight(uc:EntIndex());
			dlight.Pos = uc:GetPos();
			dlight.r = 255;
			dlight.g = 255;
			dlight.b = 0;
			dlight.Brightness = -4;
			dlight.Decay = 2048;
			dlight.Size = 2048;
			dlight.DieTime = CurTime() + 1;
		
		DrawColorModify{
			["$pp_colour_addr"] = (30 / 255) * 4,
			["$pp_colour_addg"] = (30 / 255) * 4,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = -.25,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = .32,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		};
		
	end
	
	
end
