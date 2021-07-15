ESX  = nil
checkPos = 1
checkpoint = {}
raceStarted = false
raceLap = 1
finishLine = true
activeRace = {}
startPoint = nil
raceId = 1
finished = false
lastLap = nil
raceConfig = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
CreateThread(function()
	while true do
		-- draw every frame
		Wait(0)
		if raceStarted then
			local coords = activeRace.Markers[checkPos]
			DrawMarker(2, coords.x, coords.y, coords.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(100)
		if raceStarted then
			local player = GetPlayerPed(-1)
			local coords = activeRace.Markers[checkPos]
			local position = GetEntityCoords(player)
			if GetDistanceBetweenCoords(position.x, position.y, position.z, coords.x, coords.y, coords.z, 0 , false) < 25.0 then
				-- Passed the checkpoint, delete map blip and checkpoint
				RemoveBlip(checkpoint[checkPos])
				checkPointEvent()
				if checkPos == 1 and raceLap > 1 then
					lapEvent()
				end
				checkPos = checkPos + 1
				if raceLap <= raceConfig.laps and not finished  then
					if activeRace.Markers[checkPos] == nil  then
						checkPos = 1
						if raceLap < raceConfig.laps then 
							raceLap = raceLap + 1
						else
							finished = true
						end
					end
					if activeRace.Config.Type == 'Sprint' and checkPos == #checkpoint then
						finished = true
					end
					SetBlipRoute(checkpoint[checkPos], true)
					SetBlipRouteColour(checkpoint[checkPos],2)
					
					if activeRace.Markers[checkPos + 2] ~= nil and not finishLine then
						checkpoint[checkPos + 2] = AddBlipForCoord(activeRace.Markers[checkPos + 2].x, activeRace.Markers[checkPos + 2].y, activeRace.Markers[checkPos + 2].z)
						ShowNumberOnBlip(checkpoint[checkPos + 2], checkPos + 2)
					elseif raceConfig.laps > raceLap and not finishLine then
						local pos = (checkPos + 2) - #checkpoint
						checkpoint[pos] = AddBlipForCoord(activeRace.Markers[pos].x, activeRace.Markers[pos].y, activeRace.Markers[pos].z)
						ShowNumberOnBlip(checkpoint[pos], pos)
					else 
						if activeRace.Config.Type == 'Sprint' then
							finishLine = true
						end
						if not finishLine then
							checkpoint[1] = AddBlipForCoord(activeRace.Markers[1].x, activeRace.Markers[1].y, activeRace.Markers[1].z)
							ShowNumberOnBlip(checkpoint[1], 1)
							finishLine = true
						end
					end
				else
					finishRace()
				end
			end
		end
	end
end)

-- RegisterCommand("race",function(source,args)
--     -- local player = GetPlayerPed(-1)
-- 	local checkpointType = 31
-- 	RemoveBlip(startPoint)
-- 	checkPos = 1
-- 	raceLap = 1
-- 	finishLine = false
-- 	TriggerServerEvent('racing:start',raceId)
-- end)

RegisterCommand("raceApp",function(source,args)
    local playerPed = PlayerPedId()
	SetNuiFocus(true,true)
	SetPedUsingActionMode(playerPed, -1, -1, 1)
	SendNUIMessage({
		raceApp = true
	})
end)

function startRace(race_Id)
	raceId = race_Id
	activeRace = Races[raceId]
	local checkpointType = 31
	if(startPoint) then 
		RemoveBlip(startPoint)
	end
	checkpoint[1] = AddBlipForCoord(activeRace.Markers[1].x, activeRace.Markers[1].y, activeRace.Markers[1].z)
	ShowNumberOnBlip(checkpoint[1], 1)
	checkPos = 1
	raceLap = 1
	finishLine = false
	SetNuiFocus(false,false)
	SendNUIMessage({
		openRacing = true,
		closeApp = true,
		setRaceConfig = true,
		raceConfig = {
			laps = raceConfig.laps,
			totalChecks = #activeRace.Markers,
			racerCount = raceConfig.racerCount
		}
	})
	ESX.ShowNotification("Race Countdown in 10 Seconds", true, false, '120')
	Wait(5000)
	ESX.ShowNotification("Race Countdown in 5 Seconds", true, false, '120')
	Wait(5000)
	SendNUIMessage({
		countdown = true
	})
	Wait(3000)
	raceStarted = true
	
	RemoveBlip(checkpoint[1])
	for i=checkPos, checkPos + 2 do 
		checkpoint[i] = AddBlipForCoord(activeRace.Markers[i].x, activeRace.Markers[i].y, activeRace.Markers[i].z)
		ShowNumberOnBlip(checkpoint[i], i)
	end
	SetBlipRoute(checkpoint[checkPos], true)
	SetBlipRouteColour(checkpoint[checkPos],2)
	SendNUIMessage({
		startrace = true
	})
end

function finishRace()
	SendNUIMessage({
		endRace = true
	})
	-- Need to get a callback from ui to tell us race details
	resetFlags()
end

function resetFlags()
	checkPos = 1
	checkpoint = {}
	raceStarted = false
	finishLine = false
	raceLap = 1
	activeRace = {}
	lastLap = nil
	finished = false
	raceConfig = nil
end

function checkPointEvent()
	TriggerServerEvent('racing:checkpoint',raceId, checkPos, raceLap)
	SendNUIMessage({
		checkPoint = true
	})
end

function lapEvent()
	SendNUIMessage({
		lapEvent = true
	})
end

RegisterNetEvent("racing:finishClient")
AddEventHandler("racing:finishClient", function()

end)
RegisterNetEvent("racing:startClient")
AddEventHandler("racing:startClient", function(raceConf)
	raceConfig = raceConf
	startRace(raceConfig.id)
end)

RegisterNetEvent("racing:raceInfo")
AddEventHandler("racing:raceInfo", function(raceInfo)
	SendNUIMessage({
		raceInfo = true,
		info = raceInfo
	})
end)


RegisterNetEvent("racing:updatePos")
AddEventHandler("racing:updatePos", function(positionTable)
	data = ESX.GetPlayerData()
    table.sort(positionTable, function(a,b)
		if a.checkpoint ~= b.checkpoint then
            return a.checkpoint > b.checkpoint
        end
        return a.last_checkpoint_time < b.last_checkpoint_time
    end)
	
    local pos = 0
    for i = 1, #positionTable do
        if positionTable[i].identifier == data.identifier then 
            pos = i
            break;
        end
    end
	SendNUIMessage({
		positionUpdate = true,
		position = pos
	})
end)

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

function DecimalsToMinutes(dec)
	local ms = tonumber(dec)
	ms = ms/1000
	return math.floor(ms / 100)..":"..(ms % 100)
end


function GetIdentifierWithoutLicense(Identifier)
    return string.gsub(Identifier, "license", "")
end


-- Race App Code beneath
-- Globals

RegisterNUICallback('closeApp', function(params,cb)
	SetNuiFocus(false,false)
	SendNUIMessage({
		closeApp = true
	})
	cb('ok');
end)
RegisterNUICallback('quitRace', function(params,cb)
	TriggerServerEvent('racing:quit')
	cb('ok');
end)

RegisterNUICallback('raceDetails', function(params,cb)
	TriggerServerEvent('racing:raceDetails', params.raceId)
	cb('ok');
end)

RegisterNUICallback('getCrypto', function(params,cb)
	TriggerServerEvent('racing:getCrypto')
	cb('ok');
end)

RegisterNetEvent("racing:setCrypto")
AddEventHandler("racing:setCrypto", function(crypto)
	SendNUIMessage({
		cryptoEvent = true,
		crypto = crypto
	})
end)

-- Track Screen
RegisterNUICallback('getTracks', function(params,cb)
	SendNUIMessage({
		trackListEvent = true,
		tracks = Races
	})
	cb('ok');
end)
RegisterNUICallback('alertSignup', function(params,cb)
	TriggerServerEvent('racing:alertSignup',params.signup)
	cb('ok');
end)

RegisterNUICallback('getPendingRaces', function(data,cb)
	TriggerServerEvent('racing:pendingList')
	cb('ok');
end)

RegisterNUICallback('initApp', function(data,cb)
	local data = ESX.GetPlayerData()
	
	SendNUIMessage({
		initApp = true,
		identifier = data.identifier
	})

	SendNUIMessage({
		trackListEvent = true,
		tracks = Races
	})
	
	TriggerServerEvent('racing:pendingList')
	cb('ok');
end)

RegisterNUICallback('createRace', function(params,cb)
	raceId = params.raceId
	activeRace = Races[raceId]
	TriggerServerEvent('racing:join',raceId, true, params.laps)
	cb('ok');

end)


RegisterNUICallback('raceStats', function(params,cb)
	TriggerServerEvent('racing:finishedStats',params)
	cb('ok');

end)

RegisterNUICallback('getLeaderboards', function(params,cb)
	TriggerServerEvent('racing:getLeaderboards',params.race_id)
	cb('ok');
end)

-- Pending Race Screen



RegisterNetEvent('racing:sendLeaderboards')
AddEventHandler('racing:sendLeaderboards', function(leaderboard)
	SendNUIMessage({
		leaderboardEvent = true,
		list = leaderboard
	})
end)
RegisterNetEvent("racing:racingList")
AddEventHandler("racing:racingList", function(raceList)
	SendNUIMessage({
		racingListEvent = true,
		list = raceList
	})
end)

RegisterNetEvent('racing:dnfIssued')
AddEventHandler('racing:dnfIssued', function()
	ESX.ShowNotification("You have been disqualified from the race", true, false, '120')
	RemoveBlip(checkpoint[checkPos])
	checkPos = checkPos + 1
	RemoveBlip(checkpoint[checkPos])
	checkPos = checkPos + 1
	RemoveBlip(checkpoint[checkPos])
	resetFlags()
	SendNUIMessage({
		dnf = true
	})
end)

RegisterNUICallback('mapToRace', function(params, cb)
    local player = GetPlayerPed(-1)
	activeRace = Races[tonumber(params.raceId)]
	startPoint = AddBlipForCoord(activeRace.Markers[1].x, activeRace.Markers[1].y, activeRace.Markers[1].z)
	SetBlipRoute(startPoint, true)
	SetBlipRouteColour(startPoint,2)
	cb('ok');
end)


RegisterNUICallback('joinRace', function(params, cb)
	TriggerServerEvent('racing:join',params.raceId)
		raceId = params.raceId
		activeRace = Races[raceId]
	cb('ok');
end)

RegisterNUICallback('startRace', function(params, cb)
	TriggerServerEvent('racing:start',params.raceId)
	cb('ok');
end)


RegisterNUICallback('getArchivedList', function(params, cb)
	TriggerServerEvent('racing:finishedRacesList')
	cb('ok');
end)

-- Error handling function


RegisterNetEvent("racing:racingerror")
AddEventHandler("racing:racingerror", function(Cerror)
	local code = Cerror.code
	SendNUIMessage({
		error = true,
		message = Cerror.message
	})
	SendNUIMessage({
		joinError = true
	})
end)


-- Home Screen Post Race

RegisterNetEvent("racing:archivedList")
AddEventHandler("racing:archivedList", function(raceInfo, racerInfo)
	SendNUIMessage({
		raceData = true,
		raceInfo = raceInfo,
		racers = racerInfo
	})
end)

-- Racing Screen

-- RegisterNUICallback('setBestLap', function(params, cb)
-- 	TriggerServerEvent('racing:setBestLap',params.raceId, params.bestLap)
-- 	cb('ok');
-- end)