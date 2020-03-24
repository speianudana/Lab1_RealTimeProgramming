defmodule WEATHER do

  @doc """
      Start weather service by using:
      iex> WEATHER.start()
  """
  def start() do
    children = [
      {CacheServer, strategy: :one_for_one}, #actor for saving data in cache
      {HelpRequest, strategy: :one_for_one}, #actor for /help request
      {EventsourceEx, strategy: :one_for_one}, # actor for collecting stream data (uses SSE library and HTTP poison library  )
      {MessageParseActor, strategy: :one_for_one} #actor for parsing the data(messages)
    ]
    Supervisor.start_link(children, strategy: :one_for_one) #supervisor for monitoring children
  end
end