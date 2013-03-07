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
  return lru_cache
end

function lru_print(cache)
  print("==== LRU ====")
  local cur = cache.tail
  while cur ~= nil do
    print(cur.key, cur.value)
    cur = cur.next
  end
end

function lru_cache_add_entry(cache, entry)
  cache.head.prev.next = entry
  entry.prev = cache.head.prev

  cache.head.prev = entry
  entry.next = cache.head

  cache.current_items = cache.current_items + 1
  cache.data[entry.key] = entry
end

function lru_cache_remove_entry(cache, entry)
  cache.current_items = cache.current_items - 1
  cache.data[entry.key] = nil

  entry.prev.next = entry.next
  entry.next.prev = entry.prev
end

function lru_cache_del_last_entry(cache)
  if cache.current_items ~= 0 then
    local entry = cache.tail.next
    lru_cache_remove_entry(cache, entry)

    -- call callback function if it's present
    if cache.evictfunc ~= nil then cache.evictfunc(entry.key, entry.value) end
  end
end

function lru_cache_set(cache, key, value)
  local entry = cache.data[key] 
  if entry ~= nil then 
    entry.value = value
    lru_cache_remove_entry(cache, entry)
    lru_cache_add_entry(cache, entry)
  else

    local entry = {
      -- If 'lru_cache_del_last_entry' is called the key is needed to remove
      -- the entry from cache.data
      key = key,
      value = value,
      next = nil,
      prev = nil
    }

    -- print("current_items", cache.current_items)

    if cache.current_items >= cache.maxsize then
      lru_cache_del_last_entry(cache)
    end
    lru_cache_add_entry(cache, entry)
  end
end

function lru_cache_get(cache, key)
  local entry = cache.data[key]

  if entry == nil then return nil end

  lru_cache_remove_entry(cache, entry)
  lru_cache_add_entry(cache, entry)        

  return entry.value
end

local cache = lru_cache_create(3, function(k, v) print("Evicted", k, v) end)

lru_cache_set(cache, "a", "1")
lru_cache_set(cache, "b", "2")
lru_cache_set(cache, "a", "1")
lru_cache_set(cache, "c", "3")
lru_cache_set(cache, "d", "4")
lru_print(cache)