
//Fretta function, copy-pasted so I could add onto it.  Credits - Garry


local function CreateHowToPlay()
	
	//Create How to Play menu here
	
	local frame = vgui.Create("DFrame");
	
	local w = ScreenScale(325);
	local h = (400 * (ScrH() / 480));
	
	frame:SetSize(w, h);
	frame:SetPos(((ScrW() * .5) - (w * .5)), ((ScrH() * .5) - (h * .5)));
	frame:MakePopup();
	
	local p1 = vgui.Create("DPropertySheet", frame);
	p1:SetPos(5, 30);
	p1:SetSize((frame:GetWide() - 10), (frame:GetTall() - 60));
	
end


local function AddHowToPlay(help)
	
	/*local btn = help:AddSelectButton("How to Play", function()
		CreateHowToPlay();
	end);
	btn.m_colBackground = Color(200, 200, 200);*/
	
end


local Help = nil 


function ShowHelp()
	
	if ( !IsValid( Help ) ) then
		
		Help = vgui.CreateFromTable( vgui_Splash )
		Help:SetHeaderText( "" )
		Help:SetHoverText( "As a Pigmask:\nDo your duty to King Porky and shut down the Ultimate Chimera by pressing the button on its back! If you succeed, you will be awarded with a rank advancement! Just watch out for those teeth...\nLeft click/E: Press button\nRight click: Salute\n\nAs the Ultimate Chimera:\nDestroy everything in your path! The Pigmask Army has come to stop you, but you're not going down without a fight, right?\nLeft click: Bite\nRight click: Roar\nR: Tail whip\nF: Night vision\n\nAs a Ghost:\nWatch the game, but try not to interfere!\nLeft click: Focus on a player\nRight click: Change perspective" );
		
		Help.lblFooterText.Think = function( panel ) 
										local tl = math.floor(GetGameTimeLeft())
										if ( GetState() == STATE_VOTING ) then panel:SetText( "Game has ended..." ) return end
										if ( CurTime() > GetTimeLimit() ) then panel:SetText( "Game will end after this round." ) return end
										
										local minute = tostring(math.floor(tl/60));
										local second = tl - minute * 60;
										if ( second < 10 ) then second = "0" .. second end -- Couldn't use string.ToMinutesSeconds, not working :C
										tl = minute .. ":" .. second;
										panel:SetText( "Time Left: " .. tl ) 
									end
		
		local btn = Help:AddSelectButton( "Vote For New Map", function() RunConsoleCommand( "uch_vote_map" ) end )
		btn.m_colBackground = Color( 255, 200, 100 )
		btn:SetDisabled( LocalPlayer():GetNWBool( "WantsVote" ) ) 
		btn.Paint = function( w, h )
						surface.SetDrawColor( Color( 255, 200, 100, 255 ) )
						surface.DrawOutlinedRect( 0, 0, btn:GetWide(), btn:GetTall() )
					end
		
		local btn = Help:AddSelectButton( "Change Team", function() ShowTeam() end )
		btn.m_colBackground = Color( 120, 255, 100 )
		btn.Paint = function( w, h )
						surface.SetDrawColor( Color( 120, 255, 100, 255 ) )
						surface.DrawOutlinedRect( 0, 0, btn:GetWide(), btn:GetTall() )
					end
		
		/*if ( !GAMEMODE.TeamBased && GAMEMODE.AllowSpectating ) then
			
			if ( LocalPlayer():Team() == TEAM_SPECTATOR ) then
				
				local btn = Help:AddSelectButton( "Join Game", function() RunConsoleCommand( "changeteam", TEAM_UNASSIGNED ) end )
				btn.m_colBackground = Color( 120, 255, 100 )
				
			else
				
				local btn = Help:AddSelectButton( "Spectate", function() RunConsoleCommand( "changeteam", TEAM_SPECTATOR ) end )
				btn.m_colBackground = Color( 200, 200, 200 )
				
			end
		end
		
		local TeamID = LocalPlayer():Team()
		local Classes = team.GetClass( TeamID )
		if ( Classes && #Classes > 1 ) then
			local btn = Help:AddSelectButton( "Change Class", function() GAMEMODE:ShowClassChooser( LocalPlayer():Team() ) end )
			btn.m_colBackground = Color( 120, 255, 100 )
		end*/
		
		Help:AddCancelButton()
		//AddHowToPlay(Help);
		/*
		if ( GAMEMODE.SelectModel ) then
			
			local function CreateModelPanel()
				
				local pnl = vgui.Create( "DGrid" )
				
				pnl:SetCols( 6 )
				pnl:SetColWide( 66 )
				pnl:SetRowHeight( 66 )
				
				for name, model in pairs( list.Get( "PlayerOptionsModel" ) ) do
					
					local icon = vgui.Create( "SpawnIcon" )
					icon.DoClick = function() surface.PlaySound( "ui/buttonclickrelease.mp3" ) RunConsoleCommand( "cl_playermodel", name ) end
					icon.PaintOver = function() if ( GetConVarString( "cl_playermodel" ) == name ) then surface.SetDrawColor( Color( 255, 210 + math.sin(RealTime()*10)*40, 0 ) ) surface.DrawOutlinedRect( 4, 4, icon:GetWide()-8, icon:GetTall()-8 ) surface.DrawOutlinedRect( 3, 3, icon:GetWide()-6, icon:GetTall()-6 ) end end
					icon:SetModel( model )
					icon:SetSize( 64, 64 )
					icon:SetTooltip( name )
					
					pnl:AddItem( icon )
					
				end
				
				return pnl
				
			end
			
			Help:AddPanelButton( "gui/silkicons/user", "Choose Player Model", CreateModelPanel )
			
		end
		
		if ( GAMEMODE.SelectColor ) then
			
			local function CreateColorPanel()
				
				local pnl = vgui.Create( "DGrid" )
				
				pnl:SetCols( 10 )
				pnl:SetColWide( 36 )
				pnl:SetRowHeight( 128 )
				
				for name, colr in pairs( list.Get( "PlayerColours" ) ) do
					
					local icon = vgui.Create( "DButton" )
					icon:SetText( "" )
					icon.DoClick = function() surface.PlaySound( "ui/buttonclickrelease.mp3" ) RunConsoleCommand( "cl_playercolor", name ) end
					icon.Paint = function() surface.SetDrawColor( colr ) icon:DrawFilledRect() end
					icon.PaintOver = function() if ( GetConVarString( "cl_playercolor" ) == name ) then surface.SetDrawColor( Color( 255, 210 + math.sin(RealTime()*10)*40, 0 ) ) surface.DrawOutlinedRect( 4, 4, icon:GetWide()-8, icon:GetTall()-8 ) surface.DrawOutlinedRect( 3, 3, icon:GetWide()-6, icon:GetTall()-6 ) end end
					icon:SetSize( 32, 128 )
					icon:SetTooltip( name )
					
					pnl:AddItem( icon )
					
				end
				
				return pnl
				
			end
			
			Help:AddPanelButton( "gui/silkicons/application_view_tile", "Choose Player Color", CreateColorPanel )
			
		end
		*/
		
	end
	
	Help:MakePopup()
	Help:NoFadeIn()
	
end
net.Receive("HelpMenu", ShowHelp)
