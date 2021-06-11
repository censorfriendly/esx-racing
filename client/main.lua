ESX  = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    -- Loop forever and update every frame
    while true do
        Citizen.Wait(0)

        -- Get player and check if they're in a vehicle
	end
end)

RegisterCommand("race",function(source,args)
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "Please be careful to not step on too many snails!"}
	})


    local player = GetPlayerPed(-1)
	local checkpointType = 31
	checkpoint = {}
	checkpoint.blip = AddBlipForCoord(-226.17, -1005.55, 29.34)
    checkpoint.checkpoint = CreateCheckpoint(checkpointType, -226.17,  -1005.55, 29.34, 2, 2, 2, 25, 255, 255, 0, 127, 0)
    SetCheckpointCylinderHeight(checkpoint.checkpoint,25.0, 10.0, 25.0)
	SetBlipRoute(checkpoint.blip, true)
	TriggerEvent('chat:addMessage', {
	  color = { 255, 0, 0},
	  multiline = true,
	  args = {"Me", "Please be careful to not step on too many snails!"}
	})
end)
