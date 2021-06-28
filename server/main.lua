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

RegisterServerEvent('racing:finishedStats')
AddEventHandler('racing:finishedStats', function(stats)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    local raceId = stats.raceId
    for y = 1, #activeRaces[raceId] do
        if activeRaces[raceId][y].identifier == identifier then 
            activeRaces[raceId][y].finished = true
            activeRaces[raceId][y].best_lap = stats.bestLap
            activeRaces[raceId][y].total_time = stats.trackTime
            break
        end
    end
    TriggerClientEvent('chatMessage', source, "", {0,0,0}, 'Finished Race ')
    checkFinished()
end)

RegisterServerEvent('racing:quit')
AddEventHandler('racing:quit', function()
    xPlayer = ESX.GetPlayerFromId(source)
    identifier = xPlayer.getIdentifier()
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
                    local xPlayer = ESX.GetPlayerFromIdentifier(pendingRaces[x][y].identifier)
                    xPlayer.triggerEvent('racing:quitRace')
                    xPlayer.triggerEvent('esx:showNotification', 'Race Cancelled')
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
AddEventHandler('racing:join', function(raceId,setOwner,laps)
    local xPlayer = ESX.GetPlayerFromId(source)
    local usource = source
    identifier = xPlayer.getIdentifier()
    -- local raceAlreadySet = checkIfInTable(pendingRaces,'race', raceId)
    if setOwner and pendingRaces[raceId] == nil then
        -- Create a new entry for the race (only 1 of each race can be created)
        rconf = {
            id = raceId,
            name = Races[raceId].Config.Name,
            type = Races[raceId].Config.Type,
            laps = tonumber(laps),
            started = false,
            owner = identifier,
        }
        raceConfigs[raceId] = rconf

        pendingRaces[raceId] = {}
        local inObj = {
            identifier = identifier,
            player_name = xPlayer.getName(),
        }
        table.insert(pendingRaces[raceId], inObj)
        alertPlayers(rconf)
    else
        local inObj = {
            identifier = identifier,
            player_name = xPlayer.getName()
        }
        table.insert(pendingRaces[raceId], inObj)
    end
end)

RegisterServerEvent('racing:start')
AddEventHandler('racing:start', function(raceId)
    local raceCopy = pendingRaces[raceId]
    activeRaces[raceId] = {}
    for i = 1, #raceCopy do 
        local inObj = {
            last_checkpoint_time = '',
            identifier = raceCopy[i].identifier,
            player_name = raceCopy[i].player_name,
            lap = 1,
            checkpoint = 1,
            position = 1,
            best_lap = '',
            total_time = '',
            finished = false,
        }
        table.insert(activeRaces[raceId], inObj)
        local xPlayer = ESX.GetPlayerFromIdentifier(raceCopy[i].identifier)
        raceConfigs[raceId].racerCount = #raceCopy
        xPlayer.triggerEvent('racing:startClient',raceConfigs[raceId])
    end
    pendingRaces[raceId] = nil
    raceConfigs[raceId].started = true
end)

RegisterServerEvent('racing:checkpoint')
AddEventHandler('racing:checkpoint', function(race_id, checkpoint, lap)
    local xPlayer = ESX.GetPlayerFromId(source)
    _identifier = xPlayer.getIdentifier()
    local ppid = 1
    for i = 1, #activeRaces[race_id] do
        if activeRaces[race_id][i].identifier == _identifier then 
            ppdid = i
            activeRaces[race_id][i].checkpoint = tonumber(checkpoint)
            activeRaces[race_id][i].lap = tonumber(lap)
            activeRaces[race_id][i].last_checkpoint_time = GetGameTimer()
        end
    end
    local pos = 1
    for i = 1, #activeRaces[race_id] do
        if i ~= ppid and activeRaces[race_id][i].checkpoint >= checkpoint and activeRaces[race_id][i].lap >= lap  then 
            pos = pos + 1
        end
    end
    activeRaces[race_id][ppid].position = pos
    xPlayer.triggerEvent('racing:updatePos',pos)
end)

RegisterServerEvent('racing:pendingList')
AddEventHandler('racing:pendingList', function()
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
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
    MySQL.Async.fetchAll('SELECT * FROM racing_tracktimes WHERE track_id = @trackId Order By track_id Desc, best_lap Desc Limit 10', {['@trackId'] = race_id}, function(results)
        if #results > 0 then 
            TriggerClientEvent('racing:sendLeaderboards', usource, results)
        end
    end)
end)

RegisterServerEvent('racing:alertSignup')
AddEventHandler('racing:alertSignup', function(signUpFlag)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
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

function alertPlayers(raceConf)
    for x = 1, #alertSignups do
        local xPlayer = ESX.GetPlayerFromIdentifier(alertSignups[x].identifier)
        xPlayer.triggerEvent('esx:showNotification', 'Race Alert: ' .. raceConf.name .. ' No. Laps ' .. raceConf.laps)
    end
end



RegisterServerEvent('racing:getCrypto')
AddEventHandler('racing:getCrypto', function(signUpFlag)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    local usource = source
    MySQL.Async.fetchAll('Select * from users WHERE identifier = @identifier', {['@identifier'] = identifier}, function(result)
        TriggerClientEvent('racing:setCrypto', usource, result[1].racecrypto)
    end)
end)



-- Thread to manage as races finish to translate into Archived format, and to auto DNF after designated time frame
CreateThread(function()
	while true do
		Wait(300000)
        checkFinished()
        checkDNFs()
	end
end)

function checkDNFs()
    for x,v in pairs(activeRaces) do 
        if activeRaces[x] ~= nil then
            for y = 1, #activeRaces[x] do 
                if activeRaces[x][y].finished == false and not isempty(activeRaces[x][y].last_checkpoint_time) and tonumber(activeRaces[x][y].last_checkpoint_time) < GetGameTimer() - 60000  then 
                    activeRaces[x][y].finished = true
                    activeRaces[x][y].best_lap = "DNF"
                    activeRaces[x][y].total_time = "DNF"
                    local xPlayer = ESX.GetPlayerFromIdentifier(activeRaces[x][y].identifier)
                    xPlayer.triggerEvent('racing:dnfIssued')
                end
            end
        end
    end
end

function checkFinished()
    for x,v in pairs(activeRaces) do 
        if activeRaces[x] ~= nil then
            local raceended = true
            for y = 1, #activeRaces[x] do 
                if activeRaces[x][y].finished == false then 
                    raceended = false
                    break;
                end
            end
            if raceended then 
                archiveRace(x)
            end
        end
    end
    -- print('need to check finished status of race')
end

function archiveRace(race_id)
    for y = 1, #activeRaces[race_id] do
        local identifier = activeRaces[race_id][y].identifier
        local bestLap = activeRaces[race_id][y].best_lap
        local playerName = activeRaces[race_id][y].player_name 
        MySQL.Async.fetchAll('Select * from racing_tracktimes WHERE identifier = @identifier AND track_id = @track_id', {['@identifier'] = identifier, ['@track_id'] = race_id}, function(lookups)
            if #lookups > 0 then
                -- Update if the laptime is better
                if isempty(lookups[1].best_lap) or lookups[1].best_lap == 'DNF' or (bestLap ~= 'DNF' and TimeStamp(bestLap) < TimeStamp(lookups[1].best_lap)) then
                    MySQL.Async.execute('UPDATE racing_tracktimes SET `best_lap` = @best_lap WHERE identifier = @identifier AND track_id = @track_id',
                    {
                        ['@best_lap'] = bestLap,
                        ['@identifier'] = identifier,
                        ['@track_id'] = race_id
                    })
                end
            else    
                -- First time racing store data
                MySQL.Async.execute('INSERT INTO `racing_tracktimes` (`identifier`, `player_name`, `track_id`, `best_lap`) VALUES (@identifier, @player_name, @track_id, @best_lap)', {
                    ['@identifier'] = identifier,
                    ['@player_name'] = playerName,
                    ['@track_id'] = race_id,
                    ['@best_lap'] = bestLap
                })
            end
        end)
    end
    table.insert(archiveRaces,activeRaces[race_id])
    table.insert(archiveConfigs,raceConfigs[race_id])
    if RacingConfig.crypto and #archiveRaces[#archiveRaces] >= RacingConfig.cryptoMin then 
        distributeCrypto(#archiveRaces)
    end
    raceConfigs[race_id] = nil
    activeRaces[race_id] = nil
end

function distributeCrypto(i)
    local distributed = {}
    for x = 1, 3 do
        local place = nil
        local lowestTime = nil
        for y = 1, #archiveRaces[i] do 
            if (isempty(lowestTime) or (archiveRaces[i][y].total_time ~='DNF' and TimeStamp(archiveRaces[i][y].total_time) < lowestTime)) and setNotContains(distributed,archiveRaces[i][y].identifier) then 
                place = y
                lowestTime = TimeStamp(archiveRaces[i][y].total_time)
            end
        end
        if not isempty(place) then
            table.insert(distributed,{identifier = archiveRaces[i][place].identifier, crypto = (tonumber(RacingConfig.cryptoPayout) / x)})
        end
    end
    if #distributed == 3 then 
        for y = 1, #archiveRaces[i] do
            if setNotContains(distributed,archiveRaces[i][y].identifier) then
                table.insert(distributed,{identifier = archiveRaces[i][y].identifier, crypto = (tonumber(RacingConfig.cryptoPayout) / 3) -1})
            end
        end
        for x = 1, #distributed do
            MySQL.Async.execute('UPDATE users SET `racecrypto` =  racecrypto + @crypto WHERE identifier = @identifier',
                {
                    ['@identifier'] = distributed[x].identifier,
                    ['@crypto'] = distributed[x].crypto
                })
        end
    end
end

function setNotContains(table,value)
    for x = 1, #table do
        if value == table[x].identifier then
            return false
        end
    end
    return true
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


--  Functions Script

-- Stores correct Character in leaderboards to avoid cross issues
function getProperIdentity(identity, cb)
    -- if RacingConfig.kashacters then 
    --     -- local lastChar = MySQL.Sync.fetchAll("SELECT * FROM `user_lastcharacter` WHERE `license` = @identity", {['@identity'] = identity})
    --     -- charNum = tonumber(lastChar[1].charid)
    --     identity = GetIdentifierWithoutLicense(identity)
    --     cb(identity)
    -- else
        cb(identity)
    -- end
end

function removeKey(table, key)
    table[key] = nil
end

function GetIdentifierWithoutLicense(Identifier)
    return string.gsub(Identifier, "license", "")
end

function getServerIdentifier(Identifier)
    a, b = string.match(Identifier, "(.*):(.*)")
    return "license:" .. b
end

function TimeStamp(dateStringArg)
	
	local inYear, inMonth, inDay, inHour, inMinute, inSecond, inZone =      
  string.match(dateStringArg, '^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)(.-)$')

	local zHours, zMinutes = string.match(inZone, '^(.-):(%d%d)$')
		
	local returnTime = os.time({year=inYear, month=inMonth, day=inDay, hour=inHour, min=inMinute, sec=inSecond, isdst=false})
	
	if zHours then
		returnTime = returnTime - ((tonumber(zHours)*3600) + (tonumber(zMinutes)*60))
	end
	
	return returnTime
	
end


function MySQLAsyncExecute(query)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll(query, {}, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

function isempty(s)
    return s == nil or s == ''
end