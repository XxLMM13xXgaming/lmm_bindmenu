MsgC( Color(255,0,0), "\n[BindMenu] Loading in progress! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
AddCSLuaFile( "bm_config.lua" )
include( "bm_config.lua" )
MsgC( Color(255,0,0), "\n[BindMenu] Config Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
util.AddNetworkString( "LMMBMOpenMenu" )
util.AddNetworkString( "LMMBMCreateBind" )
util.AddNetworkString( "LMMBMEditBind" )
util.AddNetworkString( "LMMBMDeleteBind" )
util.AddNetworkString( "LMMBMInvalidChars" )
util.AddNetworkString( "LMMBMPlayerOnCoolDown" )
MsgC( Color(255,0,0), "[BindMenu] Net Vars Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )
if !(file.Exists( "lmm_bm_data", "DATA" )) then
	file.CreateDir( "lmm_bm_data", "DATA" )
	MsgC( Color(255,0,0), "[BindMenu] Dada File Created! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )		
end
MsgC( Color(255,0,0), "[BindMenu] Data File Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )

function GivePlayerDataFileBM(ply)
	if !file.Exists( "lmm_bm_data/"..ply:SteamID64(), "DATA" ) then
		file.CreateDir( "lmm_bm_data/"..ply:SteamID64().."/binds", "DATA" )
	end 
end

local function SendGUI( ply )
	local title = {}
	for k,v in pairs( file.Find( "lmm_bm_data/"..ply:SteamID64().."/binds/*.txt", "DATA" ) ) do
		local contents = file.Read( "lmm_bm_data/"..ply:SteamID64().."/binds/" .. v )
		table.insert( title, { v, contents } )
	end	
	
	net.Start("LMMBMOpenMenu")
		net.WriteTable( title )
	net.Send( ply )
end	

concommand.Add( "+bindmenu", function( ply )
	SendGUI( ply )
end )

net.Receive( "LMMBMCreateBind", function( len, ply )
	local title = net.ReadString()
	local text = net.ReadString()
	local PlayerIsOnCoolDownAns = ply:GetNWFloat( "PlayerIsOnCoolDown" )
	
	if PlayerIsOnCoolDownAns == 1 then 
		net.Start( "LMMBMPlayerOnCoolDown" )
		net.Send( ply )		
		return
	end

	GivePlayerDataFileBM(ply)
	
	file.Write( "lmm_bm_data/"..ply:SteamID64().."/binds/"..title..".txt", text )
	
	if !(file.Exists( "lmm_bm_data/"..ply:SteamID64().."/binds/"..title..".txt", "DATA" )) then
		net.Start( "LMMBMInvalidChars" )
			net.WriteString( title )
		net.Send( ply )
	end
	
	ply:SetNWFloat( "PlayerIsOnCoolDown", 1 )
	timer.Simple( BMConfig.CoolTimeTime, function()
		ply:SetNWFloat( "PlayerIsOnCoolDown", 0 )
	end	)
	
end)

net.Receive( "LMMBMEditBind", function( len, ply )
	local title = net.ReadString()
	local text = net.ReadString()

	file.Write( "lmm_bm_data/"..ply:SteamID64().."/binds/"..title..".txt", text )

end)

net.Receive( "LMMBMDeleteBind", function(len, ply )
	local title = net.ReadString()

	file.Delete( "lmm_bm_data/"..ply:SteamID64().."/binds/"..title..".txt", "DATA" )
	
end	)

function LMMBMOpenMenu(ply, text)
	local text = string.lower(text)
	if(string.sub(text, 0, 100)== "/bindmenu" or string.sub(text, 0, 100)== "!bindmenu") then
		SendGUI(ply)
		return ''
	end
end 
hook.Add("PlayerSay", "LMMBMOpenMenu", LMMBMOpenMenu)

function LMMBMUpdateCMD(ply, text)
	local text = string.lower(text)
	if(string.sub(text, 0, 100)== "/bmupdate" or string.sub(text, 0, 100)== "!bmupdate") then
		ply:SendLua([[gui.OpenURL("https://github.com/XxLMM13xXgaming/lmm_bindmenu")]])
		return ''
	end
end 
hook.Add("PlayerSay", "LMMBMUpdateCMD", LMMBMUpdateCMD)
		
MsgC( Color(255,0,0), "[BindMenu] Server-side Loaded! (Made By: XxLMM13xXgaming STEAM_0:0:90799036)\n" )