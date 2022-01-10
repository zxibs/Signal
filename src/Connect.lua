local strict = require(script.Parent:WaitForChild("strict"))
local SignalService = require(script.Parent)

local function createId(self)
	math.randomseed(#self.__connections)
    
	return tostring(math.random(math.huge, 1))
end

local function Connect(self, callbackFunction)
    -- selene: allow(incorrect_standard_library_use)
    assert(SignalService.isSignal(self) and type(callbackFunction) == "function")

	local id = createId(self)
	self.__callbacks[id] = callbackFunction

	local Connection = {
		__signal = self,
		__id = id,

		Connected = true,

		Disconnect = require(script.Parent:WaitForChild("Disconnect")),
	}

	Connection = strict(Connection, "Connection")
	self.__connections[id] = setmetatable({}, {
        __index = function(_self, index)
            if type(rawget(Connection, index)) == "function" then
                return function(_self, ...)
                    local args = table.pack(...)
                    for index1, argument in pairs(args) do
                        args[index1] = tostring(argument)
                    end

                    print(string.format("calling Connection:%s(%s)", tostring(index), table.unpack(args)))
                    return Connection[index](Connection, ...)
                end
            end

            return Connection[index]
        end,

        __newindex = function(_self, index, value)
            Connection[index] = value
        end
    })

	return Connection
end

return Connect
