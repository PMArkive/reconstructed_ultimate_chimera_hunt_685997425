
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_hud.lua");
AddCSLuaFile("cl_help.lua");
AddCSLuaFile("cl_scoreboard.lua");
AddCSLuaFile("cl_selectscreen.lua");
AddCSLuaFile("cl_splashscreen.lua");
AddCSLuaFile("sh_chataddtext.lua");
AddCSLuaFile("cl_voice.lua");
AddCSLuaFile("sh_ghost.lua");
AddCSLuaFile("sh_cache.lua");
AddCSLuaFile("cl_killnotices.lua");
AddCSLuaFile("cl_targetid.lua");
AddCSLuaFile(GM.Folder .. "/entities/entities/chimera_spawn/init.lua");

AddCSLuaFile("vgui_vote.lua")

for k, v in pairs(file.Find(GM.Folder .. "/gamemode/scoreboard/*.lua", "GAME")) do
	AddCSLuaFile("scoreboard/" .. v);
end

AddCSLuaFile("sh_ply_extensions.lua");
AddCSLuaFile("sh_player.lua");
AddCSLuaFile("sh_roundtimer.lua");

include("shared.lua")
include("sv_mapcontrol.lua")

waittime = CreateConVar( "uch_waittime", "60", { FCVAR_ARCHIVE }, "Time before the first round starts" )
roundtime = CreateConVar( "uch_roundtime", "3", { FCVAR_ARCHIVE }, "The number of minutes each round lasts" )
musicmode = CreateConVar( "uch_musicmode", "0", { FCVAR_ARCHIVE }, "Use Mother music on every map [1 = Enabled 0 = Disabled]" )
tf2maps = CreateConVar( "uch_tf2maps", "0", { FCVAR_ARCHIVE }, "Allow certain TF2 maps to be mounted by the gamemode (TF2 must be mounted on your server) [1 = Enabled 0 = Disabled]" )
ulxmode = CreateConVar("uch_ulxmode", "0", { FCVAR_ARCHIVE }, "Use ULX/Evolve ranks on the scoreboard instead of Pigmask ranks (If no admin mods are detected, Pigmask ranks will be used) [1 = Enabled 0 = Disabled]" )
seasonalhud = CreateConVar( "uch_seasonalhud", "0", { FCVAR_ARCHIVE }, "Sets seasonal HUD [0 = Normal 1 = Halloween 2 = Christmas]" )

SetGlobalInt("WaitTime", waittime:GetInt())
SetGlobalBool("ULXMode", ulxmode:GetBool())
SetGlobalInt("SeasonalHUD", seasonalhud:GetInt())


function GM:Initialize()
	
	self.BaseClass:Initialize();
	
	timer.Simple(.1, function() RemoveDoors() RemoveAmbient() end);
	
	Ending = false;
	
	Changing = false;
	
	timer.Simple(.1, function() CacheStuff() end);
	
	SetState(STATE_WAITING)
	
	timer.Simple(waittime:GetInt(), function()
		if (EnoughPlayers()) then
			StartCountdown();
		end
	end);
	
	if ( ( string.sub( game.GetMap(), 1, 3 ) == "ch_" ) ) then
		maptype = 1; // We're playing on a ch_ map
	else
		maptype = 0; // We're playing on a non-ch_ map (music system will be launched)
	end
	
	if (!IsMounted("tf")) then
		print("******* TF2 isn't mounted. Please mount it on your server to avoid model collision problems! *******")
	end
	
end


function GM:PlayerDisconnected(ply)
	
	local t = nil;
	local num = 0;
	if (ply:Alive()) then
		num = 1;
	end
	
	if (Playing()) then
		
		if (ply:IsUC()) then
			t = "pigs";
		elseif (team.AlivePlayers(TEAM_PIGS) - num < 1) then
			t = "uc";
		end
		
	end
	
	if (t != nil) then
		RoundOver(t);
	end
	
	PrintMessage( HUD_PRINTTALK, "Player " .. ply:Name() .. " has disconnected." )
	
end


function GM:PlayerSetModel(ply)
	
	if (ply:IsUC()) then
		ply:SetModel("models/uch/uchimeragm.mdl");
		ply:SetSkin(0);
		ply:SetBodygroup(1, 1);
		ply:SetModelScale(1, 0);
	elseif (ply:IsGhost()) then
		ply:SetModel("models/uch/mghost.mdl");
	else
		ply:SetModel("models/uch/pigmask.mdl");
		ply:SetRankBodygroups();
		ply:SetRankSkin();
		ply:SetModelScale(1, 0);
	end
	
end


function GM:PlayerLoadout(ply)
	
	ply:StripWeapons();
	
end


function GM:IsSpawnpointSuitable(ply, spawn, bool)
	return true;
end


function GM:PlayerSpawn(ply) // Does stuff to a player when the game starts
	
	ply:UnSpectate();
	
	ply:SetupSpeeds();
	
	ply:SetJumpPower(242);
	
	ply:SetSprinting(false);
	
	ply:SetSprint(1);
	
	ply:SetPancake(false);
	
	ply.LastUC = false;
	ply:SetNWBool("UC_Voted", false);
	
	ply:UnScare(false);
	ply:ResetUCVars();
	
	ply:StopTaunting();
	
	if (ply:Team() != TEAM_SPECTATE) then
		
		if (ply:IsUC()) then
			
			ply.LastUC = true;
			
			ply:SetTeam(TEAM_UC);
			ply:SetJumpPower(260);
			ply:SetSwipeMeter(1);
			ply:SendLua("LocalPlayer().SwipeMeterSmooth = 1;");
			ply:SetSprint(1);
			ply:SendLua("LocalPlayer().SprintMeterSmooth = 1;");
			
		else
			
			if (ply:Team() == TEAM_UC) then
				ply:SetTeam(TEAM_PIGS);
			end
			
			ply.UCChance = (ply.UCChance || 0);
			ply.UCChance = math.Clamp((ply.UCChance + 1), 1, 10);
			
		end
		
		if (ply:Alive()) then
			ply:SetRank(ply.NextRank);
		end
		
		if (GetState() == STATE_WAITING) then
			if (EnoughPlayers() and CurTime() > waittime:GetInt() + 1.2) then
				StartCountdown();
			end
		end
		
	end
	
	hook.Call("PlayerSetModel", self, ply);
	
	UpdateHull(ply);
	
	timer.Simple(1, function() UpdateHull(ply) end )
	
end


function GM:PlayerInitialSpawn(ply)
	
	self.BaseClass:PlayerInitialSpawn(ply);
	ply:SetupVariables();
	
	ply:SpectateEntity(NULL);
	ply:UnSpectate();
	
	ply:SetCustomCollisionCheck(true);
	ply:SetCanZoom(false);
	
	if (!ply:IsBot()) then
		ply:SetTeam(TEAM_SPECTATE);
	else
		ply:SetTeam(TEAM_PIGS);
	end
	
	ply:SetDead(true);
	if (math.random(1, 6) == 1) then
		ply:SetBodygroup(1, 1);
	else
		ply:SetBodygroup(1, 0);
	end
	
	ply:SendLua("RunConsoleCommand(\"stopsound\")");
	ply:SendLua("timer.Simple(3, function() surface.PlaySound(\"uch/music/cues/join.mp3\") end)");
	ply:SendLua("timer.Create(\"WaitingMusic\", 10, 1, WaitingMusic)");
	
	ply:SendLua("CacheStuff()");
	ply:SendLua("ShowSplash()");
	SendMapList(ply);
	
end


function PlayerJoinTeam(ply, newteam)
	
	local oldteam = ply:Team();
	
	if (oldteam == TEAM_UC) then
		ply:ChatPrint("You cannot change teams as the Ultimate Chimera!");
		return;
	end
	
	if (ply.LastTeamSwitch != nil && RealTime() - ply.LastTeamSwitch < 10) then
		ply:ChatPrint("You must wait " .. tostring(math.ceil(10 -(RealTime() - ply.LastTeamSwitch))) .. " more second(s) to switch teams.");
		return;
	end
	
	if (PlayersFrozen()) then
		ply:ChatPrint("You cannot switch teams right now!");
		return;
	end
	
	local pos = ply:GetPos();
	local ang = ply:EyeAngles();
	local vel = ply:GetVelocity();
	
	local target = ply:GetObserverTarget();
	
	if (ply:Alive()) then
		ply:Kill();
	end
	
	ply:SetTeam(newteam);
	ply.LastTeamSwitch = RealTime();
	
	GAMEMODE:OnPlayerChangedTeam(ply, oldteam, newteam);
	ply:Spawn();
	if (!IsValid(target)) then
		ply:SetPos(pos);
	else
		ply:SetPos(target:GetPos());
	end
	ply:SetEyeAngles(ang);
	ply:SetLocalVelocity(vel);
	
end


function GM:OnPlayerChangedTeam( ply, oldteam, newteam )
	
	if ( oldteam > 3 ) then return end -- Just to stop from saying someone joined spectator on spawn
	chat.AddText( team.GetColor(oldteam), ply:Nick(), color_white, " joined ", team.GetColor(newteam), team.GetName(newteam), color_white, ".")
	
end


function ChangeTeam( ply, TeamID )
	
	PlayerJoinTeam( ply, TeamID )
	
end


function ChangeTeam2( length, ply )
	
	local TeamID = net.ReadTable()[1];
	PlayerJoinTeam( ply, TeamID )
	
end
util.AddNetworkString( "ChangeTeam" )
net.Receive("ChangeTeam", ChangeTeam2)


function GM:PlayerSelectSpawn(ply)
	
	if (ply:IsUC()) then
		
		local spawntype = 1;
		local map = string.Replace(game.GetMap(), " ", "")
		if (file.Exists("gamemodes/ultimatechimerahunt/content/data/uch/spawns/" .. map .. ".txt", "GAME")) then
			spawntype = 2;
		elseif (#ents.FindByClass("chimera_spawn") >= 1) then //spawn at random chimera spawn
			spawntype = 3;
		else //map not supported
			ply:ChatPrint(map .. " isn't supported by this gamemode!");
		end
		
		if (spawntype == 2) then
			
			local map = game.GetMap();
			local file2 = file.Read("gamemodes/ultimatechimerahunt/content/data/uch/spawns/" .. map .. ".txt", "GAME");
			local file3 = string.Explode(" ", file2);
			local targ = ents.Create("info_target");
			targ:SetPos(Vector(file3[1], file3[2], file3[3]));
			targ:SetAngles(Angle(file3[4], file3[5], file3[6]));
			targ:Spawn();
			return targ;
			
		elseif (spawntype == 3) then
			
			local spawns = ents.FindByClass("chimera_spawn");
			return spawns[math.random(1, #spawns)];
			
		end
		
	end
	
	
	if ((ply:Team() == TEAM_PIGS || ply:Team() == TEAM_SPECTATE || ply.LastUC) && !ply:IsUC()) then
		return self.BaseClass:PlayerSelectSpawn(ply);
	end
	
	//TF2 maps, load from file
	//Chimera Spawn, find entity
	//Neither, map not supported
	
end


function GM:PlayerDeathThink(ply)
	
	local state = GetState();
	if (state == STATE_PLAYING || state == STATE_INTERMISSION) then
		return;
	else
		self.BaseClass:PlayerDeathThink(ply);
	end
	
end


function AddPigDeadCount()
	
	SetGlobalInt("PigDeadCount", GetGlobalInt("PigDeadCount") + 1);
	
end


function ResetPigDeadCount()
	
	SetGlobalInt("PigDeadCount", 0)
	
end


function GM:PlayerDeath(ply, wep, kill)
	
	//self.BaseClass:PlayerDeath(ply, wep, kill);
	if (!PlayersFrozen()) then
		ply:Freeze(false);
	end
	
	ply:UnScare(false);
	ply:StopTaunting();
	ply:NightVisionOff();
	
	ply:SetSprinting(false);
	
	if (ply:IsUC()) then
		ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
	
	ply:SetDead(true);
	
	ply:AddDeaths(1);
	
	UpdateHull(ply);
	ply:UpdateSpeeds();
	
	for k, v in pairs(player.GetAll()) do
		
		local target = v:GetObserverTarget();
		
		if (target == ply && !ply:IsUC()) then
			v:UnSpectate();
			v:SetPos(target:GetPos());
		end
		
	end
	
	local t = nil;
	
	if (ply:Team() == TEAM_PIGS) then
		
		if (math.random(1, 6) == 1) then
			ply:SetBodygroup(1, 1);
		else
			ply:SetBodygroup(1, 0);
		end
		
		timer.Create(tostring(ply) .. "SetGhostModel", 1, 1, function()
			if (ply:IsValid()) then
				hook.Call("PlayerSetModel", GAMEMODE, ply);
			end
		end);
		
		timer.Create(tostring(ply) .. "RemoveCorpse", 10, 1, function()
			if (ply:IsValid()) then
				local prag = ply:GetRagdollEntity();
				if (IsValid(prag)) then
					prag:Remove();
				end
			end
		end);
		
		if (team.AlivePlayers(TEAM_PIGS) <= 0 && Playing()) then
			t = "uc";
		end
		
		ply:SendLua("surface.PlaySound(\"uch/music/cues/die.mp3\")");
		
		AddPigDeadCount();
		
	else
		
		t = "pigs";
		
	end
	
	if (t != nil && Playing()) then
		RoundOver(t);
	end
	
end


function GM:DoPlayerDeath(ply, wep, kill)
	
	//self.BaseClass:DoPlayerDeath(ply, wep, kill);
	
end


function CheckForBrokenTimers()
	
	if (TimerCheck != false && TimerCheck != true) then
		TimerCheck = true;
	end
	
	if (CurTime() >= (LastTimerCheck || 0)) then
		LastTimerCheck = (CurTime() + 2);
		if (TimerCheck) then
			
			TimerCheck = false;
			timer.Simple(1, function()
				TimerCheck = true; //We're working  :D
			end);
			
		else //fuck, timers broke :|
			
			LastTimerCheck = (CurTime() + 100000);
			
			local map = game.GetMap()
			chat.AddText(Color(250, 250, 250, 255), "Timers are broken, this will be fixed at some point. Resetting map...");
			WaitForMapChange = (CurTime() + 5);
			ShouldMapChange = true;
			NextMap = map;
			
		end
	end
end


function SendKillNotice(str, ent1, ent2)
	
	net.Start("KillNotice")
		net.WriteString(str);
		net.WriteEntity(ent1);
		net.WriteEntity(ent2);
	net.Send(player.GetAll())
	
end


function DoKillNotice(ply)
	if (ply:IsUC()) then
		if (ply.Pressed && ply.Presser:IsValid()) then
			SendKillNotice("press", ply, ply.Presser);
			ply.Pressed = false;
			ply.Presser = nil;
		else
			SendKillNotice("skull", ply);
		end
	else
		local uc = GetUC();
		if (ply.Squished) then
			ply.Squished = false;
			SendKillNotice("pop", ply, uc);
			return;
		end
		if (ply.Bit) then
			ply.Bit = false;
			SendKillNotice("bite", ply, uc);
			return;
		end
		if (ply.Suicide) then
			ply.Suicide = false;
			SendKillNotice("suicide", ply);
			return;
		end
		SendKillNotice("skull", ply);
	end
end


function GM:EntityKeyValue(ent, key, value)
	
	//set keyvalues?  Is this needed?
	
end


function BackToWaiting()
	
	SetState(STATE_WAITING);
	RemoveUC();
	RemoveAmbient();
	ResetPlayers();
	
end


function StartGame() //start game, choose round, etc.
	
	local state = GetState();
	if (state == STATE_PLAYING || state == STATE_VOTING) then
		return;
	end
	
	if (!EnoughPlayers()) then
		
		SetState(STATE_WAITING);
		print("The game tried to start, but there weren't enough players!");
		return;
		
	end
	
	game.CleanUpMap();
	RemoveDoors();
	if (maptype == 1 && musicmode:GetBool()) then
		RemoveAmbient();
	end
	
	StartTimer();
	
	NewUC();
	
	Votes = 0;
	
	SetState(STATE_PLAYING);
	
	ResetPlayers();
	
	if (maptype == 0 || musicmode:GetBool()) then
		timer.Create("RoundMusic", 4, 1, RoundMusic);
	end
	
end


function RoundMusic(last)
	local musicnumber = math.random(1,25);
	if (musicnumber == last) then
		RoundMusic(musicnumber);
		return;
	end
	local list = file.Read("gamemodes/ultimatechimerahunt/content/data/uch/music/round.txt", "GAME");
	local duration = string.Explode(";", list)[musicnumber];
	timer.Create("RoundMusic", duration, 1, function() RoundMusic(musicnumber) end);
	net.Start("PlayMusic")
		net.WriteString("round/" .. musicnumber);
	net.Send(player.GetAll())
end


function StopMusic()
	timer.Remove("RoundMusic");
	for k, v in pairs(player.GetAll()) do
		v:SendLua("timer.Remove(\"WaitingMusic\")");
	end
end


function GetWinningWant()
	
	local Votes = {}
	
	for k, ply in pairs( player.GetAll() ) do
		
		local want = ply:GetNWString( "Wants", nil )
		if ( want && want != "" ) then
			Votes[ want ] = Votes[ want ] or 0
			Votes[ want ] = Votes[ want ] + 1			
		end
		
	end
	
	return table.GetWinningKey( Votes )
	
end


function GetRandomMap()
	
	return table.Random(GetMaps())
	
end


function GetWinningMap()
	
	//if ( GAMEMODE.WinningMap ) then return GAMEMODE.WinningMap end
	
	local winner = GetWinningWant()
	if ( !winner ) then return GetRandomMap() end
	
	return winner
	
end


function ClearPlayerWants()
	
	for k, ply in pairs( player.GetAll() ) do
		ply:SetNWString( "Wants", "" )
	end
	
end


function ChangeGamemode(mp)
	
	RunConsoleCommand( "changelevel", string.sub(mp, 1, string.len(mp) - 4))
	
end


function FinishMapVote()
	
	local WinningMap = GetWinningMap()
	ClearPlayerWants()
	
	// Send bink bink notification
	BroadcastLua( "ChangingGamemode( \"".. WinningMap .."\" )" );
	
	// Start map vote?
	timer.Simple( 3, function() ChangeGamemode(WinningMap) end )
	
end


function StartMapVote()
	
	SetGlobalBool( "InGamemodeVote", true );
	
	BroadcastLua( "ShowVoteScreen()" );
	
	local musicnumber = math.random(1,36);
	net.Start("PlayMusic")
		net.WriteString("voting/" .. musicnumber);
	net.Send(player.GetAll())
	
	timer.Simple( 25, FinishMapVote );
	SetGlobalFloat( "VoteEndTime", CurTime() + 25 );
	
end


function EndOfGame()
	
	SetState(STATE_VOTING);
	
	OnEndOfGame();
	
	MsgN( "Starting map vote..." );
	PrintMessage( HUD_PRINTTALK, "Starting map vote..." );
	timer.Simple( 8.1, function() StartMapVote() end );
	SetGlobalFloat( "VoteStartTime", CurTime() + 8.1 );
	
end


function OnEndOfGame()
	
	FreezePlayers(true);
	BroadcastLua("RunConsoleCommand(\"+showscores\")");
	StopMusic();
	BroadcastLua("RunConsoleCommand(\"stopsound\")");
	BroadcastLua("timer.Simple(.1, function() surface.PlaySound(\"uch/music/cues/gameover.mp3\") end) timer.Simple(4.1, function() surface.PlaySound(\"uch/music/cues/gameover.mp3\") end)");
	
end


function ResetGame()
	
	if (GetState() == STATE_INTERMISSION && (GetTimeLimit() - CurTime()) <= 0) then
		EndOfGame();
		
		return;
		
	end
	
	if (GetState() == STATE_VOTING) then
		return;
	end
	
	if (EnoughPlayers()) then
		
		StartGame();
		
	else
		
		BackToWaiting();
		
	end
	
	ResetPigDeadCount();
	
end


function StartCountdown()
	
	FreezePlayers(true);
	timer.Simple(3, StartGame);
	
end


function RoundOver(t)
	
	SetGlobalString( "WinningTeam", t );
	
	SetState(STATE_INTERMISSION);
	
	local countdown;
	if (t != "tie" && t != "") then
		countdown = 10;
	else
		countdown = 5;
	end
	
	timer.Simple(countdown, function() ResetGame() end);
	
	timer.Simple(countdown - 1, function() FreezePlayers(true) end);
	
	StopMusic();
	
	if (t == "uc") then
		for k, v in pairs(player.GetAll()) do
			
			local music;
			if (v:Team() != TEAM_PIGS) then
				music = "win_chimera";
			else
				music = "lose_pigs";
			end
			
			v:SendLua("timer.Simple(.5, function() RunConsoleCommand(\"stopsound\") end)");
			
			v:SendLua("timer.Simple(.6, function() surface.PlaySound(\"uch/music/cues/" .. music .. ".mp3\") end)");
			
		end
		local uc = GetUC();
		uc:AddFrags(2);
	elseif (t == "pigs") then
		for k, v in pairs(player.GetAll()) do
			
			local music;
			if (!v:IsUC()) then
				music = "win_pigs";
			else
				music = "lose_chimera";
			end
			
			v:SendLua("timer.Simple(.3, function() RunConsoleCommand(\"stopsound\") end)");
			
			v:SendLua("timer.Simple(.4, function() surface.PlaySound(\"uch/music/cues/" .. music .. ".mp3\") end)");
			
		end
	elseif (t == "tie") then
		for k, v in pairs(player.GetAll()) do
			
			v:Kill();
			v.NextRank = math.Clamp((v:GetRankNum() - 1), 1, 4);
			
			v:SendLua("RunConsoleCommand(\"stopsound\")");
			
			v:SendLua("timer.Simple(.1, function() surface.PlaySound(\"uch/music/cues/timer_end.mp3\") end)");
			
		end
	end
end


function EnoughPlayers()
	
	return ((team.NumPlayers(TEAM_PIGS) + team.NumPlayers(TEAM_UC)) > NumPlayers);
	
end


function CountVotes()
	
	local plys = team.NumPlayersNotBots(TEAM_PIGS)
	local votes = Votes
	
	if (votes >= math.ceil((plys * .5))) then
		RoundOver("")
		chat.AddText(Color(255, 255, 255, 255), "Round restart initiated!")
		FreezePlayers(true)
		BroadcastLua("RunConsoleCommand(\"stopsound\")")
		BroadcastLua("timer.Simple(.1, function() surface.PlaySound(\"uch/music/cues/restart.mp3\") end)")
	end
	
end


function VoteRoundChange(ply)
	
	if (ply:GetNWBool("UC_Voted", true) || ply:IsUC() || !Playing() || ply:Team() == TEAM_SPECTATE) then
		return
	end
	
	ply:SetNWBool("UC_Voted", true)
	Votes = (Votes + 1)
	
	local str =  (tostring(Votes) .. "/" .. tostring(math.ceil((team.NumPlayersNotBots(TEAM_PIGS) * .5))))
	chat.AddText(Color(250, 200, 200, 255), ply:GetName(), Color(250, 250, 250, 255), " voted for a new Ultimate Chimera.  ", Color(62, 255, 62, 255), "(" .. str .. ")")
	
	CountVotes()
	
end


local function VoteChange(ply, cmd, args)
	
	VoteRoundChange(ply)
	
end
concommand.Add("uch_vote_uc", VoteChange)


function GM:PlayerConnect( name, ip )
	//PrintMessage( HUD_PRINTTALK, "Player " .. name .. " has joined the game." )
end


function VoteForChange( ply )
	
	if ( ply:GetNWBool( "WantsVote" ) ) then
		return
	end
	local waittime = waittime:GetInt()
	if (CurTime() < waittime + 1.2) then
		ply:ChatPrint( "You must wait " .. tostring(math.ceil(waittime + 1.2 - CurTime())) .. " more second(s) to vote for a new map." )
		return
	end
	
	ply:SetNWBool( "WantsVote", true )
	
	local VotesNeeded = GetVotesNeededForChange()
	local NeedTxt = ""
	if ( VotesNeeded > 0 ) then NeedTxt = ", Color( 80, 255, 50 ), [[ ("..VotesNeeded.." more votes needed.) ]] " end
	
	BroadcastLua( "chat.AddText( Entity("..ply:EntIndex().."), Color( 255, 255, 255 ), [[ has voted to change the map.]] "..NeedTxt.." )" )
	
	Msg( ply:Nick() .. " has voted to change the map.\n" )
	
	timer.Simple( 5, function() CountVotesForChange() end )
	
end
concommand.Add( "uch_vote_map", function( pl, cmd, args ) VoteForChange( pl ) end )


function GetVotesNeededForChange()
	
	local Fraction, NumHumans, WantsChange = GetFractionOfPlayersThatWantChange()
	local FractionNeeded = .7
	
	local VotesNeeded = math.ceil( FractionNeeded * NumHumans )
	
	return VotesNeeded - WantsChange
	
end


function GetFractionOfPlayersThatWantChange()
	
	local Humans = player.GetHumans()
	local NumHumans = #Humans
	local WantsChange = 0
	
	for k, player in pairs( Humans ) do
		
		if ( player:GetNWBool( "WantsVote" ) ) then
			WantsChange = WantsChange + 1
		end
		
		// Don't count players that aren't connected yet
		if ( !player:IsConnected() ) then
			NumHumans = NumHumans - 1
		end
		
	end
	
	local fraction = WantsChange / NumHumans
	
	return fraction, NumHumans, WantsChange
	
end


function CountVotesForChange()
	
	if ( GetState() == STATE_VOTING ) then
		return
	end
	
	fraction = GetFractionOfPlayersThatWantChange()
	
	if ( fraction > .7 ) then
		EndOfGame()
		return false
	end
	
end


function InGamemodeVote()
	return ( GetGlobalBool( "InGamemodeVote" ) )
end


function VotePlayMap( ply, map )
	
	if ( !map ) then return end
	if ( !InGamemodeVote() ) then return end
	if ( !IsValidMap( map ) ) then return end
	
	ply:SetNWString( "Wants", map )
	
end
concommand.Add( "votemap", function( pl, cmd, args ) VotePlayMap( pl, args[1] ) end )


function GetMaps()
	
	local AllMaps = file.Find("maps/*.bsp", "GAME")
	local UCHMaps = {}
	for k, v in pairs(AllMaps) do
		if (string.sub(v, 1, 3) == "ch_" || string.sub(v, 1, 8) == "gmt_uch_") then
			table.insert(UCHMaps, v)
		elseif (tf2maps:GetBool()) then
			if string.sub(v, 1, 14) == "arena_badlands" then
				table.insert(UCHMaps, v)
			elseif string.sub(v, 1, 16) == "arena_lumberyard" then
				table.insert(UCHMaps, v)
			elseif string.sub(v, 1, 20) == "arena_offblast_final" then
				table.insert(UCHMaps, v)
			elseif string.sub(v, 1, 12) == "arena_ravine" then
				table.insert(UCHMaps, v)
			elseif string.sub(v, 1, 13) == "arena_sawmill" then
				table.insert(UCHMaps, v)
			elseif string.sub(v, 1, 18) == "koth_harvest_event" then
				table.insert(UCHMaps, v)
			end
		end
	end
	
	return UCHMaps
	
end


function SendMapList(ply)
	
	net.Start("MapList")
		net.WriteTable(GetMaps());
	net.Send(ply)
	
end


function IsValidMap( map )
	
	if ( map == nil ) then return true end
	
	for _, mapname in pairs( GetMaps() ) do
		if ( mapname == map ) then return true end
	end
	
	return false
	
end


local function TeamMenu( ply )
	
	net.Start( "TeamMenu" )
	net.Send( ply )
	
end
hook.Add("ShowTeam", "ShowTeamMenu", TeamMenu);


local function HelpMenu( ply )
	
	net.Start( "HelpMenu" )
	net.Send(ply)
	
end
hook.Add("ShowHelp", "ShowHelpMenu", HelpMenu)


util.AddNetworkString("TeamMenu");
util.AddNetworkString("HelpMenu");
util.AddNetworkString("KillNotice");
util.AddNetworkString("UpdateRoundTimer");
util.AddNetworkString("UC_RestartAnimation");
util.AddNetworkString("SwitchLight");
util.AddNetworkString("UpdateHulls");
util.AddNetworkString("AddText");
util.AddNetworkString("TailSwipe");
util.AddNetworkString("UCMakeRagFly");
util.AddNetworkString("UCRoared");
util.AddNetworkString("FRecieveGlobalInt");
util.AddNetworkString("FRecieveGlobalEntity");
util.AddNetworkString("FRecieveGlobalBool");
util.AddNetworkString("GetRank");
util.AddNetworkString("SendRank");
util.AddNetworkString("MapList");
util.AddNetworkString("DoStompEffect");
util.AddNetworkString("PlayMusic");
