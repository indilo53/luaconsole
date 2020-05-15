# luaconsole

- One-liner
- Editor
- Expression evaluator / Object explorer

![screenshot](https://i.ibb.co/bgVCkqD/Screenshot-10.png)

To integrate luaconsole with your resource, place this code in client / server or both :

```lua
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
```

To access **myResource** client environnment, just type **myResource** instead of **luaconsole**
To access **myResource** server environnment, type **@myResource** instead of luaconsole

Known bugs : 

- Crash when passing huge table to explorer (right pane)

### Don't start in server.cfg, instead ensure luaconsole when needed and stop it after
### Alt + C for opening ingame console when loaded
