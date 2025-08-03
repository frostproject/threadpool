local pool: { thread } = {}

local function run<T...>(callback: (T...) -> (), thread: thread, ...: T...): ()
   callback(...)
   table.insert(pool, thread)
end

local function loop(): ()
   while true do
      run(coroutine.yield())
   end
end

--[=[
   Spawns a new thread to run the given callback with the provided arguments. Similar to `task.spawn`.

   ```lua
   -- Output: "2 + 3 = 5"
   threadpool.spawn(function(a: number, b: number): ()
      print(`{a} + {b} = {a + b}`)
   end, 2, 3)
   ```

   @within threadpool
   @param callback (T...) -> () -- Function to run within the new thread
   @param ... T... -- Arguments passed to the callback
]=]
local function spawn<T...>(callback: (T...) -> (), ...: T...): ()
   local thread: thread
   local index: number = #pool

   if index > 0 then
      thread = pool[index]
      pool[index] = nil
   else
      thread = coroutine.create(loop)
      coroutine.resume(thread)
   end

   task.spawn(thread, callback, thread, ...)
end

--[=[
   Pseudo code threadpool implementation for Luau to manage concurrent task execution
   
   @class threadpool
]=]
return table.freeze {
   spawn = spawn,
}
