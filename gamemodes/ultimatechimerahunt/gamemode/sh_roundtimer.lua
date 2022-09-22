
function RoundTimeUp()
	return (CurTime() >= GetGlobalInt("RoundTimer"));
end


if (SERVER) then
	
	
	function StartTimer()
		
		RoundTimeCheck = (CurTime() + 1);
		SetGlobalInt("RoundTimer", (CurTime() + (roundtime:GetInt() * 60)));
		
	end
	
	
	function AddTime(num)
		
		local t = GetGlobalInt("RoundTimer");
		t = (t + num);
		
		t = math.Clamp((t - CurTime()), 0, 12.5 * 60);
		t = (CurTime() + t);
		
		SetGlobalInt("RoundTimer", t);
		
		net.Start("UpdateRoundTimer")
			net.WriteFloat(num);
		net.Send(player.GetAll())
		
	end
	
	
	function RoundTimeThink()
		
		RoundTimeCheck = (RoundTimeCheck || CurTime());
		
		if (CurTime() >= RoundTimeCheck) then
			RoundTimeCheck = (CurTime() + 1);
		end
		
		if (RoundTimeUp() && Playing()) then
			RoundOver("tie");
		end
		
	end
	
	
else
	
	local sw, sh = ScrW(), ScrH();
	local timerticks = {};
	
	
	local function UpdateRoundTimer()
		local num = net.ReadFloat();
		table.insert(timerticks, {CurTime(), num});
		
		LastTimerAdd = (LastTimerAdd || 0);
		if (CurTime() >= LastTimerAdd) then
			LastTimerAdd = (CurTime() + .4);
			surface.PlaySound("uch/music/cues/timer_add.mp3");
		end
		
	end
	net.Receive("UpdateRoundTimer", UpdateRoundTimer);
	
	
	function DrawTimerTicks()
		for k, v in ipairs(timerticks) do
			
			local t, num = (v[1] + 1), v[2];
			local fade = (t - CurTime());
			
			local alpha = math.Clamp(fade, 0, 255);
			DrawNiceText("+" .. tostring(num), "UCH_TargetID_Name", ((sw * .48) - (fade * (sw * .1))), 0, Color(255, 255, 255, (alpha * 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, (alpha * 150));
			
			if (CurTime() >= t) then
				table.remove(timerticks, k);
			end
			
		end
	end
	
	
	--Normal HUD
	local pemat = surface.GetTextureID("uch/hud/timer_pigs_ensign");
	local pmat = surface.GetTextureID("uch/hud/timer_pigs");
	local pCmat = surface.GetTextureID("uch/hud/timer_pigs_colonel");
	local ucmat = surface.GetTextureID("uch/hud/timer_chimera");
	--Halloween HUD
	local hpigEmat = surface.GetTextureID("uch/hud/halloween/timer_pigs_ensign");
	local hpigCmat = surface.GetTextureID("uch/hud/halloween/timer_pigs_captain");
	local hpigMmat = surface.GetTextureID("uch/hud/halloween/timer_pigs_major");
	local hpigCOmat = surface.GetTextureID("uch/hud/halloween/timer_pigs_colonel");
	local hpigGmat = surface.GetTextureID("uch/hud/halloween/timer_ghosts");
	local hucmat = surface.GetTextureID("uch/hud/halloween/timer_chimera");
	--Christmas HUD
	local cpigEmat = surface.GetTextureID("uch/hud/christmas/timer_pigs_ensign");
	local cpigCmat = surface.GetTextureID("uch/hud/christmas/timer_pigs_captain");
	local cpigMmat = surface.GetTextureID("uch/hud/christmas/timer_pigs_major");
	local cpigCOmat = surface.GetTextureID("uch/hud/christmas/timer_pigs_colonel");
	local cucmat = surface.GetTextureID("uch/hud/christmas/timer_chimera");
	
	
	function DrawRoundTime()
		
		local state = GetState();
		
		if (state == STATE_PLAYING || state == STATE_INTERMISSION) then
			
			local t = GetGlobalInt("RoundTimer");
			local tm = math.floor(t - CurTime());
			local minute = tostring(math.floor(tm/60));
			local second = tm - minute * 60;
			if (second < 10) then second = "0" .. second end -- Couldn't use string.FormattedTime, not working :C
			tm = minute .. ":" .. second;
			
			if (RoundTimeUp() || !Playing()) then
				tm = "Time up!";
			end
			
			tm = string.Trim(tm);
			
			surface.SetFont("UCH_TargetID_Name");
			local txtw, txth = surface.GetTextSize("Time up!");
			
			local x, y = (sw * .5), -(sh * .05);
			local h = (txth + -y);
			local w = (h * 2);
			
			local mat = pmat;
			
			local ply = LocalPlayer();
			local target = ply:GetObserverTarget();
			local rank;
			local r, g, b;
			if (IsValid(target)) then
				rank = target:GetRank();
				r, g, b = target:GetRankColorSat();
			else
				rank = ply:GetRank();
				r, g, b = ply:GetRankColorSat();
			end
			
			local season = GetGlobalInt("SeasonalHUD");
			
			--Timer Seasonal Switch
			if (season == 1) then
				r, g, b = 255, 255, 255;
				if (rank == "Ensign") then
					mat = hpigEmat;
				elseif (rank == "Captain") then
					mat = hpigCmat;
				elseif (rank == "Major") then
					mat = hpigMmat;
				elseif (rank == "Colonel") then
					mat = hpigCOmat;
				end
				
				if (ply:IsUC() || (IsValid(target) && target:IsUC())) then
					mat = hucmat;
				end
				
				if (ply:IsGhost() && !IsValid(target)) then
					mat = hpigGmat;
					r, g, b = 220, 220, 220;
				end
			elseif (season == 2) then
				if (rank == "Ensign") then
					mat = cpigEmat;
				elseif (rank == "Captain") then
					mat = cpigCmat;
				elseif (rank == "Major") then
					mat = cpigMmat;
				elseif (rank == "Colonel") then
					mat = cpigCOmat;
				end
				
				if (ply:IsUC() || (IsValid(target) && target:IsUC())) then
					mat = cucmat;
					r, g, b = 255, 255, 255;
				end
				
				if (ply:IsGhost() && !IsValid(target)) then
					mat = cpigCOmat;
				end
			else
				if (rank == "Colonel") then
					mat = pCmat;
				end
				if (rank == "Ensign") then
					mat = pemat;
					r, g, b = 255, 255, 255;
				end
				if (ply:IsUC() || (IsValid(target) && target:IsUC())) then
					mat = ucmat;
					r, g, b = 255, 255, 255;
				end
				if (ply:IsGhost() && !IsValid(target)) then
					mat = pmat;
					r, g, b = 255, 255, 255;
				end
			end
			
			surface.SetTexture(mat);
			surface.SetDrawColor(Color(r, g, b, 255));
			surface.DrawTexturedRect((x - (w * .5)), 0, w, h);
			
			DrawNiceText(tm, "UCH_TargetID_Name", (sw * .5), 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 250);
			
			if (#timerticks > 0) then
				DrawTimerTicks();
			end
			
		end
		
	end
	
	
end
