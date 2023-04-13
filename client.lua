local elektrykMarker = {x = 0.0, y = 0.0, z = 0.0} -- współrzędne markeru elektryka
local elektrykVehicle = {x = 0.0, y = 0.0, z = 0.0} -- współrzędne pojazdu firmowego
local elektrykJobs = {
	{x = 0.0, y = 0.0, z = 0.0, job = "Naprawa przewodów", reward = Config.ElektrykJobReward.min, rewardMax = Config.ElektrykJobReward.max},
	{x = 0.0, y = 0.0, z = 0.0, job = "Naprawa gniazdka", reward = Config.ElektrykJobReward.min, rewardMax = Config.ElektrykJobReward.max},
	{x = 0.0, y = 0.0, z = 0.0, job = "Naprawa żarówki", reward = Config.ElektrykJobReward.min, rewardMax = Config.ElektrykJobReward.max}
}

function ShowElektrykJobMenu()
    local elements = {}

    for i=1, #elektrykJobs, 1 do
        table.insert(elements, {label = elektrykJobs[i].job, value = i})
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'elektryk_job_menu', {
        title    = "Elektryk",
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        local job = elektrykJobs[data.current.value]
        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed)
        local jobBlip = AddBlipForCoord(job.x, job.y, job.z)

        SetBlipSprite(jobBlip, 1)
        SetBlipColour(jobBlip, 5)
        SetBlipAsShortRange(jobBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Elektryk")
        EndTextCommandSetBlipName(jobBlip)

        while GetDistanceBetweenCoords(coords, job.x, job.y, job.z, true) > 5 do
            Citizen.Wait(1000)
            coords = GetEntityCoords(playerPed)
        end

        RemoveBlip(jobBlip)

        TriggerServerEvent('elektryk:jobDone', job.reward)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

AddEventHandler('elektryk:selectColor', function()
	ShowElektrykJobMenu()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = GetPlayerPed(-1)
		local coords = GetEntityCoords(playerPed)

		for i=1, #elektrykJobs, 1 do
			local job = elektrykJobs[i]
			local distance = GetDistanceBetweenCoords(coords, job.x, job.y, job.z, true)

			if distance < 5 then
				DrawMarker(1, job.x, job.y, job.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
			end

			if distance < 1 then
				ESX.ShowHelpNotification("Naciśnij ~INPUT_CONTEXT~ aby wykonać zadanie")

				if IsControlJustReleased(0, 38) then
					ShowElektrykJobMenu()
				end
			end
		end
	end
end)

function CreateElektrykMarker()
	elektrykMarker = CreateMarker(elektrykMarker.x, elektrykMarker.y, elektrykMarker.z, "cylinder", 1.0, 255, 0, 0, 100, 0, 0, 0, false, 0)
	SetBlipSprite(elektrykMarker, 446)
	SetBlipColour(elektrykMarker, 1)
	SetBlipAsShortRange(elektrykMarker, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Elektryk")
	EndTextCommandSetBlipName(elektrykMarker)
end

function CreateElektrykVehicle()
	elektrykVehicle = CreateVehicle(GetHashKey("elektrykVehicle"), elektrykVehicle.x, elektrykVehicle.y, elektrykVehicle.z, 0.0, true, false)
	SetVehicleNumberPlateText(elektrykVehicle, "ELEKTRYK")
	SetVehicleOnGroundProperly(elektrykVehicle)
end

local elektrykReward = math.random(100, 1500)

function ShowElektrykMenu()
    local elements = {
        {label = "Czerwony", value = "red"},
        {label = "Czarny", value = "black"},
        {label = "Zielony", value = "green"}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'elektryk_menu', {
        title    = "Elektryk",
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('elektryk:selectColor', data.current.value, elektrykReward)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

AddEventHandler('onClientMapStart', function()
	CreateElektrykMarker()
	CreateElektrykVehicle()
end)

AddEventHandler('elektryk:markerEntered', function()
	ShowElektrykMenu()
end)