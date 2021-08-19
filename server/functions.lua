ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


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
            table.insert(distributed,{identifier = archiveRaces[i][place].identifier, crypto = (tonumber(RacingConfig.cryptoPayout) / x), bestLap = archiveRaces[i][place].best_lap})
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
        -- check if this time was the fastest lap for the track
        MySQL.Async.fetchAll('SELECT * FROM racing_tracktimes WHERE track_id = @trackId Order By track_id Desc, best_lap Desc Limit 1', {['@trackId'] = archiveConfigs[i].id}, function(results)
            if #results > 0 and results[1].identifier == distributed[1].identifier and distributed[1].bestLap == results[1].best_lap then 
                MySQL.Async.execute('UPDATE users SET `racecrypto` =  racecrypto + @crypto WHERE identifier = @identifier',
                {
                    ['@identifier'] = distributed[1].identifier,
                    ['@crypto'] = (RacingConfig.cryptoPayout / 2)
                })
            end
        end)
    end
end

function alertPlayers(raceConf)
    for x = 1, #alertSignups do
        local xPlayer = ESX.GetPlayerFromIdentifier(alertSignups[x].identifier)
        xPlayer.triggerEvent('esx:showNotification', 'Race Alert: ' .. raceConf.name .. ' No. Laps ' .. raceConf.laps)
    end
end

function triggerPoliceNotification(location)
    if RacingConfig.notifyPD then
        local percent = RacingConfig.notifyChance
        local chance = math.fmod(GetGameTimer(),100)
        if chance <= percent then 
            print("add call to mdt alert system")
			print(location)
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

function checkDNFs()
    for x,v in pairs(activeRaces) do 
        if activeRaces[x] ~= nil then
            for y = 1, #activeRaces[x] do 
                if activeRaces[x][y].finished == false and not isempty(activeRaces[x][y].last_checkpoint_time) and tonumber(activeRaces[x][y].last_checkpoint_time) < GetGameTimer() - 300000  then 
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
