if (CLIENT) then 
	MsgC( Color(255,0,0), "\n[BindMenu] Loading in progress! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
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
			draw.SimpleText( "Bind Menu", "BMTitleFont", DFrame:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

		local HelpBtn = vgui.Create( "DButton", DFrame )
		HelpBtn:SetSize( DFrame:GetWide() - 325, 20 )
		HelpBtn:SetPos( 315, 60 )
		HelpBtn:SetText( "Help" )
		HelpBtn.DoClick = function()
			Derma_Message( [[1.) Put in a short title like Raid or Mug or something like that
			2.) Press enter when you are done with the title
			3.) Enter the chat text like /advert Raid!
			4.) Re-Open this menu and double click the line to say it!]], "BindMenu Help", "Got it!" )		
		end
		
		local TextEntry = vgui.Create( "DTextEntry", DFrame )	-- create the form as a child of frame
		TextEntry:SetPos( 10, 60 )
		TextEntry:SetSize( DFrame:GetWide() - 150, 20 )
		TextEntry:SetText( "Title" )
		TextEntry.OnEnter = function( self )
			Derma_StringRequest(
				tostring(self:GetValue()),
				"Imput the chat command you want to use... (ex. /advert raid!)",
				"",
				function( text )
					net.Start( "LMMBMCreateBind" )
						net.WriteString( self:GetValue() )
						net.WriteString( text )
					net.SendToServer()
					DFrame:Close()
					DFrame:Remove()					
				end
			)		
		end
		
		for k,v in pairs( title ) do
			DComboBox:AddChoice( v )
		end
		
		local DListView = vgui.Create( "DListView", DFrame )
		DListView:SetSize( DFrame:GetWide() - 20, DFrame:GetTall() - 100 )
		DListView:SetPos( 10, 85 )
		DListView:AddColumn( "Title" )
		DListView:AddColumn( "Text" )
		function DListView:DoDoubleClick( line )
			local LocalText = DListView:GetLine( line ):GetValue( 2 )
			local LocalTitle = DListView:GetLine( line ):GetValue( 1 )		
		
			LocalPlayer():ConCommand( "say "..LocalText )
		end
		DListView.OnRowRightClick = function( id, line)
			local LocalText = DListView:GetLine( line ):GetValue( 2 )
			local LocalTitle = DListView:GetLine( line ):GetValue( 1 )
			local menu = DermaMenu()
			menu:AddOption( "Edit", function()
				Derma_StringRequest(
					"EDIT: "..LocalTitle,
					"Imput the chat command you want to use... (ex. /advert raid!)",
					"",
					function( text )
						net.Start( "LMMBMEditBind" )
							net.WriteString( LocalTitle )
							net.WriteString( text )
						net.SendToServer()
						DFrame:Close()
						DFrame:Remove()						
					end
				)			
			end )
			menu:AddOption( "Delete", function()
				Derma_StringRequest(
					"DELETE!?!",
					"Are you sure you want to delete "..LocalTitle.."??? (TYPE YES OR NO)",
					"",
					function( text )
						if text == "YES" then
							net.Start( "LMMBMDeleteBind" )
								net.WriteString( LocalTitle )
							net.SendToServer()
							DFrame:Close()
							DFrame:Remove()
							chat.AddText( Color(255,0,0), "You deleted this bind!" )							
						else
							chat.AddText( Color(0,255,0), "You did NOT delete this bind!" )
						end
					end
				)	
			end )
			menu:Open()
		end
		
		if #title > 0 then
			for k,v in pairs( title ) do
				DListView:AddLine( string.StripExtension( v[1] ), v[2] )
			end
		end
	end )	
end