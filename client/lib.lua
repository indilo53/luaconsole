local CurrentRequestId = 0
local ServerCallbacks  = {}

TriggerServerCallback = function(name, cb, ...)

  ServerCallbacks[CurrentRequestId] = cb

  TriggerServerEvent('luaconsole:triggerServerCallback', name, CurrentRequestId, ...)

  if CurrentRequestId < 65535 then
    CurrentRequestId = CurrentRequestId + 1
  else
    CurrentRequestId = 0
  end

end

RegisterNetEvent('luaconsole:serverCallback')
AddEventHandler('luaconsole:serverCallback', function(requestId, ...)
  ServerCallbacks[requestId](...)
  ServerCallbacks[requestId] = nil
end)
