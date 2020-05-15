Citizen.CreateThread(function()

	while true do

		if (IsControlJustPressed(0, 26) or IsDisabledControlJustPressed(0, 26)) and(IsControlPressed(0, 19) or IsDisabledControlPressed(0, 19)) then
			SendNUIMessage({action = 'show'})
			SetNuiFocus(true, true)
		end

		Citizen.Wait(0)

	end
end)
