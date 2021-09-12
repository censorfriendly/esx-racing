ESX = nil

activeRaces = {}
pendingRaces = {}
archiveRaces = {}
raceConfigs = {}
archiveConfigs = {}
alertSignups = {}

-- pendingRaces[1] = {}
-- raceConfigs = { [1] = { ["laps"] = 1,["started"] = false,["id"] = 1,["name"] = 'Test Track',["type"] = 'Circuit',["owner"] = 'license:fb4534551c7d686f36d903c66de8531e8d1db82c',} ,}
-- archiveRaces = { [1] = { [1] = { ["best_lap"] = '1970-01-01T00:00:33.423Z',["position"] = 1,["checkpoint"] = 1,["identifier"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',["race_key"] = '',["lap"] = 2,["finished"] = true,["total_time"] = '1970-01-01T00:01:14.459Z',["player_name"] = 'Test Racer',} , [2] = { ["best_lap"] = '1970-01-01T00:00:33.423Z',["position"] = 1,["checkpoint"] = 1,["identifier"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',["race_key"] = '',["lap"] = 2,["finished"] = true,["total_time"] = '1970-01-01T00:01:18.459Z',["player_name"] = 'Test Racer',} ,} ,[2] = { [1] = { ["best_lap"] = '1970-01-01T00:00:25.270Z',["position"] = 1,["checkpoint"] = 1,["identifier"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',["race_key"] = '',["lap"] = 3,["finished"] = true,["total_time"] = '1970-01-01T00:01:28.072Z',["player_name"] = 'Test Racer',} ,} ,}
-- archiveConfigs = { [1] = { ["laps"] = 1,["name"] = 'Test Track',["type"] = 'Circuit',["started"] = true,["racerCount"] = 1,["id"] = 1,["owner"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',} ,[2] = { ["laps"] = 1,["name"] = 'Test Track2',["type"] = 'Circuit',["started"] = true,["racerCount"] = 1,["id"] = 1,["owner"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',}}
-- table.insert(raceConfigs, { 
--     id = 1,
--     name = 'Test Track',
--     type = 'Sprint',
--     laps = 2,
--     started = false,
--     owner = ':fbe32bb51c7d686f36d903c66de8531e8d1db82c'
-- })
-- pendingRaces[1] = {}
-- table.insert(pendingRaces[1], { 
--     player_name = 'fake racer',
--     identifier = ':fbe32bb51c7d686f36d903c66de8531e8d1db82c'
-- })
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('racetablet', function(source)
    TriggerClientEvent('racing:openApp', source)
end)

RegisterServerEvent('racing:finishedStats')
AddEventHandler('racing:finishedStats', function(stats)
    identifier = source
    local raceId = stats.raceId
    for y = 1, #activeRaces[raceId] do
        if activeRaces[raceId][y].identifier == identifier then 
            activeRaces[raceId][y].finished = true
            activeRaces[raceId][y].best_lap = stats.bestLap
            activeRaces[raceId][y].total_time = stats.trackTime
            break
        end
    end
    TriggerClientEvent('esx:showNotification', source, 'Finished Race ')
    checkFinished()
end)

RegisterServerEvent('racing:quit')
AddEventHandler('racing:quit', function()
    xPlayer = ESX.GetPlayerFromId(source)
    identifier = source
    local ident = identifier
    local quitRace = false
    -- Check pending race

    for x,v in pairs(pendingRaces) do 
        if pendingRaces[x] ~= nil then
            for y = 1, #pendingRaces[x] do
                if pendingRaces[x][y].identifier == ident then 
                    table.remove(pendingRaces[x],y)
                    quitRace = true
                    break
                end
            end
        end
        if raceConfigs[x] ~= nil then
            if raceConfigs[x].owner == ident then 
                raceConfigs[x] = nil
                for y = 1, #pendingRaces[x] do
                    local xPlayer = ESX.GetPlayerFromId(pendingRaces[x][y].identifier)
                    TriggerClientEvent('racing:quitRace',pendingRaces[x][y].identifier)
                    TriggerClientEvent('esx:showNotification',pendingRaces[x][y].identifier, 'Race Cancelled')
                end
                pendingRaces[x] = nil
                quitRace = true
            end
        end
        if quitRace then 
            break
        end
    end

    -- Check active race
    if quitRace == false then 
        for x,v in pairs(activeRaces) do 
            if activeRaces[x] ~= nil then
                for y = 1, #activeRaces[x] do
                    if activeRaces[x][y].identifier == ident then 
                        activeRaces[x][y].finished = true
                        activeRaces[x][y].total_time = "DNF"
                        activeRaces[x][y].best_lap = "DNF"
                        quitRace = true
                        break
                    end
                end
            end
            if quitRace then 
                break
            end
        end
    end
    if quitRace then 
        TriggerClientEvent('esx:showNotification', source, "", {0,0,0}, 'Quit Race')
        TriggerClientEvent('racing:quitRace',source)
    end
end)

RegisterServerEvent('racing:join')
AddEventHandler('racing:join', function(raceId,setOwner,configuration)
    local xPlayer = ESX.GetPlayerFromId(source)
    local usource = source
    sId = source
    steamidentifier = xPlayer.getIdentifier()
    local XplayerName = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier',  {
        ['@identifier'] = steamidentifier
    })
    -- local raceAlreadySet = checkIfInTable(pendingRaces,'race', raceId)
    local inObj = {
        identifier = sId,
        steamidentifier = steamidentifier,
        player_name = XplayerName[1]['firstname'] .. ' ' .. XplayerName[1]['lastname']
    }
    if setOwner and pendingRaces[raceId] == nil then
        -- Create a new entry for the race (only 1 of each race can be created)
        rconf = {
            id = raceId,
            name = Races[raceId].Config.Name,
            type = Races[raceId].Config.Type,
            laps = tonumber(configuration.laps),
            title = configuration.title,
            started = false,
            owner = sId,
        }
        
        raceConfigs[raceId] = rconf
        pendingRaces[raceId] = {}
        alertPlayers(rconf)
    end
    table.insert(pendingRaces[raceId], inObj)
    TriggerClientEvent('racing:raceInfo',usource, pendingRaces[raceId])
end)

RegisterServerEvent('racing:start')
AddEventHandler('racing:start', function(raceId,postal,street)
    local raceCopy = pendingRaces[raceId]
    activeRaces[raceId] = {}
    for i = 1, #raceCopy do 
        local inObj = {
            last_checkpoint_time = '',
            identifier = raceCopy[i].identifier,
            steamidentifier = raceCopy[i].steamidentifier,
            player_name = raceCopy[i].player_name,
            lap = 1,
            checkpoint = 1,
            position = 1,
            best_lap = '',
            total_time = '',
            finished = false,
        }
        table.insert(activeRaces[raceId], inObj)
        raceConfigs[raceId].racerCount = #raceCopy
        TriggerClientEvent('racing:startClient',raceCopy[i].identifier, raceConfigs[raceId])
    end
    pendingRaces[raceId] = nil
    raceConfigs[raceId].started = true
    triggerPoliceNotification(postal,street)
end)

RegisterServerEvent('racing:checkpoint')
AddEventHandler('racing:checkpoint', function(race_id, checkpoint, lap)
    _identifier = source
    for i = 1, #activeRaces[race_id] do
        if activeRaces[race_id][i].identifier == _identifier then 
            activeRaces[race_id][i].checkpoint = tonumber(activeRaces[race_id][i].checkpoint) + 1;
            activeRaces[race_id][i].last_checkpoint_time = GetGameTimer()
            break;
        end
    end
    TriggerClientEvent('racing:updatePos',source,activeRaces[race_id])
end)

RegisterServerEvent('racing:pendingList')
AddEventHandler('racing:pendingList', function()
    identifier = source
    local usource = source
    local unstartedRaces = {}
    for k, v in pairs(raceConfigs) do 
        if raceConfigs[k].started == false then
           table.insert(unstartedRaces,raceConfigs[k]) 
        end
    end
    TriggerClientEvent('racing:racingList', usource, unstartedRaces)
end)

RegisterServerEvent('racing:finishedRacesList')
AddEventHandler('racing:finishedRacesList', function()
    local usource = source
    TriggerClientEvent('racing:archivedList', usource, archiveConfigs, archiveRaces)
end)

RegisterServerEvent('racing:getLeaderboards')
AddEventHandler('racing:getLeaderboards', function(race_id)
    local usource = source
    MySQL.Async.fetchAll('SELECT * FROM racing_tracktimes WHERE track_id = @trackId Order By track_id Desc, best_lap ASC Limit 10', {['@trackId'] = race_id}, function(results)
        if #results > 0 then 
            TriggerClientEvent('racing:sendLeaderboards', usource, results)
        end
    end)
end)

RegisterServerEvent('racing:alertSignup')
AddEventHandler('racing:alertSignup', function(signUpFlag)
    identifier = source
    local usource = source
    local alreadySignedUp = false;
    local pindex = 0
    for x = 1, #alertSignups do
        if alertSignups[x].identifier == identifier then 
            alreadySignedUp = true;
            pindex = x
            break
        end
    end
    if signUpFlag then
        if alreadySignedUp == false then 
            table.insert(alertSignups, {identifier = identifier})
        end
    else
        table.remove(alertSignups, pindex)
    end
end)

RegisterServerEvent('racing:raceDetails')
AddEventHandler('racing:raceDetails', function(raceId)
    
    TriggerClientEvent('racing:raceInfo', source, pendingRaces[raceId])
end)

RegisterServerEvent('racing:getCrypto')
AddEventHandler('racing:getCrypto', function(signUpFlag)
    -- identifier = source
    -- local usource = source
    -- MySQL.Async.fetchAll('Select * from users WHERE identifier = @identifier', {['@identifier'] = identifier}, function(result)
    --     TriggerClientEvent('racing:setCrypto', usource, result[1].racecrypto)
    -- end)
end)

RegisterServerEvent('racing:sendMessageToRacers')
AddEventHandler('racing:sendMessageToRacers', function(params)
    local rid = params.raceId
    local message = params.message
    for i = 1, #pendingRaces[rid] do 
        TriggerClientEvent('esx:showNotification',pendingRaces[rid][i].identifier, 'Race Message: ' .. message)
    end
end)

-- Thread to manage as races finish to translate into Archived format, and to auto DNF after designated time frame
CreateThread(function()
	while true do
		Wait(300000)
        checkFinished()
        checkDNFs()
	end
end)