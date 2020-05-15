RegisterNetEvent('luaconsole:print_s')
AddEventHandler('luaconsole:print_s', function(str)
	ExecEnv.lc_print(str)
end)

RegisterNetEvent('luaconsole:clear_s')
AddEventHandler('luaconsole:clear_s', function()
	ExecEnv.lc_clear()
end)

RegisterNUICallback('exec', function(data, cb)

	if string.sub(data.handler, 1, 1) == '@' then

		TriggerServerCallback('luaconsole:exec', cb, string.sub(data.handler, 2), data.code)

	else

		local handler = Handlers[data.handler]

		if handler == nil then
			cb({ret = json.encode('handler ' .. data.handler .. ' does not exists')})
			return
		end

		local func = handler(data.code, ExecEnv)

		if func == nil then
			cb({ret = json.encode('Invalid expression => ' .. data.code)})
			return
		end

		try {
			function()
				cb({ret = json.encode(escapeObject(func()))})
			end,

			catch {
				function(err)
					cb({ret = json.encode('Error => ' .. err)})
				end
			}
		}

	end

end)

RegisterNUICallback('set_handler', function(data, cb)
	
	Handler = data.name

	if string.sub(Handler, 1, 1) == '@' then
		TriggerServerEvent('luaconsole:setHandler', string.sub(Handler, 2))
	end

	cb('')

end)

RegisterNUICallback('watch', function(data, cb)

	if string.sub(Handler, 1, 1) == '@' then

		TriggerServerCallback('luaconsole:watch', cb, string.sub(Handler, 2), data.name)

	else

		Watchable     = data.name
		local handler = Handlers[Handler]
		local obj     = {}

		if handler ~= nil then

			local func = handler('return ' .. data.name)

			if func ~= nil then

				try {
					function()
						obj = escapeObject(func())
					end,

					catch {
						function(err)
						end
					}
				}

				
			end

		end

		cb({obj = obj})

	end

end)

RegisterNUICallback('diffwatch', function(data, cb)

	if string.sub(Handler, 1, 1) == '@' then

		TriggerServerCallback('luaconsole:diffwatch', cb, data.diff)

	else

		local handler = Handlers[Handler]
		local diff    = data.diff

		if handler ~= nil then

			for i=1, #diff, 1 do

				local code = Watchable;

				for j=1, #diff[i].path, 1 do

					local part = diff[i].path[j]

					if type(part) == 'number' then
						code = code .. '[' .. (part + 1) .. ']'
					else
						code = code .. '[\'' .. part .. '\']'
					end

				end

				if diff[i].value == nil then
					code = code .. ' = nil'
				elseif type(diff[i].value) == 'number' then
					code = code .. ' = ' .. diff[i].value;
				elseif  type(diff[i].value) == 'boolean' then
					code = code .. ' = ' .. tostring(diff[i].value)
				else
					code = code .. ' = \'' .. diff[i].value .. '\''
				end

				local func = Handlers[Handler](code)

				if func ~= nil then
					func()
				else
					print('(' .. Handler .. ') Invalid expression => ' .. code)
				end

			end

		end

	end

end)

RegisterNUICallback('escape', function(data, cb)

	SendNUIMessage({action = 'hide'})
	SetNuiFocus(false)

	cb('')

end)
