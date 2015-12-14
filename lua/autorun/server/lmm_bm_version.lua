--[[You really should not edit this!]]--
local version = "1.3" -- DO NOT EDIT THIS!
local version_url = "https://gist.githubusercontent.com/XxLMM13xXgaming/b4e362751c03cd89328e/raw/lmm_bindmenu" -- DO NOT EDIT THIS!
local update_url = "https://github.com/XxLMM13xXgaming/lmm_bindmenu" -- DO NOT EDIT THIS!
local msg_outdated = "You are using a outdated/un-supported version. You are on version "..version.."! Please download the new version here: " .. update_url -- DO NOT EDIT THIS!
local ranksthatgetnotify = { "superadmin", "owner", "admin", "trial moderator", "moderator" } -- DO NOT EDIT THIS!

http.Fetch(version_url, function(body, len, headers, code, ply)
	if (string.Trim(body) ~= version) then
		MsgC( Color(255,0,0), "[BindMenu] You are NOT using the latest version! ("..string.Trim(body)..")\n" )
	else
		MsgC( Color(255,0,0), "[BindMenu] You are using the latest version! ("..version..")\n" )
	end
end )	
timer.Create("BindMenuVersionCheckServerTimer", 600, 0, function()
	http.Fetch(version_url, function(body, len, headers, code, ply)
		if (string.Trim(body) ~= version) then
			MsgC( Color(255,0,0), "[BindMenu] You are NOT using the latest version! ("..string.Trim(body)..")\n" )
		end
	end )
end )
	 
hook.Add("PlayerInitialSpawn", "BindMenuVersionCheckServerTimer", function(ply)
	if (table.HasValue( ranksthatgetnotify, ply:GetUserGroup() ) ~= true) then return end
	
    http.Fetch(version_url, function(body, len, headers, code)

        if (string.Trim(body) ~= version) then
			ply:ChatPrint("[BindMenu] "..msg_outdated)
			timer.Create( "BindMenuVersionCheckTimer", 600, 6, function()
				ply:ChatPrint("[BindMenu] "..msg_outdated)
			end )
		else
			MsgC( Color(255,0,0), "[BindMenu] You are using the latest version! ("..version..")" )
        end
		
    end, function(error)

        -- Silently fail

    end)
end)
