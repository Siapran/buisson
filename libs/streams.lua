local Stream = {}

-- The low level stream constructor receives a generator function
-- similar to the one coroutine.wrap would return. You could change the API
-- to something returning multiple values, like ipairs does. 
function Stream:new(gen)
	local stream = { _next = gen }
	setmetatable(stream, self)
	self.__index = self
	return stream
end

function Each(list)
	return Stream:new(coroutine.wrap(function()
		for _, x in ipairs(list) do
			coroutine.yield(x)
		end
	end))
end

-- Receives a predicate and returns a filtered Stream
function Stream:Filter(pred)
	return Stream:new(coroutine.wrap(function()
		for x in self._next do
			if pred(x) then
				coroutine.yield(x)
			end
		end
	end))
end

function Stream:Map(func)
	return Stream:new(coroutine.wrap(function()
		for x in self._next do
			coroutine.yield(func(x))
		end
	end))
end

function Stream:Foreach(func)
	for x in self._next do
		func(x)
	end
end

function Stream:Limit(n)
	return Stream:new(coroutine.wrap(function()
		for n=1,n do
			local x = self._next()
			if not x then return end
			coroutine.yield(func(x))
		end
	end))
end

function Stream:Count()
	local n = 0
	for _ in self._next do
		n = n + 1
	end
	return n
end

function Stream:ToList()
	local tab = {}
	for x in self._next do
		table.insert(tab, x)
	end
	return tab
end

math.randomseed( os.time() )

local tab = Stream:new(coroutine.wrap(function()
	for i=1,100 do
		coroutine.yield(math.random(100))
	end
end)):Filter(function(x) return x <= 50 end):ToList()

for k,v in pairs(tab) do
	print(k,v)
end