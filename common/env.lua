ExecEnv = {}

ExecEnv.lc_print = function(str)
	
  print(str)
  
  if IsDuplicityVersion() then
    TriggerClientEvent('luaconsole:print_s', CurrentClient, str)
  else
    SendNUIMessage({action = 'print', str = str})
  end

end

ExecEnv.lc_clear = function()
  if IsDuplicityVersion() then
    TriggerClientEvent('luaconsole:clear_s', CurrentClient)
  else
    SendNUIMessage({action = 'clear'})
  end
end

ExecEnv.lc_dump = function(o, nb)
  
  if nb == nil then
    nb = 0
  end
  
  if type(o) == 'table' then
    local s = ''
    for i = 1, nb + 1, 1 do
      s = s .. "    "
    end
    s = '{\n'
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
        for i = 1, nb, 1 do
          s = s .. "    "
        end
      s = s .. '['..k..'] = ' .. ExecEnv.lc_dump(v, nb + 1) .. ',\n'
    end
    for i = 1, nb, 1 do
      s = s .. "    "
    end
    return s .. '}'
  else
    return tostring(o)
  end

end

ExecEnv.lc_hook = function(target, hookFunc)
	
	local code = ''

	if hookFunc == nil then

    code = [[
      _G['__LC_HOOKS'] = _G['__LC_HOOKS'] or {}
      @TARGET@ = _G['__LC_HOOKS']['@TARGET@'] or @TARGET@
      _G['__LC_HOOKS']['@TARGET@'] = nil
    ]]

	else

    code = [[
      _G['__LC_HOOKS']    = _G['__LC_HOOKS'] or {}
      local isHook        = _G['__LC_HOOKS']['@TARGET@'] ~= nil
      local prevHookFound = false
      local oldFunc       = nil

      if isHook then

        oldFunc = _G['__LC_HOOKS']['@TARGET@']
      
      else

        oldFunc = @TARGET@

        for k,v in pairs(_G['__LC_HOOKS']) do
          if v == @TARGET@ then
            isHook        = true
            prevHookFound = true
            oldFunc       = v
            break
          end
        end

      end

      local newFunc = function(...)
        return (@HOOK_FUNC@)(oldFunc, ...)
      end

      if (not isHook) or prevHookFound then
        _G['__LC_HOOKS']['@TARGET@'] = oldFunc
      end

      @TARGET@ = newFunc

      return oldFunc, newFunc
    ]]

    code = code:gsub('@HOOK_FUNC@', hookFunc)

	end

  code = code:gsub('@TARGET@', target)

	return Handlers[Handler](code, ExecEnv)()

end

ExecEnv.lc_ishook = function(target)
  
  local code = [[
    return _G['__LC_HOOKS'] ~= nil and _G['__LC_HOOKS']['@TARGET@'] ~= nil
  ]]

  code = code:gsub('@TARGET@', target)

  return Handlers[Handler](code, ExecEnv)()

end

ExecEnv.lc_getargs = function(target)
  
  local code = [[
    local args = {}
    local hook = debug.gethook()
    
    local argHook = function(...)

      local info = debug.getinfo(3)

      if 'pcall' ~= info.name then return end

      for i = 1, math.huge do
          
        local name, value = debug.getlocal(2, i)
        
        if '(*temporary)' == name then
          debug.sethook(hook)
          error('')
          return
        end

        table.insert(args, name)

      end

    end
    
    debug.sethook(argHook, "c")
    pcall(@TARGET@)
    
    return args
  ]]

  code = code:gsub('@TARGET@', target)

  return Handlers[Handler](code, ExecEnv)()

end