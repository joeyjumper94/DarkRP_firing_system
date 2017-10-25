AddCSLuaFile()
if SERVER then
	concommand.Add("darkrp_fire_msg",function(ply,cmd,args)
		if args[1]==nil then DarkRP.notify(ply,1,8,"invalid arguement") return end
		if ply:IsValid() and ply:IsPlayer() and ply:isMayor() then
			for k,target in ipairs(player.GetAll()) do
				if string.lower(target:Nick()):find(args[1]) or string.lower(target:SteamName()):find(args[1]) or target:SteamID()==args[1] then
					print("target acquired")
					if target:IsValid() and target:IsPlayer() and target:isCP() and !target:getDarkRPVar("job"):find("corrupt") then
						print("firing")
						if GetConVarNumber("darkrp_fire_demotion_time")>=0 then
							local demote_timer=GetConVarNumber("darkrp_fire_demotion_time")
						elseif GAMEMODE!=nil and GAMEMODE.Config!=nil and GAMEMODE.Config.demotetime!=nil then
							local demote_timer=GAMEMODE.Config.demotetime
						else
							ply:PrintMessage(HUDPRINT_TALK,"time not set, tell the server dev")
							demote_timer=120
						end

						target:changeTeam(GAMEMODE.DefaultTeam, true)
						target:teamBan(target:Team(),time)

						for k,v in ipairs(player.GetAll()) do
							if v==target then
								DarkRP.notify(v,1,8,ply:Nick().." fired you")
							elseif v==ply then
								DarkRP.notify(v,0,8,"you fired "..target:Nick())
							elseif true then
								DarkRP.notify(v,0,8,ply:Nick().." fired "..target:Nick())
							end
						end
					elseif target:IsValid() and target:IsPlayer() then
						DarkRP.notify(ply,1,8,"you cannot fire this person")
					else
						DarkRP.notify(ply,1,8,"player does not exist")
					end
					
				end
			end
		elseif ply:IsValid() and ply:IsPlayer() then
			DarkRP.notify(ply,1,8,"you do not have the right job to fire someone")
		else
			print("you cannot fire someone from the server console")
		end
 	end,nil,"fire someone from a job")

else --client
	concommand.Add("darkrp_fire",function(ply,cmd,args) RunConsoleCommand("darkrp_fire_msg",args[1])end,nil,"fire someone from a job")

	hook.Add("OnPlayerChat","firing_chat",function(ply,text,teamChat)
		if string.StartWith(string.lower(text),"/fire ") then
			--ply:SendLua(
			RunConsoleCommand("darkrp_fire_msg",string.Split(text," ")[2])--)
			return true
		end
	end)
end
CreateConVar("darkrp_fire_demotion_time","-1",FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,"decide how long someone is demoted for when fired,set to -1 to use the time defined by darkrp")