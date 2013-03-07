function lru_cache_create(maxsize, evictfunc)

  local lru_cache = {
    -- Number of current cache entries
    current_items = 0,
    -- Number of maximum cache entries
    maxsize = maxsize,

    head = {key = "__head__", next = nil, prev = nil},
    tail = {key = "__tail__", next = nil, prev = nil},

    -- Callback function when last member is getting evicted
    evictfunc = evictfunc,

    -- Stores the cache entries
    data = {}
  }
  -- head/tail are nodes in the linked list, which are never be dropped.
  -- They are sentinels which make the operations on the linked list easier
  lru_cache.head.prev = lru_cache.tail
  lru_cache.tail.next = lru_cache.head

  local function add_entry(cache, entry)
    cache.head.prev.next = entry
    entry.prev = cache.head.prev

    cache.head.prev = entry
    entry.next = cache.head

    cache.current_items = cache.current_items + 1
    cache.data[entry.key] = entry
  end

  local function remove_entry(cache, entry)
    cache.current_items = cache.current_items - 1
    cache.data[entry.key] = nil

    entry.prev.next = entry.next
    entry.next.prev = entry.prev
  end

  local function remove_last(cache)
    if cache.current_items ~= 0 then
      local entry = cache.tail.next
      remove_entry(cache, entry)

      -- call callback function if it's present
      if cache.evictfunc ~= nil then cache.evictfunc(entry.key, entry.value) end
    end
  end

  local mt = {}
  mt.__index = {}
  mt.__index.put = function(cache, key, value)
    local entry = cache.data[key]
    if entry ~= nil then
      entry.value = value
      remove_entry(cache, entry)
      add_entry(cache, entry)
    else

      local entry = {
        key = key,
        value = value,
        next = nil,
        prev = nil
      }

      -- print("current_items", cache.current_items)

      if cache.current_items >= cache.maxsize then
        remove_last(cache)
      end
      add_entry(cache, entry)
    end
  end

  mt.__index.get = function(cache, key)
    local entry = cache.data[key]

    if entry == nil then return nil end

    remove_entry(cache, entry)
    add_entry(cache, entry)

    return entry.value
  end

  mt.__index.foreach = function(cache, func)
    local cur = cache.tail.next
    while cur ~= cache.head do
      func(cur.key, cur.value)
      cur = cur.next
    end
  end

  return setmetatable(lru_cache, mt)
end

local cache = lru_cache_create(3, function(k, v) print("Evicted", k, v) end)

cache:put("a", "1")
cache:put("b", "2")
cache:put("a", "1")
cache:put("c", "3")
cache:put("d", "4")

print("cache:get(d)", cache:get("d"))

cache:foreach(print)

