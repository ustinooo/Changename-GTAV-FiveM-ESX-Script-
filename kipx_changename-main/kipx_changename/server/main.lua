local Framework = Config.Framework

if Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Framework == "qbcore" then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterCommand("changename", function(source, args, rawCommand)
    TriggerClientEvent("kipxchangename:openMenu", source)
end, true) 

if Framework == "esx" then
    ESX.RegisterServerCallback('kipxchangename:getData', function(source, cb)
        local name = getPlayerIdentity(source)
        cb(name.firstname, name.lastname)
    end)
else
    QBCore.Functions.CreateCallback('kipxchangename:getData', function(source, cb)
        local name = getPlayerIdentity(source)
        cb(name.firstname, name.lastname)
    end)
end

function getPlayerIdentity(source)
    local result = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {
        Framework == "esx" and ESX.GetPlayerFromId(source).identifier or QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    })
    return result or { firstname = "Unknown", lastname = "Unknown" }
end

RegisterServerEvent('kipxchangename:Update', function(firstname, lastname, date)
    local src = source
    local player = Framework == "esx" and ESX.GetPlayerFromId(src) or QBCore.Functions.GetPlayer(src)
    local identifier = Framework == "esx" and player.identifier or player.PlayerData.citizenid

    local currentMoney = Framework == "esx" and player.getAccount('bank').money or player.Functions.GetMoney('bank')
    local xPlayerName = Framework == "esx" and player.getName() or player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    local timestamp = os.date('%Y-%m-%d %H:%M:%S', date)
    local remarks = xPlayerName .. " successfully changed their name to " .. firstname .. " " .. lastname .. " on " .. timestamp .. " and paid the amount of " .. Config.ChangeNamePrice

    local color = 32768
    local fullname = xPlayerName

    if currentMoney >= Config.ChangeNamePrice then
        -- Remove money from player
        if Framework == "esx" then
            player.removeAccountMoney('bank', Config.ChangeNamePrice)
            -- Add money to government society account
            TriggerEvent('esx_addonaccount:getSharedAccount', Config.Society, function(account)
                if account then
                    account.addMoney(Config.ChangeNamePrice)
                end
            end)
    		---running SQL with QBCore  
            MySQL.Async.execute('UPDATE users SET firstname = @firstname, lastname = @lastname WHERE identifier = @identifier', {
                    ['@firstname'] = firstname,
                    ['@lastname'] = lastname,
                    ['@identifier'] = identifier
                })
        else
            player.Functions.RemoveMoney('bank', Config.ChangeNamePrice)
            TriggerEvent('QBCore:Server:GetSocietyAccount', Config.Society, function(account)
                if account then
                    account.addMoney(Config.ChangeNamePrice)
                end
            end)
            ---running SQL with QBCore    
            MySQL.query('UPDATE players SET firstname = @firstname, lastname = @lastname WHERE citizenid = @identifier', {
                    ['@firstname'] = firstname,
                    ['@lastname'] = lastname,
                    ['@identifier'] = identifier
                })
        end

        -- Send logs and notify client
        sendCityHallLogstoDiscord(color, identifier, fullname, remarks)
        SendNotify(src, 'Keep City Hall', "You successfully changed your name from " ..fullname.. " to " ..firstname .. " " .. lastname, 5000, 'success')
        SendNotify(src, 'Keep City Hall', "A process fee was charged in your account in the amount of P" .. Config.ChangeNamePrice, 5000, 'success')
    else
        SendNotify(src, 'Keep City Hall', "Failure to process, insufficient funds, kindly check your Bank Balance.", 5000, 'success')
    end
end)

-- Unified Notification Function
function SendNotify(source, title, description, time, notifyType)
    TriggerClientEvent('kipxchangename:notif', source, title, description, time, notifyType)
end

function sendCityHallLogstoDiscord(color, xPlayerIdentifier, playerName, message)
    local embeds = {
        {
            ["title"] = "Keep City Hall System",
            ["description"] = message,
            ["color"] = color, 
            ["fields"] = {
                {["name"] = "Player Name", ["value"] = playerName, ["inline"] = true},
                {["name"] = "Player ID", ["value"] = xPlayerIdentifier, ["inline"] = true},
            },
            ["footer"] = {
                ["text"] = "Prepared by: " .. playerName,
            },
        }
    }
   PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({ embeds = embeds}), { ['Content-Type'] = 'application/json' })
end