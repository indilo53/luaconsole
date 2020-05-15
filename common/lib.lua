function catch(what)
	return what[1]
end

function try(what)
	status, result = pcall(what[1])
	if not status then
      what[2](result)
	end
	return result
end

function escapeObject(t)

  if type(t) == 'table' then

			if t.__cfx_functionReference ~= nil then
				return '__FUNCTION__'
			end

			local target = {}

			for k,v in pairs(t) do
				target[k] = escapeObject(v)
			end

			return target

  else

		if type(t) == 'function' then
			return '__FUNCTION__'
		elseif type(t)  == 'vector3' then
			return {x = t.x, y = t.y, z = t.z}
		else
			return t
		end

  end

  return target

end
