
local meta = FindMetaTable("Player");


function meta:SetSprint(num)
	self:SetDTFloat(2, num);
end


function meta:SetSprinting(bool)
	self:SetDTBool(3, bool);
end


function meta:GetSprint()
	return self:GetDTFloat(2);
end


function meta:GetSprinting()
	return (self:GetDTBool(3));
end


function meta:SetSprintingNW(bool)
	self:SetSprinting(bool);
	if (SERVER) then
		self:SetDTBool(1, bool);
	end
end


function meta:GetSprintingNW()
	return (self:GetDTBool(1));
end


local sprint_minimum = .2;


function meta:CanRechargeSprint()
	
	self.SprintCooldown = (self.SprintCooldown || 0);
	local cooldown = self.SprintCooldown;
	return ((!self:IsUC() && CurTime() >= cooldown) || (self:IsUC() && self:IsOnGround()) && !self:KeyDown(IN_SPEED));
	
end


function meta:CanSprint()
	
	if (self:GetSprint() > 0) then
		if (self:IsUC()) then
			return true;
		end
		if (self:IsTaunting() || self:IsRoaring() || self:IsBiting()) then
			return false;
		end
		if (self:IsScared() || (!self:IsUC() && (!self:IsOnGround() || self:GetSprinting()))) then
			return false;
		end
		if (self:Team() == TEAM_PIGS && !self:GetSprintingNW()) then
			return true;
		end
		if (self:IsOnGround()) then
			return true;
		end
		return false;
	end
	
	return false;
	
end


function SprintKeyPress(ply, key) //pigs sprint
	
	if (key != IN_SPEED || ply:GetSprint() < sprint_minimum) then
		return;
	end
	
	if (ply:CanSprint()) then
		ply:SetSprinting(true);
	end
	
end


if (SERVER) then
	
	nextthink = 0;
	
	
	function SprintThink()
		
		if (CurTime() >= nextthink) then
			nextthink = (CurTime() + .05);
			for k, v in pairs(player.GetAll()) do
				
				if (!v:Alive()) then
					v:SetSprinting(false);
				else
					
					v:SetSprint((v:GetSprint() || 1));
					v:SetSprinting((v:GetSprinting() || false));
					v.SprintCooldown = (v.SprintCooldown || 0);
					
					if (v:IsUC()) then
						
						local bool = (v:KeyDown(IN_SPEED) && v:MovementKeyDown() && v:CanSprint());
						v:SetSprinting(bool);
						if (v:GetSprintingNW() != bool) then
							v:SetSprintingNW(bool);
						end
						
					end
					
					if (v:IsScared()) then
						v:UpdateSpeeds();
					else
						
						if (v:GetSprinting()) then //I'm running, I'M RUNNING
							
							if (!v:GetSprintingNW()) then
								v:SetSprintingNW(true);
							end
							
							local drain = SprintDrain;
							
							if (v:IsUC()) then
								drain = (drain - .004);
							else
								local rank = v:GetRankNum();
								drain = (drain - (.005 * (rank / 4)));
							end
							
							v:SetSprint((v:GetSprint() - drain));
							
							v:UpdateSpeeds();
							
							if (v:GetSprint() <= 0) then //you're all out man!
								v:SetSprinting(false);
								
								if (CurTime() > v.SprintCooldown) then
									v.SprintCooldown = (CurTime() + 6);
								end
								
								v:ResetSpeeds();
								
							end
							
						else
							
							if (v:GetSprintingNW()) then
								v:SetSprintingNW(false);
							end
							
							if (v:GetSprint() < 1 && v:CanRechargeSprint()) then
								
								local recharge = SprintRecharge;
								
								if (v:IsUC()) then
									recharge = (recharge + .001);
								else
									local rank = v:GetRankNum();
									local num = .00075;
									
									if (v:Crouching()) then
										num = .02;
									end
									
									recharge = (recharge + (num * (rank / 4)));
								end
								
								v:SetSprint(math.Clamp((v:GetSprint() + recharge), 0, 1));
							end
							
							v:UpdateSpeeds();
							
						end
						
					end
					
				end
				
			end
		end
		
	end
	
	
else
	
	--Christmas HUD Underlay
	local csprintedbar = surface.GetTextureID("uch/hud/christmas/underlay_pigs");
	local cucsprintedbar = surface.GetTextureID("uch/hud/christmas/underlay_chimera");
	
	local sw, sh = ScrW(), ScrH();
	
	
	function DrawSprintedBar(x, y, w, h)
		
		local ply = LocalPlayer();
		
		local mat = csprintedbar;
		
		local r, g, b, a;
		
		if (ply:IsUC()) then
			
			local h = (sh * .285);
			local w = (h * 2);
			
			local x, y = (sw * -.0385), (sh * .732);
			
			local spdx, spdy = (x + (w * .285)), (y + (h * .58));
			local spdw, spdh = (w * .505), (h * .145);
			
			mat = cucsprintedbar;
			r, g, b, a = 255, 255, 255, 235;
			
			surface.SetTexture(mat);
			surface.SetDrawColor(Color(r, g, b, a));
			surface.DrawTexturedRect(x, y, w, h);
			
		else
			
			local h = (sh * .14);
			local w = (h * 4);
			
			local x, y = (sw * -.035), (sh * .85);
			
			local spdx, spdy = (x + (w * .286)), (y + (h * .35));
			local spdw, spdh = (w * .51), (h * .275);
			
			mat = csprintedbar;
			a = 220;
			r, g, b = ply:GetRankColor();
			
			surface.SetTexture(mat);
			surface.SetDrawColor(Color(r, g, b, a));
			surface.DrawTexturedRect(x, y, w, h);
			
		end
		
	end
	
	
	local sprintbar = surface.GetTextureID("uch/hud/sprintbar_pigs");
	local ucsprintbar = surface.GetTextureID("uch/hud/sprintbar_chimera");
	
	local sw, sh = ScrW(), ScrH();
	
	
	function DrawSprintBar(x, y, w, h)
		
		local ply = LocalPlayer();
		
		if ((!ply:GetSprint() && !ply:IsScared()) || ply:IsGhost()) then
			return;
		end
		
		local mat = sprintbar;
		local r, g, b = ply:GetRankColor();
		local season = GetGlobalInt("SeasonalHUD");
		
		if (ply:IsUC()) then
			--Seasonal Chimera Sprintbar Color Switch
			if (season == 1) then
				mat = sprintbar;
				r, g, b = 255, 122, 0;
			else
				mat = ucsprintbar;
				r, g, b = 255, 255, 255;
			end
		end
		
		local a = ply.SprintBarAlpha;
		
		ply.SprintMeterSmooth = (ply.SprintMeterSmooth || ply:GetSprint());
		
		local diff = math.abs((ply.SprintMeterSmooth - ply:GetSprint()));
		
		ply.SprintMeterSmooth = math.Approach(ply.SprintMeterSmooth, ply:GetSprint(), (FrameTime() * (diff * 5)));
		
		--Seasonal Switch for Sprint Bar Backdrop
		if (season == 1) then
			draw.RoundedBox(0, x, y, w, h, Color(30, 30, 30, 200));
		elseif (season == 2) then
			DrawSprintedBar(spdx, spdy, spdw, spdh);
		else
			draw.RoundedBox(0, x, y, w, h, Color(130, 130, 130, a));
		end
		
		if (!ply:IsUC()) then
			--Seasonal Switch for the Sprint Minimum Texture.
			if (season == 0) then
				draw.RoundedBox(0, x, y, (w * sprint_minimum), h, Color(100, 100, 100, a));
			elseif (season == 1) then
				draw.RoundedBox(0, x, y, (w * sprint_minimum), h, Color(80, 80, 80, 100));
			end
			
		end
		
		surface.SetTexture(mat);
		surface.SetDrawColor(Color(r, g, b, a));
		surface.DrawTexturedRect(x, (y + 1), (w * ply.SprintMeterSmooth), h);
		
		if (ply.SprintMeterSmooth <= .02 || ply:IsScared()) then
			--Red Blinking Removed for Christmas HUD.
			if (season == 1) then
				local alpha = (100 + (math.sin((CurTime() * 5)) * 45));
				draw.RoundedBox(0, x, y, w, h, Color(250, 40, 233, alpha));
			elseif (season == 2) then
				return;
			else
				local alpha = (100 + (math.sin((CurTime() * 5)) * 45));
				draw.RoundedBox(0, x, y, w, h, Color(250, 0, 0, alpha));
			end
		end
		
	end
	
	
end
