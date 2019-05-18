local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

local DoingBreak = false -- don't touch
local GUI = {} -- don't touch
ESX = nil -- don't touch
GUI.Time = 0 -- don't touch
local PlayerData = {} -- don't touch
local showPro = false -- don't touch
local stealing = false -- don't touch
local peeking = false -- don't touch
local CurrentAction		= nil
------------------------------------------------------
------------------------------------------------------
local useQalleCameraSystem = true --( https://github.com/qalle-fivem/esx-qalle-camerasystem )
local chancePoliceNoti = 60 -- the procent police get notified (only numbers like 30, 10, 40. You get it.)
local useBlip = true -- if u want blip
local useInteractSound = true -- if you wanna use InteractSound (when u lockpick the door)
------------------------------------------------------
------------------------------------------------------

------ l o c a l e s ------
local noCar = "No car nearby"
local text = "~r~lockpick~w~ door?" -- lockpick the door
local textUnlock = "~g~[E]~w~ Enter" -- enter the house
local insideText = "~g~[E]~w~ Exit" -- exit the door
local abortConfirm = "You have aborted the lockpicking"
local searchText = "~g~[E]~w~ Search" -- search the spot
local emptyMessage = "There is nothing here!" -- if you press E where it is empty
local emptyMessage3D = "~r~Empty" -- if the spot is empty
local closetText = "~g~[E]~w~ Peek into closet" -- text at closet
local abortLock = "~g~[E]~w~ To abort lockpicking"
local noLockpickText = "You don't have any lockpick!" -- if you don't have a lockpick and you try to do the burglary
local carUnlocked = "You have unlocked the car"
local youFound = "From the" -- when you steal something
local burglaryDetected = "A burglary has been detected at" -- text 1 cops gets sent
local sentPhoto = "We've sent you a photo of the criminal." -- if you use qalle's camerasystem this will be in the message too
local item = {'ring', 'goldNecklace', 'laptop', 'coke_pooch', 'weed_pooch', 'samsungS10', 'rolex', 'camera', 'nothing', 'nothing', 'nothing', 'nothing', 'nothing'}
local exitPos = {pos = {x = 0, y = 0, z = 0, h = 0 }}
---------------------------


local PlayerData = {}

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(1)
  end
while ESX.GetPlayerData() == nil do
  Citizen.Wait(10)
end
PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)



RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('99kr-burglary:onUse')
AddEventHandler('99kr-burglary:onUse', function()
	local playerPed		= GetPlayerPed(-1)
  local coords		= GetEntityCoords(playerPed)
	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

    if DoesEntityExist(vehicle) then
      lockpicking = false
      ---print(lockpicking)
      randi = math.random(1, 10)
      if randi == 1 then
      TriggerServerEvent('99kr-burglary:removeKit')
      end
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
			  if useInteractSound then
			    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.7)
			  end

			Citizen.CreateThread(function()
				ThreadID = GetIdOfThisThread()
				CurrentAction = 'lockpick'

				Citizen.Wait(22 * 1000)

        if CurrentAction ~= nil then
          procent(100)
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(carUnlocked)
				end
				
				CurrentAction = nil
				--TerminateThisThread()
			end)
		end

		Citizen.CreateThread(function()
			Citizen.Wait(0)

			if CurrentAction ~= nil then
				SetTextComponentFormat('STRING')
				AddTextComponentString(abortLock)
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)

				if IsControlJustReleased(0, Keys["X"]) then
					TerminateThread(ThreadID)
					ESX.ShowNotification(abortConfirm)
					CurrentAction = nil
				end
			end

		end)
	end
end)




RegisterNetEvent('99kr-burglary:Lockpick')
AddEventHandler('99kr-burglary:Lockpick', function(xPlayer)
  lockpicking = true
end)

local burglaryPlaces = {
  ["Robban"] = {
    locked = true,
    pos = { x = 1229.1, y = -725.47, z = 60.80, h = 89.98 }, -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 }, -- Inside coords
    animPos = { x = 1229.53, y = -724.81, z = 60.96, h = 277.96 } -- The animation position
  },
  ["Grove Street 1"] = {
    locked = true,
    pos = { x = 126.73, y = -1930.20, z = 22.0, h = 207.79 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 126.73, y = -1930.00, z = 21.38, h = 207.79 } -- The animation position
  }
}

local burglaryInside = {
[" kitchen table you found "] = { x = 342.23, y = -1003.29, z = -99.0,  amount = 1},
[" tv draw you found "] = { x = 338.14, y = -997.69,  z = -99.2,  amount = 1},
[" bedroom draw you found "] = { x = 350.91, y = -999.26,  z = -99.2,  amount = 1},
[" bed side table you found "] = { x = 349.19, y = -994.83,  z = -99.2,  amount = 1},
[" book shelf you found "] = { x = 345.3,  y = -995.76,  z = -99.2,  amount = 1},
[" hallway table you found "] = { x = 346.14, y = -1001.55, z = -99.2,  amount = 1},
[" bathroom draw you found "] = { x = 347.23, y = -994.09,  z = -99.2,  amount = 1},
[" dinning table you found "] = { x = 339.23, y = -1003.35, z = -99.2,  amount = 1},
[" wardrobe you found "] = { x = 351.24, y = -993.53,  z = -99.2,  amount = 1}

}

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5)
    for k,v in pairs(burglaryPlaces) do
      local playerPed = PlayerPedId()
      local house = k
      local coords = GetEntityCoords(playerPed)
      local dist   = GetDistanceBetweenCoords(v.pos.x, v.pos.y, v.pos.z, coords.x, coords.y, coords.z, false)
        if dist <= 1.2 and DoingBreak == false then
          if v.locked then
            DrawText3D(v.pos.x, v.pos.y, v.pos.z, text, 0.4)                  
              if lockpicking == true then
                confMenu(house)
                lockpicking = false
          end
        else
          DrawText3D(v.pos.x, v.pos.y, v.pos.z, textUnlock, 0.4)                  
            if IsControlJustPressed(0, Keys["E"]) then
              fade()
              SetCoords(playerPed, v.inside.x, v.inside.y, v.inside.z - 0.98)
              SetEntityHeading(playerPed, v.inside.h)
            end
          end
        end
      
    end
  end
end)

Citizen.CreateThread(function()
  while stealing == false do
    Citizen.Wait(5)
    for k, v in pairs(burglaryInside) do
      local playerPed = PlayerPedId()
      local coords = GetEntityCoords(playerPed)
      local dist = GetDistanceBetweenCoords(v.x, v.y, v.z, coords.x, coords.y, coords.z, false)
      if dist <= 1.2 and v.amount > 0 then
        DrawText3D(v.x, v.y, v.z, searchText, 0.4)
        if dist <= 0.5 and IsControlJustPressed(0, Keys["E"]) then
          steal(k)
        end
      elseif v.amount < 1 and dist <= 1.2 then
        DrawText3D(v.x, v.y, v.z, emptyMessage3D, 0.4)
        if IsControlJustPressed(0, Keys["E"]) and dist <= 0.5 then
          ESX.ShowNotification(emptyMessage)
        end
      end
    end
  end
end)


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5)
    for k, v in pairs(burglaryPlaces) do
      local playerPed = PlayerPedId()
      local coords = GetEntityCoords(playerPed)
      local house = k
      if GetDistanceBetweenCoords(v.inside.x, v.inside.y, v.inside.z, coords.x, coords.y, coords.z, false) <= 3.0 then
        DrawText3D(v.inside.x, v.inside.y, v.inside.z, insideText, 0.4)
        if GetDistanceBetweenCoords(v.inside.x, v.inside.y, v.inside.z, coords.x, coords.y, coords.z, false) <= 1.2 and IsControlJustPressed(0, Keys["E"]) then
          fade()
          teleport(exitPos)
        end
      end
    end
  end
end)


Citizen.CreateThread(function()
	while true do
    Citizen.Wait(6)
    if showPro == true then
      local playerPed = PlayerPedId()
		  local coords = GetEntityCoords(playerPed)
      DrawText3D(coords.x, coords.y, coords.z, TimeLeft .. '~g~%', 0.4)
    end
	end
end)

function confMenu(house)
Citizen.Wait(6)
  local v = GetHouseValues(house, burglaryPlaces)
  exitPos = {pos ={x = v.pos.x, y = v.pos.y, z = v.pos.z, h = v.pos.h }}
  Citizen.CreateThread(function()
      local inventory = ESX.GetPlayerData().inventory
      local LockpickAmount = nil
        for i=1, #inventory, 1 do                          
            if inventory[i].name == 'lockpick' then
                LockpickAmount = inventory[i].count
            end
        end
          if LockpickAmount > 0 then
            HouseBreak(house)
            v.locked = false
            Citizen.Wait(math.random(15000,30000))
            local random = math.random(0, 100)
              if useQalleCameraSystem == true then
                if random <= chancePoliceNoti then                           -- chance police get notified and they get a photo of you
                  TriggerEvent('skinchanger:getSkin', function(skin)
                  TriggerServerEvent('esx-qalle-camerasystem:addWitness', skin, "Burglary")
                  TriggerServerEvent('esx_phone:send', 'police', burglaryDetected .. ' ' .. house .. '. ' .. sentPhoto, { x = v.pos.x, y = v.pos.y, z = v.pos.z })
                end)
              end
                  if useQalleCameraSystem == false then
                    if random <= chancePoliceNoti then
                      TriggerServerEvent('esx_phone:send', 'police', burglaryDetected .. ' ' .. house, { x = v.pos.x, y = v.pos.y, z = v.pos.z })
                    end
                  end
          else 
           ESX.ShowNotification(noLockpickText)
          end
        end
	end)
end
    


function steal(k)
  local goods = item[math.random(#item)] 
  local values = GetHouseValues(k, burglaryInside)
  local playerPed = PlayerPedId()
  stealing = true
  FreezeEntityPosition(playerPed, true)
  TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
  Citizen.Wait(2000)
  procent(50)
  TriggerServerEvent('99kr-burglary:Add', goods, 1)
  ESX.ShowNotification(youFound .. k ..' '.. goods)
  values.amount = values.amount - 1
  ClearPedTasks(playerPed)
  FreezeEntityPosition(playerPed, false)
  stealing = false
end

function HouseBreak(house)
  local v = GetHouseValues(house, burglaryPlaces)
  local playerPed = PlayerPedId()
  fade()
  DoingBreak = true
  FreezeEntityPosition(playerPed, true)
  SetEntityCoords(playerPed, v.animPos.x, v.animPos.y, v.animPos.z - 0.98)
  SetEntityHeading(playerPed, v.animPos.h)
  loaddict("mini@safe_cracking")
  TaskPlayAnim(playerPed, "mini@safe_cracking", "idle_base", 3.5, - 8, - 1, 2, 0, 0, 0, 0, 0)
  if useInteractSound then
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.7)
  end
  procent(70)
  rand = math.random(1, 10)
  if rand == 1 then
    TriggerServerEvent('99kr-burglary:Remove', 'lockpick', 1)
  end  
  print(rand)
  fade()
  ClearPedTasks(playerPed)
  FreezeEntityPosition(playerPed, false)
  SetCoords(playerPed, v.inside.x, v.inside.y, v.inside.z - 0.98)
  SetEntityHeading(playerPed, v.inside.h)
end 


function SetCoords(playerPed, x, y, z)
  SetEntityCoords(playerPed, x, y, z)
  Citizen.Wait(100)
  SetEntityCoords(playerPed, x, y, z)
end

function fade()
  DoScreenFadeOut(1000)
  Citizen.Wait(1000)
  DoScreenFadeIn(1000)
end

function loaddict(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Wait(10)
  end
end

function DrawText3D(x, y, z, text, scale)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
  SetTextScale(scale, scale)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextEntry("STRING")
  SetTextCentre(1)
  SetTextColour(255, 255, 255, 255)
  SetTextOutline()
  AddTextComponentString(text)
  DrawText(_x, _y)
  local factor = (string.len(text)) / 270
  DrawRect(_x, _y + 0.015, 0.005 + factor, 0.03, 31, 31, 31, 155)
end

function procent(time)
  showPro = true
  TimeLeft = 0
  repeat
  TimeLeft = TimeLeft + 1 -- thank you (github.com/Loffes)
  Citizen.Wait(time)
  until(TimeLeft == 100)
  showPro = false
end

function teleport(confMenu)
  local values = GetHouseValues(house, burglaryPlaces)
  local playerPed = PlayerPedId()
  SetCoords(playerPed, confMenu.pos.x, confMenu.pos.y, confMenu.pos.z - 0.98)
  SetEntityHeading(playerPed, confMenu.pos.h)
  DoingBreak = false
end

function GetHouseValues(house, pair)
  for k, v in pairs(pair) do
    if k == house then
      return v
    end
  end
end

if useBlip then
  Citizen.CreateThread(function()
    for k, v in pairs(burglaryPlaces) do
       local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
       SetBlipSprite (blip, 40)
       SetBlipDisplay(blip, 4)
       SetBlipScale (blip, 0.8)
       SetBlipColour (blip, 39)
       SetBlipAsShortRange(blip, true)
       BeginTextCommandSetBlipName("STRING")
       AddTextComponentString('Burglary')
       EndTextCommandSetBlipName(blip)
    end
  end)
end

RegisterNetEvent('99kr-burglary:Sound')
AddEventHandler('99kr-burglary:Sound', function(sound1, sound2)
PlaySoundFrontend(-1, sound1, sound2)
end)

--------------  Pawn Shop ---------------------------
function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local blips = {
  {title="Pawnshop", colour=4, id=133, x = 412.31, y = 314.11, z = 103.02}
}

Citizen.CreateThread(function()
  for _, info in pairs(blips) do
    info.blip = AddBlipForCoord(info.x, info.y, info.z)
    SetBlipSprite(info.blip, info.id)
    SetBlipDisplay(info.blip, 4)
    SetBlipScale(info.blip, 1.0)
    SetBlipColour(info.blip, info.colour)
    SetBlipAsShortRange(info.blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(info.title)
    EndTextCommandSetBlipName(info.blip)
  end
end)

local gym = {
  {x = 412.31, y = 314.11, z = 103.02}
}

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      for k in pairs(gym) do
          DrawMarker(21, gym[k].x, gym[k].y, gym[k].z, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 0, 153, 255, 255, 0, 0, 0, 0)
      end
  end
end)

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      for k in pairs(gym) do
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, gym[k].x, gym[k].y, gym[k].z)
        if dist <= 0.5 then
          DrawText3D(plyCoords.x, plyCoords.y, plyCoords.z, "~w~Press ~r~[H] ~w~ to use pawn shop!", 0.4)
        end
          if IsControlJustPressed(0, Keys['H'])then
            OpenSellMenu()
          end			
      end
  end
end)

function OpenSellMenu()
  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'pawn_sell_menu',
      {
          title    = 'Do you have any of the following you want to sell?',
          elements = {
              {label = 'Ring ($350)', value = 'ring'},
              {label = 'Rolex ($1150)', value = 'rolex'},
              {label = 'Camera ($135)', value = 'camera'},
              {label = 'Gold Necklace ($345)', value = 'goldNecklace'},
              {label = 'Laptop ($1750)', value = 'laptop'},
              {label = 'Samsung S10($925)', value = 'samsungS10'},
          }
      },
      function(data, menu)
          if data.current.value == 'ring' then
              TriggerServerEvent('99kr-burglary:sellring')
          elseif data.current.value == 'rolex' then
              TriggerServerEvent('99kr-burglary:sellrolex')
          elseif data.current.value == 'camera' then
              TriggerServerEvent('99kr-burglary:sellcamera')
          elseif data.current.value == 'goldNecklace' then
              TriggerServerEvent('99kr-burglary:sellgoldNecklace')
          elseif data.current.value == 'laptop' then
              TriggerServerEvent('99kr-burglary:selllaptop')
          elseif data.current.value == 'samsungS10' then
              TriggerServerEvent('99kr-burglary:sellsamsungS10')
          end
      end,
      function(data, menu)
          menu.close()
      end
  )
end