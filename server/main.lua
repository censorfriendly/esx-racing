ESX = nil

activeRaces = {}
pendingRaces = {}
raceConfigs = {}

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
AddEventHandler('racing:finish', function(finishTime,raceId)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    MySQL.Async.execute('UPDATE racing_active SET `finished` = 1, `total_time` = @total_time WHERE identifier Like @identifier ',
    {
        ['@total_time'] = finishTime,
        ['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"
    })
    TriggerClientEvent('chatMessage', source, "", {0,0,0}, 'Finish time of ' .. finishTime)
    checkFinished()
    createLastRaceData(raceId)
end)

RegisterServerEvent('racing:quit')
AddEventHandler('racing:quit', function()
    xPlayer = ESX.GetPlayerFromId(source)
    identifier = xPlayer.getIdentifier()
    local ident = GetIdentifierWithoutLicense(identifier)
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
    end

    -- MySQL.Async.fetchAll('SELECT * from racing_pending WHERE identifier LIKE  @identifier', {['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"}, function(results)
    --     if #results > 0 then
    --         MySQL.Async.execute('DELETE from racing_pending WHERE id = @id',
    --         {
    --             ['@id'] = results[1].id
    --         })
    --         TriggerClientEvent('chatMessage', usource, "", {0,0,0}, 'left race')
    --     end
    -- end)
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
            laps = laps,
            started = false,
            owner = GetIdentifierWithoutLicense(identifier),
        }
        raceConfigs[raceId] = {}
        table.insert(raceConfigs, rconf)

        pendingRaces[raceId] = {}
        local inObj = {
            identifier = GetIdentifierWithoutLicense(identifier),
            player_name = xPlayer.getName(),
        }
        table.insert(pendingRaces[raceId], inObj)

    else
        local inObj = {
            identifier = GetIdentifierWithoutLicense(identifier),
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
        local xPlayer = ESX.GetPlayerFromIdentifier(getServerIdentifier(raceCopy[i].identifier))
        xPlayer.triggerEvent('racing:startClient',raceConfigs[raceId])
    end
    raceConfigs[raceId].started = true
end)

RegisterServerEvent('racing:checkpoint')
AddEventHandler('racing:checkpoint', function(race_id, checkpoint, lap)
    local xPlayer = ESX.GetPlayerFromId(source)
    _identifier = xPlayer.getIdentifier()
    local ppid = 1
    for i = 1, #activeRaces[race_id] do
        if activeRaces[race_id][i].identifier == GetIdentifierWithoutLicense(_identifier) then 
            ppdid = i
            activeRaces[race_id][i].checkpoint = checkpoint
            activeRaces[race_id][i].lap = lap
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

RegisterServerEvent('racing:setBestLap')
AddEventHandler('racing:setBestLap', function(race_id, bestLap)
    local _identifier = ESX.GetPlayerFromId(source).getIdentifier()
    local newLapTime = TimeStamp(bestLap)
    for i = 1, #activeRaces[race_id] do
        if activeRaces[race_id][i].identifier == GetIdentifierWithoutLicense(_identifier) then 
            if(activeRaces[race_id][i].best_lap ~= '') then
                local oldLapTime = TimeStamp(activeRaces[race_id][i].best_lap)
                if(newLapTime < oldLapTime) then
                    activeRaces[race_id][i].best_lap = bestLap;
                end
            else
                activeRaces[race_id][i].best_lap = bestLap;
            end
        end
    end
end)

RegisterServerEvent('racing:pendingList')
AddEventHandler('racing:pendingList', function()
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    local usource = source

    local unstartedRaces = {}
    for i = 1, #raceConfigs do 
        if raceConfigs[i].started == false then
           table.insert(unstartedRaces,raceConfigs[i]) 
        end
    end
    TriggerClientEvent('racing:racingList', usource, unstartedRaces)
    -- MySQL.Async.fetchAll('SELECT * FROM racing_pending WHERE owner != "NULL"', {}, function(results)
    --     TriggerClientEvent('racing:racingList', usource, results)
    -- end)
end)


function createLastRaceData(raceId) 
    print(raceId)
    MySQL.Async.fetchAll('SELECT * FROM racing_active WHERE race_id = @raceId Order By `position`', {['@raceId'] = raceId}, function(results)
        for i = 1, #results do
            local xPlayer = ESX.GetPlayerFromIdentifier(getServerIdentifier(results[i].identifier))
            xPlayer.triggerEvent('racing:raceData', results)
        end
    end)
end




-- Thread to manage as races finish to translate into Archived format, and to auto DNF after designated time frame
CreateThread(function()
	while true do
		Wait(60000)
        checkFinished()
        checkDNFs()
	end
end)

function checkDNFs()
    MySQL.Async.fetchAll('SELECT total_time, race_key from racing_active WHERE finished = 1 and total_time != "DNF"  GROUP BY race_key', {}, function(results)
        if #results > 0 then
            for i = 1, #results do
                if(GetGameTimer() > results[i].race_key + results[i].total_time + 900000) then 
                    
                    MySQL.Async.execute('UPDATE racing_active SET `total_time` = @total_time, `finished` = @finished WHERE race_key = @race_key and finished = 0 ',
                    {
                        ['@total_time'] = 'DNF',
                        ['@finished'] = 1,
                        ['@race_key'] = results[i].race_key,
                    })
                end
            end
        end
    end)
end

function checkFinished()
    MySQL.Async.fetchAll('Select race_key, MIN(finished) as finished from racing_active', {}, function(results)
        if #results > 0 then 
            for i = 1, #results do
                if results[i].finished == 1 then 
                    archiveRace(results[i].race_key)
                end
            end
        end
    end)
end

function archiveRace(race_key)
    MySQL.Async.fetchAll('Select * from racing_active WHERE race_key = @race_key', {['@race_key'] = race_key}, function(results)
        if #results > 0 then 
            for i = 1, #results do
                MySQL.Async.fetchAll('Select * from racing_tracktimes WHERE identifier = @identifier AND track_id = @track_id', {['@identifier'] = results[i].identifier, ['@track_id'] = results[i].race_id}, function(lookups)
                    if #lookups > 0 then
                        -- Update if the laptime is better
                        print(lookups[1].best_lap)
                        if isempty(lookups[1].best_lap) or lookups[1].best_lap == 'DNF' or tonumber(results[i].best_lap) < tonumber(lookups[1].best_lap) then
                            MySQL.Async.execute('UPDATE racing_tracktimes SET `best_lap` = @best_lap WHERE identifier = @identifier AND track_id = @track_id',
                            {
                                ['@best_lap'] = results[i].best_lap,
                                ['@identifier'] = results[i].identifier,
                                ['@track_id'] = results[i].race_id
                            })
                        end
                    else    
                        -- First time racing store data
                        MySQL.Async.execute('INSERT INTO `racing_tracktimes` (`identifier`, `player_name`, `track_id`, `best_lap`) VALUES (@identifier, @player_name, @track_id, @best_lap)', {
                            ['@identifier'] = results[i].identifier,
                            ['@player_name'] = results[i].player_name,
                            ['@track_id'] = results[i].race_id,
                            ['@best_lap'] = results[i].best_lap
                        })
                    end
                end)
            end
        end
        -- cleanRace(race_key)
    end)
end

function cleanRace(race_key)
    Wait(2000)
    MySQL.Async.execute('DELETE FROM `racing_active` WHERE race_key = @race_key',{['@race_key'] = race_key})
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
    if RacingConfig.kashacters then 
        local lastChar = MySQL.Sync.fetchAll("SELECT * FROM `user_lastcharacter` WHERE `license` = @identity", {['@identity'] = identity})
        charNum = tonumber(lastChar[1].charid)
        identity = 'Char'.. charNum ..''.. GetIdentifierWithoutLicense(identity)
        cb(identity)
    else
        cb(identity)
    end
end


function GetIdentifierWithoutLicense(Identifier)
    return string.gsub(Identifier, "license", "")
end

function getServerIdentifier(Identifier)
    a, b = string.match(Identifier, "(.*):(.*)")
    print(a)
    print(b)
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