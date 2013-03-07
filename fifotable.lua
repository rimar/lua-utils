function fifoTable(maxSize, t)
  local currentIndex = 1
  local metaTable = {}

  metaTable.__index = {

    put = function(self, key,value)
      rawset(self, key, value)
      rawset(self, currentIndex, key)
      currentIndex = currentIndex % maxSize + 1
    end,

    ordered = function (t)
      local myIndex = currentIndex
      local stop = false
      local function iter(t)
        if stop then return end
        while true do
          local key = t[myIndex]
          myIndex = myIndex % maxSize + 1
          if myIndex == currentIndex then stop = true end
          if key then return key, t[key] end
        end
      end
      return iter, t
    end,

    show = function(t)
      print (t.__name .. ":")
      for k, v in t:ordered() do print(k, v) end
    end

  }

  return setmetatable(t or {}, metaTable)
end

tab = fifoTable (3, {__name = "table 1"})
tab:put("firstName", "Rici")
tab:put("lastName",  "Lake")
tab:show()
tab:put("firstName", "Rici")
tab:show()
tab:put("maternalLastName", "Papert")
tab:show()

