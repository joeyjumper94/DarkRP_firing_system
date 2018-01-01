AddCSLuaFile()
local delay=delay or 30
timer.Simple(delay,function()
	delay=0.1
	if RPExtraTeams then

		local flags={FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,}
		local darkrp_notify=CreateConVar("darkrp_notify_all","1",flags,"should non cops see when someone is fired?"):GetBool()
		local darkrp_allow_cheif=CreateConVar("darkrp_allow_cheif","1",flags,"should the police chief be able to fire?"):GetBool()
		local darkrp_fire_demotion_time_cvar=CreateConVar("darkrp_fire_demotion_time","-1",flags,"decide how long someone is demoted for when fired,set to -1 to use the time defined by darkrp"):GetInt()
		local darkrp_demote_timer=120

		if darkrp_fire_demotion_time_cvar>=0 then
			darkrp_demote_timer=darkrp_fire_demotion_time_cvar
		elseif GAMEMODE and GAMEMODE.Config and GAMEMODE.Config.demotetime then
			darkrp_demote_timer=GAMEMODE.Config.demotetime
		elseif CLIENT then
			LocalPlayer():PrintMessage(HUDPRINT_TALK,"darkrp darkrp_demote_timer not set, tell the server dev")
		end

		if CLIENT then return end

		local function darkrp_findplayer(args)
			local tbl={}
			for i=1,20 do
				table.insert(tbl,args[i])
			end
			arg=table.concat(tbl)
			for k,v in ipairs(player.GetAll()) do
				if v:SteamID()==arg then
					return v
				elseif v:SteamID64()==arg then
					return v
				elseif v:Nick():find(arg) then
					return v
				end
			end
		end

		local function darkrp_firing(target,ply,target)
			for k,v in ipairs(player.GetAll()) do
				if v==target then
					DarkRP.notify(v,1,8,ply:Nick().." fired you")
				elseif v==ply then
					DarkRP.notify(v,0,8,"you fired "..target:Nick())
				elseif darkrp_notify_all then
					DarkRP.notify(v,0,8,ply:Nick().." fired "..target:Nick())
				end
			end

			target:changeTeam(GAMEMODE.DefaultTeam, true)
			for k,v in ipairs(RPExtraTeams) do
				if GAMEMODE.CivilProtection[k] then
					target:teamBan(k,darkrp_demote_timer)
				end
			end
		end

		DarkRP.defineChatCommand("fire", function(ply,args)
			if ply:IsValid() and ply:IsPlayer() then
				local target=darkrp_findplayer(args)
				if ply:isMayor() then
					if target:getDarkRPVar("job"):find("corrupt") then
						DarkRP.notify(ply,1,8,"you can't fire a corrupt "..team.GetName(target:Team()))
					elseif target==ply then
						DarkRP.notify(ply,1,8,"you can't fire yourself")
					elseif target and target:isCP() then
						darkrp_firing(target,ply,target)
					elseif target then
						DarkRP.notify(ply,1,8,"you can only fire cops")
					else
						DarkRP.notify(ply,1,8,'cannot find ("'..tostring(args[1])..'".')
					end
				elseif ply:isChief() and darkrp_allow_cheif then
					if target:getDarkRPVar("job"):find("corrupt") then
						DarkRP.notify(ply,1,8,"you can't fire a corrupt "..team.GetName(target:Team()))
					elseif target:isMayor() then
						DarkRP.notify(ply,1,8,"you can't fire the "..team.GetName(target:Team()))
					elseif target==ply then
						DarkRP.notify(ply,1,8,"you can't fire yourself")
					elseif target and target:isCP() then
						darkrp_firing(target,ply,target)
					elseif target then
						DarkRP.notify(ply,1,8,"you can only fire cops")
					else
						DarkRP.notify(ply,1,8,"cannot find (\""..tostring(args[1])..'".')
					end
				else
					DarkRP.notify(ply,1,8,"you do not have the right job to fire someone")
				end
			end
		end)
	end
end)