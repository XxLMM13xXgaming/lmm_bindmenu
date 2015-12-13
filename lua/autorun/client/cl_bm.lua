if (CLIENT) then
	MsgC( Color(255,0,0), "\n[BindMenu] Loading in progress! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
	include("ab_config.lua")
	MsgC( Color(255,0,0), "[BindMenu] Config Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
	MsgC( Color(255,0,0), "[BindMenu] Client-Side Fully Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )

	surface.CreateFont( "BMfontclose", {
			font = "Lato Light",
			size = 25,
			weight = 250,
			antialias = true,
			strikeout = false,
			additive = true,
	} )
	 
	surface.CreateFont( "BMTitleFont", {
			font = "Lato Light",
			size = 30,
			weight = 250,
			antialias = true,
			strikeout = false,
			additive = true,
	} )
	 
	local blur = Material("pp/blurscreen")
	local function DrawBlur(panel, amount) --Panel blur function
		local x, y = panel:LocalToScreen(0, 0)
		local scrW, scrH = ScrW(), ScrH()
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(blur)
		for i = 1, 6 do
			blur:SetFloat("$blur", (i / 3) * (amount or 6))
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
		end
	end

	local function drawRectOutline( x, y, w, h, color )
		surface.SetDrawColor( color )
		surface.DrawOutlinedRect( x, y, w, h )
	end
	net.Receive( "LMMBMOpenMenu", function()
		local title = net.ReadTable()
		local binds = net.ReadTable()

		local DFrame = vgui.Create( "DFrame" )
		DFrame:SetSize( 450, 400 )
		DFrame:Center()
		DFrame:SetDraggable( false )
		DFrame:MakePopup()
		DFrame:SetTitle( "" )
		DFrame:ShowCloseButton( false )
		DFrame.Paint = function( self, w, h )
			DrawBlur(DFrame, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 85))
			drawRectOutline( 2, 2, w - 4, h / 8.9, Color( 0, 0, 0, 85 ) )
			draw.RoundedBox(0, 2, 2, w - 4, h / 9, Color(0,0,0,125))
			draw.SimpleText( "PrivKey Admin Menu", "BMTitleFont", DFrame:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local frameclose = vgui.Create( "DButton", DFrame )
		frameclose:SetSize( 35, 35 )
		frameclose:SetPos( DFrame:GetWide() - 36,9 )
		frameclose:SetText( "X" )
		frameclose:SetFont( "BMfontclose" )
		frameclose:SetTextColor( Color( 255, 255, 255 ) )
		frameclose.Paint = function()
			
		end
		frameclose.DoClick = function()
			DFrame:Close()
			DFrame:Remove()
		end

		local DComboBox = vgui.Create( "DComboBox", DFrame )
		DComboBox:SetPos( 10, 60 )
		DComboBox:SetSize( DFrame:GetWide() - 210, 20 )
		
		for k,v in pairs( title ) do
			DComboBox:AddChoice( v )
		end
		
		local DListView = vgui.Create( "DListView", DFrame )
		DListView:SetSize( DFrame:GetWide() - 20, DFrame:GetTall() - 100 )
		DListView:SetPos( 10, 85 )
		DListView:AddColumn( "Key" )
		DListView:AddColumn( "Rank" )
		DListView.OnRowRightClick = function( id, line)
			local value = DListView:GetLine( line ):GetValue( 1 )
			SetClipboardText( value )
			notification.AddLegacy( "Key copied to clipboard", NOTIFY_GENERIC, 3 )
		end
		
		local DButton = vgui.Create( "DButton", DFrame )
		DButton:SetSize( 90, 20 )
		DButton:SetText("Create")
		DButton:SetPos( DFrame:GetWide() - 195, 60 )
		DButton.DoClick = function()		
			if not DComboBox:GetSelected() then return end
		
			local menu = DermaMenu()
			menu:AddOption( "Random", function()
				net.Start("LMMPrivKeysGenerateKey")
					net.WriteString( DComboBox:GetSelected() )
				net.SendToServer()
				DFrame:Remove()
			end )
			menu:AddOption( "Custom", function()
				Derma_StringRequest(
					"Priv Key Custom Key Maker",
					"Input the key you would like",
					"",
					function( text )
						net.Start("LMMPrivKeyGenerateCustomKey")
							net.WriteString( DComboBox:GetSelected() )
							net.WriteString( text )
						net.SendToServer()
						DFrame:Remove()					
					end,
					function( text )
					end
				 )		
			end	)
			
			menu:Open()
		end
		
		local DButton = vgui.Create( "DButton", DFrame )
		DButton:SetSize( 90, 20 )
		DButton:SetText("Remove")
		DButton:SetPos( DFrame:GetWide() - 100, 60 )
		DButton.DoClick = function()
		
			local line = DListView:GetSelectedLine()
			local value = DListView:GetLine( line ):GetValue( 1 )

			net.Start("LMMPrivKeysDestroyKey")
				net.WriteString( value .. ".txt" )
			net.SendToServer()
			
			DFrame:Remove()
		end
		
		if #keys > 0 then
			for k,v in pairs( keys ) do
				DListView:AddLine( string.StripExtension( v[1] ), v[2] )
			end
		end
	end )	
end