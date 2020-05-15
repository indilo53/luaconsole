RegisterNetEvent('luaconsole:setHandler')
AddEventHandler('luaconsole:setHandler', function(name)
	Handler = name
end)

RegisterServerCallback('luaconsole:exec', function(source, cb, handlerName, code)

	CurrentClient = source
	local handler = Handlers[handlerName]

	if handler == nil then
		cb({ret = json.encode('handler ' .. handlerName .. ' does not exists')})
		return
	end

	local func = handler(code, ExecEnv)

	if func == nil then
		cb({ret = json.encode('Invalid expression => ' .. code)})
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

end)

RegisterServerCallback('luaconsole:watch', function(source, cb, handlerName, name)

	CurrentClient = source
	Watchable     = name
	local handler = Handlers[handlerName]
	local obj     = {}

	if handler ~= nil then

		local func = handler('return ' .. name)

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

end)

RegisterServerCallback('luaconsole:diffwatch', function(source, cb, diff)

	CurrentClient = source
	local handler = Handlers[Handler]

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

end)