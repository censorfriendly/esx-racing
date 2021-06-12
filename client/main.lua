ESX  = nil
checkPos = 1
checkpoint = {}
raceStarted = false
raceLap = 1
finishLine = true
activeRace = {}
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
				checkPos = checkPos + 1
				if raceLap <= activeRace.Config.Laps then
					if activeRace.Markers[checkPos] == nil  then
						checkPos = 1
						raceLap = raceLap + 1
					end
					if activeRace.Config.Type == 'Sprint' and checkPos == #checkpoint then
						raceLap = raceLap + 1
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
							args = {"Me", "adding finish line" }
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
					resetFlags()
					TriggerEvent('chat:addMessage', {
						color = { 255, 0, 0},
						multiline = true,
						args = {"Me", "End of Race"}
					})
				end
			end
		end
	end
end)

RegisterCommand("race",function(source,args)
    local player = GetPlayerPed(-1)
	local checkpointType = 31
	checkPos = 1
	raceLap = 1
	finishLine = false
	activeRace = Races[1]
	
	for i=checkPos, checkPos + 2 do 
		checkpoint[i] = AddBlipForCoord(activeRace.Markers[i].x, activeRace.Markers[i].y, activeRace.Markers[i].z)
	end
	SetBlipRoute(checkpoint[checkPos], true)
	SetBlipRouteColour(checkpoint[checkPos],2)
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "race started"}
	})
	raceStarted = true
end)

function resetFlags()
	checkPos = 1
	checkpoint = {}
	raceStarted = false
	finishLine = false
	raceLap = 1
	activeRace = {}
end
