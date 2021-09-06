


function openApp()
    local playerPed = PlayerPedId()
	cleanCheckpoint();
	SetNuiFocus(true,true)
	SetPedUsingActionMode(playerPed, -1, -1, 1)
	SendNUIMessage({
		raceApp = true
	})
end


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
	
	ClearGpsMultiRoute()

	-- Start a new route
	StartGpsMultiRoute(018, true, true)
	RemoveBlip(checkpoint[1])
	for i=checkPos, checkPos + 2 do 
		checkpoint[i] = AddBlipForCoord(activeRace.Markers[i].x, activeRace.Markers[i].y, activeRace.Markers[i].z)
		ShowNumberOnBlip(checkpoint[i], i)
		table.insert(gpsArray,activeRace.Markers[i])
		AddPointToGpsMultiRoute(activeRace.Markers[i].x, activeRace.Markers[i].y, activeRace.Markers[i].z)
	end
	table.remove(gpsArray,1)
	-- SetBlipRoute(checkpoint[checkPos], true)
	-- SetBlipRouteColour(checkpoint[checkPos],2)
	SetGpsMultiRouteRender(true)
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
	ClearGpsMultiRoute()
	if(startPoint) then 
		RemoveBlip(startPoint)
	end
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

function cleanCheckpoint()
	if not raceStarted then
		for i=1, #checkpoint do 
			RemoveBlip(checkpoint[i])
		end
	end
end
