if (SERVER) then
	MsgC( Color(255,0,0), "\n[BindMenu] Loading in progress! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
	AddCSLuaFile("bm_config.lua.lua")
	include("bm_config.lua.lua")
	MsgC( Color(255,0,0), "[BindMenu] Config Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
	if !(file.Exists( "lmm_bm_data", "DATA" )) then
		file.CreateDir( "lmm_bm_data", "DATA" )
		MsgC( Color(255,0,0), "[BindMenu] Dada File Created! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )		
	end
	MsgC( Color(255,0,0), "[BindMenu] Data File Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
	
	local function SendGUI( ply )
		local binds = {}
		for k,v in pairs( file.Find( "lmm_bm_data/"..ply:SteamID64().."/binds/*.txt", "DATA" ) ) do
			local contents = file.Read( "lmm_bm_data/"..ply:SteamID64().."/binds/" .. v )
			table.insert( binds, { v, contents } )
		end

		local title = {}
		for k,v in pairs( file.Find( "lmm_bm_data/"..ply:SteamID64().."/title/*.txt", "DATA" ) ) do
			local contents = file.Read( "lmm_bm_data/"..ply:SteamID64().."/title/" .. v )
			table.insert( title, { v, contents } )
		end		
		
		net.Start("LMMBMOpenMenu")
			net.WriteTable( title )
			net.WriteTable( binds )
		net.Send( ply )
	end	

	function LMMBMOpenMenu(ply, text)
		local text = string.lower(text)
		if(string.sub(text, 0, 100)== "/"..ABConfig.CommandForOpening or string.sub(text, 0, 100)== "!"..ABConfig.CommandForOpening) then
			SendGUI(ply )
		 	return ''
		end
	end 
	hook.Add("PlayerSay", "LMMBMOpenMenu", LMMBMOpenMenu)		
	MsgC( Color(255,0,0), "[BindMenu] Server-side Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
end