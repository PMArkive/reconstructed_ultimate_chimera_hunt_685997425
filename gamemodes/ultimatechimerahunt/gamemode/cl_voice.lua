
local PANEL = {}
local PlayerVoicePanels = {}


function PANEL:Init()
	
	self.LabelName = vgui.Create( "DLabel", self )
	self.LabelName:SetFont( "GModNotify" )
	self.LabelName:Dock( FILL )
	self.LabelName:DockMargin( 8, 0, 200, 0 )
	self.LabelName:SetTextColor( Color( 255, 255, 255, 255 ) )
	
	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:Dock( LEFT )
	self.Avatar:SetSize( 32, 32 )
	
	self.Color = color_transparent
	
	self:SetSize( 250, 32 + 8 )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin( 2, 2, 2, 2 )
	self:Dock( BOTTOM )
	
end


function PANEL:Setup( ply )
	
	self.ply = ply
	self.LabelName:SetText( ply:Nick() )
	self.Avatar:SetPlayer( ply )
	
	self.Color = team.GetColor( ply:Team() )
	
	self:InvalidateLayout()
	
end


function PANEL:Paint( w, h )
	
	if ( !IsValid( self.ply ) ) then return end
	local r, g, b = self.ply:GetRankColor()
	local r2, g2, b2 = r/4, g/4, b/4
	if ( self.ply:IsGhost() ) then
		r, g, b = 192, 192, 192
		r2, g2, b2 = 128, 128, 128
	end
	draw.RoundedBox( 4, 0, 0, w-200, h,  Color( r2, g2, b2, 240 ) )
	draw.RoundedBox( 4, 2, 2, w-204, h-4, Color( r/2, g/2, b/2, 240 ) )
	draw.RoundedBox( 0, 42, h-9, (w/2.26), 4, Color( 0, 0, 0, 192 ) )
	draw.RoundedBox( 0, 42, h-9, (w/2.26) * self.ply:VoiceVolume(), 4, Color( 255, 255, 255, 192 ) )
	
end


function PANEL:Think( )
	
	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end
	
end


function PANEL:FadeOut( anim, delta, data )
	
	if ( anim.Finished ) then
		
		if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
			PlayerVoicePanels[ self.ply ]:Remove()
			PlayerVoicePanels[ self.ply ] = nil
			return
		end
		
	return end
	
	self:SetAlpha( 255 - (255 * delta) )
	
end


derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )


function GM:PlayerStartVoice( ply )
	
	if ( !IsValid( g_VoicePanelList ) ) then return end
	
	-- There'd be an exta one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice( ply )
	
	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
		
		if ( PlayerVoicePanels[ ply ].fadeAnim ) then
			PlayerVoicePanels[ ply ].fadeAnim:Stop()
			PlayerVoicePanels[ ply ].fadeAnim = nil
		end
		
		PlayerVoicePanels[ ply ]:SetAlpha( 255 )
		
		return
		
	end
	
	if ( !IsValid( ply ) ) then return end
	
	local pnl = g_VoicePanelList:Add( "VoiceNotify" )
	pnl:Setup( ply )
	
	PlayerVoicePanels[ ply ] = pnl
	
	ply.PiggyWiggle = true
	
end


local function VoiceClean()
	
	for k, v in pairs( PlayerVoicePanels ) do
		
		if ( !IsValid( k ) ) then
			GAMEMODE:PlayerEndVoice( k )
		end
		
	end
	
end


timer.Create( "VoiceClean", 10, 0, VoiceClean )


function GM:PlayerEndVoice( ply )
	
	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
		
		if ( PlayerVoicePanels[ ply ].fadeAnim ) then return end
		
		PlayerVoicePanels[ ply ].fadeAnim = Derma_Anim( "FadeOut", PlayerVoicePanels[ ply ], PlayerVoicePanels[ ply ].FadeOut )
		PlayerVoicePanels[ ply ].fadeAnim:Start( 1 )
		
	end
	
	if ( !IsValid( ply ) ) then return end
	ply.PiggyWiggle = false
	
end


local function CreateVoiceVGUI()
	
	g_VoicePanelList = vgui.Create( "DPanel" )
	
	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList:SetPos( ScrW() - 300, 100 )
	g_VoicePanelList:SetSize( 450, ScrH() - 200 )
	g_VoicePanelList:SetDrawBackground( false )
	
end
hook.Add( "InitPostEntity", "CreateVoiceVGUI", CreateVoiceVGUI )
