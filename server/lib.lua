local CurrentRequestId  = 0
local ServerCallbacks   = {}

RegisterServerCallback = function(name, cb)
  ServerCallbacks[name] = cb
end

TriggerServerCallback = function(name, requestId, source, cb, ...)

  if ServerCallbacks[name] ~= nil then
    ServerCallbacks[name](source, cb, ...)
  else
    print('TriggerServerCallback => [' .. name .. '] does not exists')
  end

end

RegisterServerEvent('luaconsole:serverCallback')
AddEventHandler('luaconsole:serverCallback', function(requestId, ...)
  ServerCallbacks[requestId](...)
  ServerCallbacks[requestId] = nil
end)

RegisterServerEvent('luaconsole:triggerServerCallback')
AddEventHandler('luaconsole:triggerServerCallback', function(name, requestId, ...)

  local _source = source

  TriggerServerCallback(name, requestID, _source, function(...)
    TriggerClientEvent('luaconsole:serverCallback', _source, requestId, ...)
  end, ...)

end)

