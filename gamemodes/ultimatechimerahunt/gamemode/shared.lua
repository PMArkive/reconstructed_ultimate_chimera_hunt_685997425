
GM.Name 	= "Ultimate Chimera Hunt";
GM.Author 	= "Aska, FluxMage, Schythed, Raphy, Anomaladox and BubbleMonkey";
GM.Email 	= "";
GM.Website 	= "";
DeriveGamemode("base")

include("sh_player.lua")
include("sh_chataddtext.lua")
include("sh_roundtimer.lua")
include("sh_cache.lua");

NumPlayers = 1;

//Player variables
SprintRecharge = .0062;
SprintDrain = .015;
DJump_Penalty = .042;

TEAM_PIGS = 1;
TEAM_UC = 2;
TEAM_SPECTATE = 3;

//states
STATE_WAITING = 1;
STATE_PLAYING = 2;
STATE_INTERMISSION = 3;
STATE_VOTING = 4;


function GM:CreateTeams()
	
	team.SetUp(TEAM_PIGS, "Pigmasks", Color(225, 150, 150), true);
	team.SetSpawnPoint(TEAM_PIGS, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist", "info_player_teamspawn"});
		
	team.SetUp(TEAM_UC, "Ultimate Chimera", Color(230, 30, 110, 255), false);
	team.SetSpawnPoint(TEAM_UC, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist"});
	
	team.SetUp(TEAM_SPECTATE, "Spectators", Color(225, 225, 225), true);
	team.SetSpawnPoint(TEAM_SPECTATE, {"info_player_start", "info_player_terrorist", "info_player_counterterrorist", "info_player_teamspawn"});

end


function SetState(state)
	SetGlobalInt("GamemodeState", state);
end


function GetState()
	return GetGlobalInt("GamemodeState");
end


function Playing()
	return (GetState() == STATE_PLAYING);
end


function GM:Think()
	
	GAMEMODE.BaseClass:Think()
	
	if (SERVER) then
		SprintThink();
		ScareThink();
		UCThink();
		
		RoundTimeThink();
		
		for k, v in pairs(player.GetAll()) do
			if (v:Alive() && v:Team() == TEAM_PIGS && !v:IsTaunting()) then
				v:MakePiggyNoises();
			end
		end
		
		CheckForBrokenTimers();
		
		if (ShouldMapChange) then
			if (CurTime() >= WaitForMapChange) then
				WaitForMapChange = (CurTime() + 100);
				RunConsoleCommand("changegamemode", (NextMap || GetRandomGamemodeMap()), "ultimatechimerahunt");
			end
		end
		
		for k, ply in pairs(player.GetAll()) do
			if (ply:WaterLevel() > 0) then
				
				if (ply:IsOnGround() && ply:WaterLevel() <= 2) then
					if (ply:GetNWBool("Swimming", false)) then
						ply:SetNWBool("Swimming", false);
					end
				else
					if (!ply:GetNWBool("Swimming", false)) then
						ply:SetNWBool("Swimming", true);
					end
				end
				
			else
				
				if (ply:GetNWBool("Swimming", false)) then
					ply:SetNWBool("Swimming", false);
				end
				
			end
		end
		
	end
	
end


function GM:ShouldCollide(ent1, ent2)
	
	if (ent1:IsValid() && ent2:IsValid()) then
		if ((ent1:IsPlayer() && ent1:IsGhost()) || (ent2:IsPlayer() && ent2:IsGhost())) then
			return false;
		end
		if (ent1:IsPlayer() && ent2:IsPlayer() && ent1:Team() == ent2:Team()) then
			return false;
		end
	end
	
	return true;
	
end


function team.AlivePlayers(t)
	local num = 0;
	for k, v in pairs(team.GetPlayers(t)) do
		if (v:Alive()) then
			num = (num + 1);
		end
	end
	return num;
end


function team.NumPlayersNotBots(t)
	local num = 0;
	for k, v in pairs(team.GetPlayers(t)) do
		if (!v:IsBot()) then
			num = (num + 1);
		end
	end
	return num;
end


function GetTimeLimit()
	
	return 20 * 60; -- FORMAT: Minutes * seconds
	
end


function GetGameTimeLeft()
	
	return GetTimeLimit() - CurTime();
	
end
