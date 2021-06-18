ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('racing:finish')
AddEventHandler('racing:finish', function(finishTime)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    MySQL.Async.execute('UPDATE racing_active SET `finished` = 1, `total_time` = @total_time WHERE identifier Like @identifier ',
    {
        ['@total_time'] = finishTime,
        ['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"
    })
    TriggerClientEvent('chatMessage', source, "", {0,0,0}, 'Finish time of ' .. finishTime)
    checkFinished()
end)

RegisterServerEvent('racing:quit')
AddEventHandler('racing:quit', function()
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    usource = source
    MySQL.Async.fetchAll('SELECT * from racing_pending WHERE identifier LIKE  @identifier', {['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"}, function(results)
        if #results > 0 then
            MySQL.Async.execute('DELETE from racing_pending WHERE id = @id',
            {
                ['@id'] = results[1].id
            })
            TriggerClientEvent('chatMessage', usource, "", {0,0,0}, 'left race')
        end
    end)
end)

RegisterServerEvent('racing:join')
AddEventHandler('racing:join', function(raceId,setOwner,laps)
    local xPlayer = ESX.GetPlayerFromId(source)
    local usource = source
    identifier = xPlayer.getIdentifier()
    getProperIdentity(identifier, function(charid)
        MySQL.Async.fetchAll('SELECT * from racing_pending WHERE identifier LIKE  @identifier', {['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"}, function(results)
            if #results > 0 then
                local errorCode = {code = 'joinError', message = 'Your Already in a race' .. #results .. ' quit race to join new /quitrace'}
                TriggerClientEvent('racing:racingerror', usource,errorCode )
            else
                local owner = nil
                if setOwner then
                    owner = identifier
                end
                local lap = 1
                if laps then
                    lap = laps
                end
                MySQL.Async.execute('INSERT INTO `racing_pending` (`race_id`, `identifier`, `player_name`,`owner`,`laps`) VALUES (@race_id, @identifier, @player_name, @owner, @laps)', {
                    ['@race_id'] = raceId,
                    ['@identifier'] = charid,
                    ['@player_name'] = xPlayer.getName(),
                    ['@owner'] = owner,
                    ['@laps'] = lap
                })
                TriggerClientEvent('chatMessage', usource, "", {0,0,0}, 'Joined Race ' .. raceId)
            end
        end)
    end)
end)

RegisterServerEvent('racing:start')
AddEventHandler('racing:start', function(raceId)
    local race_id = raceId
    MySQL.Async.fetchAll('SELECT * FROM racing_pending WHERE race_id = @race_id ', {['@race_id'] = race_id},
            function(results)
                local raceKey = GetGameTimer()
                for i = 1, #results do
                    MySQL.Async.execute('INSERT INTO `racing_active` ( `race_id`, `race_key`, `identifier`, `lap`, `checkpoint`, `best_lap`, `total_time`, `player_name`) VALUES (@race_id, @race_key, @identifier, @lap, @checkpoint, @best_lap, @total_time, @player_name)', {
                        ['@race_id'] = race_id,
                        ['@race_key'] = raceKey,
                        ['@identifier'] = results[i].identifier,
                        ['@player_name'] = results[i].player_name,
                        ['@lap'] = 1,
                        ['@checkpoint'] = 1,
                        ['@best_lap'] = '',
                        ['@total_time'] = ''
                    })
                    local xPlayer = ESX.GetPlayerFromIdentifier(getServerIdentifier(results[i].identifier))
                    xPlayer.triggerEvent('racing:startClient')
                end
                MySQL.Async.execute('DELETE From racing_pending WHERE race_id = @race_id',{['@race_id'] = race_id})
            end
        )
end)

RegisterServerEvent('racing:checkpoint')
AddEventHandler('racing:checkpoint', function(checkpoint, lap)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    MySQL.Async.execute('UPDATE racing_active SET `checkpoint` = @checkpoint, `lap` = @lap WHERE identifier LIKE @identifier ',
    {
        ['@checkpoint'] = checkpoint,
        ['@lap'] = lap,
        ['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"
    })
end)

RegisterServerEvent('racing:lapevent')
AddEventHandler('racing:lapevent', function(lapTime)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    local newlapTime = lapTime
    print(identifier)
    print(GetIdentifierWithoutLicense(identifier))
    MySQL.Async.fetchAll('SELECT * FROM racing_active WHERE identifier LIKE @identifier ',
    {['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"}, function(result)
        print(dump(result))
        if result[1].best_lap ~= "" then
            if newlapTime < tonumber(result[1].best_lap) then
                print('new lap time is better' .. newlapTime .. GetIdentifierWithoutLicense(identifier))
                MySQL.Async.execute('UPDATE racing_active SET `best_lap` = @best_lap WHERE identifier LIKE @identifier ',{['@best_lap'] = newlapTime,['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"})
            end
        else                
            print('No previous laptime' .. newlapTime .. GetIdentifierWithoutLicense(identifier))
            MySQL.Async.execute('UPDATE racing_active SET `best_lap` = @best_lap WHERE identifier LIKE @identifier ',{['@best_lap'] = newlapTime,['@identifier'] = "%" .. GetIdentifierWithoutLicense(identifier) .. "%"})
        end
    end)
end)



RegisterServerEvent('racing:pendingList')
AddEventHandler('racing:pendingList', function()
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
    local usource = source
    MySQL.Async.fetchAll('SELECT * FROM racing_pending WHERE owner != "NULL"', {}, function(results)
        TriggerClientEvent('racing:racingList', usource, results)
    end)
end)



-- Thread to manage as races finish to translate into Archived format, and to auto DNF after designated time frame
CreateThread(function()
	while true do
		-- draw every frame
		Wait(10000)
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
        cleanRace(race_key)
    end)
end

function cleanRace(race_key)
    Wait(2000)
    MySQL.Async.execute('DELETE FROM `racing_active` WHERE race_key = @race_key',{['@race_key'] = race_key})
end



-- Cleanup server start/stop

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
        MySQL.Async.execute('TRUNCATE `racing_active`',{})
        MySQL.Async.execute('TRUNCATE `racing_pending`',{})
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        MySQL.Async.execute('TRUNCATE `racing_active`',{})
        MySQL.Async.execute('TRUNCATE `racing_pending`',{})
	end
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