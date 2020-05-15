AddEventHandler('luaconsole:print', function(str)
	SendNUIMessage({action = 'print', str = str})
end)

AddEventHandler('luaconsole:exec', function(handler, code)
	Handlers[handler](code, ExecEnv)()
end)

AddEventHandler('onResourceStart', function(resourceName)

	if resourceName ~= 'luaconsole' then

		TriggerEvent('luaconsole:getHandlers', function(name, loadFunc)
			Handlers[name] = loadFunc
		end)

	end
	
end)

AddEventHandler('luaconsole:getHandlers', function(cb)

  local name = GetCurrentResourceName()

  cb(name, function(code, env)
    if env ~= nil then
      for k,v in pairs(env) do _ENV[k] = v end
      return load(code, 'lc:' .. name, 't', _ENV)
    else
      return load(code, 'lc:' .. name, 't')
    end
  end)

end)
