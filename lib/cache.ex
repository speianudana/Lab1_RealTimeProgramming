defmodule CacheServer do
  use GenServer
  @name CS

  ## Client API
  #initializes the database
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: CS])
  end

  #writes the data in the cache
  #key-weather rules and messages,val-data for these keys
  def write(key, val) do
    GenServer.cast(@name, {:write, key, val})
  end

  #
  def read(key) do
    GenServer.call(@name, {:read, key})
  end
  #la fiecare 5 sec se sterg datele procesate pe baza la cheie
  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end
  #clears all from cache
  def clear() do
    GenServer.cast(@name, {:clear})
  end

  #verifies if the key exists
  def exists?(key) do
    GenServer.call(@name, {:exists?, key})
  end

  ## Server API
  #it is called after start_link
  def init(:ok) do
    {:ok, %{}}
  end

  #updates the state of the actor
  def handle_call({:read, key}, _from, cache) do
    {:reply, cache[key], cache}
  end

  def handle_call({:exists?, key}, _from, cache) do
    {:reply, Map.has_key?(cache, key), cache}
  end

  #saves the cache value in the GenServer state
  def handle_cast({:write, key, val}, cache) do
    {:noreply, Map.put(cache, key, val)}
  end

  def handle_cast({:delete, key}, cache) do
    {:noreply, Map.delete(cache, key)}
  end

  def handle_cast({:clear}, _cache) do
    {:noreply, %{}}
  end

end