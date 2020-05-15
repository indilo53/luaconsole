Handler   = 'luaconsole'
Handlers  = {}
Watchable = ''

SetTimeout(0, function()

	TriggerEvent('luaconsole:getHandlers', function(name, loadFunc)
		Handlers[name] = loadFunc
	end)

end)