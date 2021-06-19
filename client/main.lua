ESX  = nil
checkPos = 1
checkpoint = {}
raceStarted = false
raceLap = 1
finishLine = true
activeRace = {}
startPoint = nil
timeTracking = {}
raceId = 1
startTime = 0
finished = false
lastLap = nil
lapTime = nil
guiEnabled = false

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
				if raceLap <= activeRace.Config.Laps and not finished  then
					if activeRace.Markers[checkPos] == nil  then
						checkPos = 1
						if raceLap < activeRace.Config.Laps then 
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
					elseif activeRace.Config.Laps > raceLap and not finishLine then
						local pos = (checkPos + 2) - #checkpoint
						checkpoint[pos] = AddBlipForCoord(activeRace.Markers[pos].x, activeRace.Markers[pos].y, activeRace.Markers[pos].z)
					else 
						if activeRace.Config.Type == 'Sprint' then
							finishLine = true
						end
						if not finishLine then
							checkpoint[1] = AddBlipForCoord(activeRace.Markers[1].x, activeRace.Markers[1].y, activeRace.Markers[1].z)
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

RegisterCommand("race",function(source,args)
    -- local player = GetPlayerPed(-1)
	local checkpointType = 31
	RemoveBlip(startPoint)
	checkPos = 1
	raceLap = 1
	finishLine = false
	TriggerServerEvent('racing:start',raceId)
end)

RegisterCommand("raceQuit",function(source)
	TriggerServerEvent('racing:quit')
end)

-- RegisterCommand("joinRace",function(source,args)
-- 	TriggerServerEvent('racing:join',raceId)
-- end)

-- RegisterCommand("setrace",function(source,args)
--     local player = GetPlayerPed(-1)
-- 	activeRace = Races[raceId]
-- 	startPoint = AddBlipForCoord(activeRace.Markers[1].x, activeRace.Markers[1].y, activeRace.Markers[1].z)
-- 	SetBlipRoute(startPoint, true)
-- 	SetBlipRouteColour(startPoint,2)
-- end)


RegisterCommand("raceApp",function(source,args)
    local playerPed = PlayerPedId()
	SetNuiFocus(true,true)
	SetPedUsingActionMode(playerPed, -1, -1, 1)
	SendNUIMessage({
		raceApp = true
	})
end)

function startRace()
	local checkpointType = 31
	if(startPoint) then 
		RemoveBlip(startPoint)
	end
	checkPos = 1
	raceLap = 1
	finishLine = false
	SetNuiFocus(false,false)
	SendNUIMessage({
		openRacing = true,
		closeApp = true
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
	
	for i=checkPos, checkPos + 2 do 
		checkpoint[i] = AddBlipForCoord(activeRace.Markers[i].x, activeRace.Markers[i].y, activeRace.Markers[i].z)
	end
	SetBlipRoute(checkpoint[checkPos], true)
	SetBlipRouteColour(checkpoint[checkPos],2)
	startTime = GetGameTimer()
	SendNUIMessage({
		startrace = {
			laps = activeRace.Config.Laps,
			totalChecks = #activeRace.Markers
		}
	})
end

function finishRace()
	local total = GetGameTimer() - startTime
	SendNUIMessage({
		endRace = true
	})
	TriggerServerEvent('racing:finish', total, raceId)
	resetFlags()
end

function resetFlags()
	checkPos = 1
	checkpoint = {}
	raceStarted = false
	finishLine = false
	raceLap = 1
	activeRace = {}
	startTime = 0
	lastLap = nil
	finished = false
end

function checkPointEvent()
	TriggerServerEvent('racing:checkpoint', checkPos, raceLap)
	SendNUIMessage({
		checkPoint = true
	})
end

function lapEvent()
	-- local baseTime = nil
	-- if lapTime == nil then
	-- 	baseTime = startTime
	-- else
	-- 	baseTime = lapTime
	-- end
	-- lapTime = GetGameTimer()
	-- TriggerServerEvent('racing:lapevent', lapTime - baseTime)
	SendNUIMessage({
		lapEvent = true
	})
end

RegisterNetEvent("racing:finishClient")
AddEventHandler("racing:finishClient", function()

end)
RegisterNetEvent("racing:startClient")
AddEventHandler("racing:startClient", function()
	startRace()
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

RegisterNUICallback('closeApp', function()
	SetNuiFocus(false,false)
	SendNUIMessage({
		closeApp = true
	})
end)


-- RegisterNUICallback('createRace', function()
-- 	TriggerServerEvent('racing:quit')
-- end)

-- Track Screen
RegisterNUICallback('getTracks', function()
	SendNUIMessage({
		trackListEvent = true,
		tracks = Races
	})
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
	TriggerServerEvent('racing:join',raceId, true, params.laps)
	activeRace = Races[raceId]
	cb('ok');

end)

-- Pending Race Screen



RegisterNetEvent("racing:racingList")
AddEventHandler("racing:racingList", function(raceList)
	SendNUIMessage({
		racingListEvent = true,
		list = raceList
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
	cb('ok');
end)

RegisterNUICallback('startRace', function(params, cb)
	TriggerServerEvent('racing:start',params.raceId)
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

RegisterNetEvent("racing:raceData")
AddEventHandler("racing:raceData", function(raceData)
	print('sending race data');
	SendNUIMessage({
		raceData = true,
		message = raceData
	})
end)