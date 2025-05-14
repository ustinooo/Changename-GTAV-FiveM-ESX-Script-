local Framework = Config.Framework

if Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Framework == "qbcore" then
    QBCore = exports['qb-core']:GetCoreObject()
end


CreateThread(function()
    for k,v in pairs(Config.MayorOffice) do
        exports.ox_target:addBoxZone({
            coords = v.pos,
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            options = {
                {
                    name  = 'kipxchangename:changename',
                    event = 'kipxchangename:openMenu',
                    icon  = v.icon,
                    label = v.label
                }
            }
        })
    end
end)

Citizen.CreateThread(function()
    for i = 1, #Config.MayorOffice, 1 do
        if Config.NPCEnable then
            RequestModel(Config.MayorOffice[i].people)
            while not HasModelLoaded(Config.MayorOffice[i].people) do
                Wait(1)
            end
            people = CreatePed(1, Config.MayorOffice[i].people, Config.MayorOffice[i].pos.x, Config.MayorOffice[i].pos.y, Config.MayorOffice[i].pos.z - 1, Config.MayorOffice[i].heading, false, true)
            SetBlockingOfNonTemporaryEvents(people, true)
            SetPedDiesWhenInjured(people, false)
            SetPedCanPlayAmbientAnims(people, true)
            SetPedCanRagdollFromPlayerImpact(people, false)
            SetEntityInvincible(people, true)
            FreezeEntityPosition(people, true)
            TaskStartScenarioInPlace(people, Config.MayorOffice[i].anim, 0, true);
        end
    end
end)

RegisterNetEvent("kipxchangename:openMenu")
AddEventHandler("kipxchangename:openMenu", function()
    ExecuteCommand('e tablet2')
    lib.registerContext({
        id = 'changenameOpenMenu',
        title = 'Keep City Civil Registry',
        onExit = function()
                ExecuteCommand('e c')
            end,
        options = {
          {
            title = 'Change Identity',
            description = 'Change first and last name for only P' .. Config.ChangeNamePrice,
            icon = 'fa-solid fa-clipboard-question',
            onSelect = function()
                changeName()
            end
          }
        }
      })
     
      lib.showContext('changenameOpenMenu')
end)

function changeName()
    ExecuteCommand('e tablet2')

    if Framework == "esx" then
        ESX.TriggerServerCallback('kipxchangename:getData', function(fname, lname)
            openInputDialog(fname, lname)
        end)
    elseif Framework == "qbcore" then
        QBCore.Functions.TriggerCallback('kipxchangename:getData', function(fname, lname)
            openInputDialog(fname, lname)
        end)
    end
end

function openInputDialog(fname, lname)
    local input = lib.inputDialog('Change Information', {
        {type = 'input',   label = 'Firstname',  required = true,  default = fname, icon = 'fa-solid fa-person'},
        {type = 'input',   label = 'Lastname',   required = true,  default = lname, icon = 'fa-solid fa-person'},
        {type = 'date',    label = 'Date',       icon = {'far', 'calendar'}, default = true, format = "DD/MM/YYYY"}
    })

    if input ~= nil then
        local firstname = input[1]
        local lastname = input[2]
        local timestamp = math.floor(input[3] / 1000)
        ExecuteCommand('e c')
        TriggerServerEvent('kipxchangename:Update', firstname, lastname, timestamp)
    else
        ExecuteCommand('e c')
        TriggerEvent('kipxchangename:notif', 'Keep City Hall', 'Fill-out these forms', 5000, 'error')
    end
end


RegisterNetEvent('kipxchangename:notif', function(title, description, time, notifyType)
    if Config.Notification == 'oxlib' then
        lib.notify({
            title = title,
            description = description,
            duration = time,
            type = notifyType
        })
    elseif Config.Notification == 'esx' then
        ESX.ShowNotification(description)
    elseif Config.Notification == 'qbcore' then
        QBCore.Functions.Notify(description, notifyType, time)
    end
end)



