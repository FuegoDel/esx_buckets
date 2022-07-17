

--[[ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerData = ESX.GetPlayerData()
end)]]

--In case you want to ever use it

exports('getClientSideBucket', function (player)
    return GlobalState.ESXBuckets[GetPlayerServerId(player)]
end)

exports('getIfPlayersInTheSameBucket', function (firstId,secondId)
    if GlobalState.ESXBuckets[firstId] == GlobalState.ESXBuckets[secondId] then
        return true
    end
    return false
end)

