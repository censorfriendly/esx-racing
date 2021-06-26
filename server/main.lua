ESX = nil

activeRaces = {}
pendingRaces = {}
archiveRaces = {}
-- raceConfigs = {}

pendingRaces[1] = {}
raceConfigs = { [1] = { ["laps"] = 1,["started"] = false,["id"] = 1,["name"] = 'Test Track',["type"] = 'Circuit',["owner"] = 'license:fb4534551c7d686f36d903c66de8531e8d1db82c',} ,}
archiveRaces = { [1] = { [1] = { ["best_lap"] = '1970-01-01T00:00:33.423Z',["position"] = 1,["checkpoint"] = 1,["identifier"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',["race_key"] = '',["lap"] = 2,["finished"] = true,["total_time"] = '1970-01-01T00:01:14.459Z',["player_name"] = 'Test Racer',} , [2] = { ["best_lap"] = '1970-01-01T00:00:33.423Z',["position"] = 1,["checkpoint"] = 1,["identifier"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',["race_key"] = '',["lap"] = 2,["finished"] = true,["total_time"] = '1970-01-01T00:01:18.459Z',["player_name"] = 'Test Racer',} ,} ,[2] = { [1] = { ["best_lap"] = '1970-01-01T00:00:25.270Z',["position"] = 1,["checkpoint"] = 1,["identifier"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',["race_key"] = '',["lap"] = 3,["finished"] = true,["total_time"] = '1970-01-01T00:01:28.072Z',["player_name"] = 'Test Racer',} ,} ,}
archiveConfigs = { [1] = { ["laps"] = 1,["name"] = 'Test Track',["type"] = 'Circuit',["started"] = true,["racerCount"] = 1,["id"] = 1,["owner"] = 'license:fbe32bb51c7d686f36d903c66de8531e8d1db82c',} ,}
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


RegisterServerEvent('racing:finish')
AddEventHandler('racing:finish', function(raceId)
    -- identifier = ESX.GetPlayerFromId(source).getIdentifier()
    -- -- MySQL.Async.execute('UPDATE racing_active SET `finished` = 1, `total_time` = @total_time WHERE identifier Like @identifier ',
    -- -- {
    -- --     ['@total_time'] = finishTime,
    -- --     ['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"
    -- -- })
    -- for y = 1, #activeRaces[raceId] do
    --     if activeRaces[raceId][y].identifier == identifier then 
    --         activeRaces[raceId][y].finished = true
    --         break
    --     end
    -- end
    -- TriggerClientEvent('chatMessage', source, "", {0,0,0}, 'Finished Race ')
    -- checkFinished()
    -- createLastRaceData(raceId)
end)


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
    print('looking at quitting race')

    for x = 1, #pendingRaces do 
        if pendingRaces[x] ~= nil then
            for y = 1, #pendingRaces[x] do
                if pendingRaces[x][y].identifier == ident then 
                    table.remove(pendingRaces[x],y)
                    quitRace = true
                    print('quit Pending Race')
                    break
                end
            end
        end
        if raceConfigs[x] ~= nil then
            if raceConfigs[x].owner == ident then 
                table.remove(raceConfigs, x)
                quitRace = true
                print('quit setup of Race')
            end
        end
        if quitRace then 
            break
        end
    end

    -- Check active race
    if quitRace == false then 
        for x = 1, #activeRaces do 
            if activeRaces[x] ~= nil then
                for y = 1, #activeRaces[x] do
                    if activeRaces[x][y].identifier == ident then 
                        table.remove(activeRaces[x],y)
                        quitRace = true
                        print('quit Active Race')
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
        print('send quit message')
        TriggerClientEvent('chatMessage', source, "", {0,0,0}, 'left race')
        TriggerClientEvent('racing:quitRace',source)
    end
end)

RegisterServerEvent('racing:join')
AddEventHandler('racing:join', function(raceId,setOwner,laps)
    local xPlayer = ESX.GetPlayerFromId(source)
    local usource = source
    identifier = xPlayer.getIdentifier()
    print(identifier)
    print("above is the correct identifier")
    -- local raceAlreadySet = checkIfInTable(pendingRaces,'race', raceId)
    if setOwner and pendingRaces[raceId] == nil then
        -- Create a new entry for the race (only 1 of each race can be created)
        print("we are creating a new race")
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

    else
        print("race already exists add us to it")
        local inObj = {
            identifier = identifier,
            player_name = xPlayer.getName()
        }
        table.insert(pendingRaces[raceId], inObj)
    end
    print(dump(raceConfigs))
end)

RegisterServerEvent('racing:start')
AddEventHandler('racing:start', function(raceId)
    print('we are hitting the start race server')
    local raceCopy = pendingRaces[raceId]
    activeRaces[raceId] = {}
    for i = 1, #raceCopy do 
        local inObj = {
            race_key = '',
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
        end
    end
    local pos = 1
    for i = 1, #activeRaces[race_id] do
        print(dump("checking our position"))
        print(dump(i ~= ppid))
        print(dump(i))
        if i ~= ppid and activeRaces[race_id][i].checkpoint >= checkpoint and activeRaces[race_id][i].lap >= lap  then 
            pos = pos + 1
            print(dump("checking the position we are behind someone"))
        end
    end
    activeRaces[race_id][ppid].position = pos
    xPlayer.triggerEvent('racing:updatePos',pos)
end)

-- RegisterServerEvent('racing:setBestLap')
-- AddEventHandler('racing:setBestLap', function(race_id, bestLap)
--     local _identifier = ESX.GetPlayerFromId(source).getIdentifier()
--     local newLapTime = TimeStamp(bestLap)
--     print(dump("new lap time:" .. newLapTime))
--     for i = 1, #activeRaces[race_id] do
--         if activeRaces[race_id][i].identifier == _identifier then 
--             if(activeRaces[race_id][i].best_lap ~= '') then
--                 local oldLapTime = TimeStamp(activeRaces[race_id][i].best_lap)
--                 if(newLapTime < oldLapTime) then
--                     print(dump("Better lap time set:" .. newLapTime))
--                     activeRaces[race_id][i].best_lap = bestLap;
--                 end
--             else
--                 print(dump("Old lap time set:" .. newLapTime))
--                 activeRaces[race_id][i].best_lap = bestLap;
--             end
--         end
--     end
-- end)

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
    print("we are looking at finished races")
    TriggerClientEvent('racing:archivedList', usource, archiveConfigs, archiveRaces)
end)



-- Thread to manage as races finish to translate into Archived format, and to auto DNF after designated time frame
CreateThread(function()
	while true do
		Wait(6000)
        checkFinished()
        checkDNFs()
	end
end)

function checkDNFs()
    -- MySQL.Async.fetchAll('SELECT total_time, race_key from racing_active WHERE finished = 1 and total_time != "DNF"  GROUP BY race_key', {}, function(results)
    --     if #results > 0 then
    --         for i = 1, #results do
    --             if(GetGameTimer() > results[i].race_key + results[i].total_time + 900000) then 
                    
    --                 MySQL.Async.execute('UPDATE racing_active SET `total_time` = @total_time, `finished` = @finished WHERE race_key = @race_key and finished = 0 ',
    --                 {
    --                     ['@total_time'] = 'DNF',
    --                     ['@finished'] = 1,
    --                     ['@race_key'] = results[i].race_key,
    --                 })
    --             end
    --         end
    --     end
    -- end)
    -- print('need to if DNF occured')
end

function checkFinished()
    -- MySQL.Async.fetchAll('Select race_key, MIN(finished) as finished from racing_active', {}, function(results)
    --     if #results > 0 then 
    --         for i = 1, #results do
    --             if results[i].finished == 1 then 
    --                 archiveRace(results[i].race_key)
    --             end
    --         end
    --     end
    -- end)
    local rActive = false
    for x = 1, #activeRaces do 
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
    -- MySQL.Sync.fetchAll('Select * from racing_tracktimes WHERE identifier = @identifier AND track_id = @track_id', {['@identifier'] = results[i].identifier, ['@track_id'] = results[i].race_id}, function(lookups)
    --     if #lookups > 0 then
    --         -- Update if the laptime is better
    --         print(lookups[1].best_lap)
    --         if isempty(lookups[1].best_lap) or lookups[1].best_lap == 'DNF' or tonumber(results[i].best_lap) < tonumber(lookups[1].best_lap) then
    --             MySQL.Sync.execute('UPDATE racing_tracktimes SET `best_lap` = @best_lap WHERE identifier = @identifier AND track_id = @track_id',
    --             {
    --                 ['@best_lap'] = results[i].best_lap,
    --                 ['@identifier'] = results[i].identifier,
    --                 ['@track_id'] = results[i].race_id
    --             })
    --         end
    --     else    
    --         -- First time racing store data
    --         MySQL.Sync.execute('INSERT INTO `racing_tracktimes` (`identifier`, `player_name`, `track_id`, `best_lap`) VALUES (@identifier, @player_name, @track_id, @best_lap)', {
    --             ['@identifier'] = results[i].identifier,
    --             ['@player_name'] = results[i].player_name,
    --             ['@track_id'] = results[i].race_id,
    --             ['@best_lap'] = results[i].best_lap
    --         })
    --     end
    -- end)
    table.insert(archiveRaces,activeRaces[race_id])
    table.insert(archiveConfigs,raceConfigs[race_id])
    print(dump(archiveConfigs))
    removeKey(activeRaces,race_id)
    raceConfigs[race_id] = nil
end

function cleanRace(race_key)
    Wait(2000)
    -- MySQL.Async.execute('DELETE FROM `racing_active` WHERE race_key = @race_key',{['@race_key'] = race_key})
    print('need to clean the current race')
end



-- Cleanup server start/stop

-- AddEventHandler('onResourceStart', function(resource)
-- 	if resource == GetCurrentResourceName() then
-- 		Citizen.Wait(5000)
--         MySQL.Async.execute('TRUNCATE `racing_active`',{})
--         MySQL.Async.execute('TRUNCATE `racing_pending`',{})
-- 	end
-- end)

-- AddEventHandler('onResourceStop', function(resource)
-- 	if resource == GetCurrentResourceName() then
--         MySQL.Async.execute('TRUNCATE `racing_active`',{})
--         MySQL.Async.execute('TRUNCATE `racing_pending`',{})
-- 	end
-- end)

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