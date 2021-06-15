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
						TriggerEvent('chat:addMessage', {
							color = { 255, 0, 0},
							multiline = true,
							args = {"Me", "adding finish line" .. GetGameTimer() }
						})
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
    local player = GetPlayerPed(-1)
	local checkpointType = 31
	RemoveBlip(startPoint)
	checkPos = 1
	raceLap = 1
	finishLine = false
	TriggerServerEvent('racing:start',raceId)
end)


RegisterCommand("joinRace",function(source,args)
	TriggerServerEvent('racing:join',raceId)
end)

RegisterCommand("setrace",function(source,args)
    local player = GetPlayerPed(-1)
	activeRace = Races[raceId]
	startPoint = AddBlipForCoord(activeRace.Markers[1].x, activeRace.Markers[1].y, activeRace.Markers[1].z)
	SetBlipRoute(startPoint, true)
	SetBlipRouteColour(startPoint,2)
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "path to race"}
	})
end)

function startRace()
	Wait(1000)
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "3"}
	})
	Wait(1000)
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "2"}
	})
	Wait(1000)
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "1"}
	})
	Wait(1000)
	raceStarted = true
	
	for i=checkPos, checkPos + 2 do 
		checkpoint[i] = AddBlipForCoord(activeRace.Markers[i].x, activeRace.Markers[i].y, activeRace.Markers[i].z)
	end
	SetBlipRoute(checkpoint[checkPos], true)
	SetBlipRouteColour(checkpoint[checkPos],2)
	startTime = GetGameTimer()
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "GO"}
	})
end

function finishRace()
	local total = GetGameTimer() - startTime
	TriggerEvent('chat:addMessage', {
		color = { 255, 0, 0},
		multiline = true,
		args = {"Me", 'Start Time' .. startTime}
	})
	TriggerEvent('chat:addMessage', {
		color = { 255, 0, 0},
		multiline = true,
		args = {"Me", 'End Time' .. GetGameTimer()}
	})
	TriggerServerEvent('racing:finish', total)
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
end


function lapEvent()
	local baseTime = nil
	if lapTime == nil then
		baseTime = startTime
	else
		baseTime = lapTime
	end
	lapTime = GetGameTimer()
	TriggerEvent('chat:addMessage', {
		color = { 255, 0, 0},
		multiline = true,
		args = {"Me", 'New Lap time' .. (lapTime - baseTime)}
	})
	TriggerServerEvent('racing:lapevent', lapTime - baseTime)
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
