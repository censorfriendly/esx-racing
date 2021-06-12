ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('racing:finish')
AddEventHandler('racing:finish', function(finishTime, raceId)
    identifier = ESX.GetPlayerFromId(source).getIdentifier()

    -- MySQL.Async.execute('INSERT INTO `racing_temp` (`race_id`, `identifier`, `track_time`, `placement`) VALUES ('.. raceId ..', ' .. source .. ', ' .. finishTime .. ', 1')
    
    MySQL.Async.execute('INSERT INTO `racing_temp` (`race_id`, `identifier`, `track_time`, `placement`) VALUES (@race_id, @identifier, @time, @placement)', {
        ['@race_id'] = raceId,
        ['@identifier'] = identifier,
        ['@time'] = finishTime,
        ['@placement'] = 1
    })

    TriggerClientEvent('chatMessage', source, "", {0,0,0}, 'Finish time of ' .. finishTime)
end)

RegisterServerEvent('racing:start')
AddEventHandler('racing:start', function(startTime)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('chatMessage', source, "", {0,0,0}, 'Start time of ' .. startTime)
end)
-- INSERT INTO `es_extended`.`racing_temp` (`race_id`, `identifier`, `track_time`, `placement`) VALUES ('1', '234234234', '1231', '1');
