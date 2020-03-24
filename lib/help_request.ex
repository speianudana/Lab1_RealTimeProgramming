defmodule HelpRequest do
  use GenServer

  #initialises the worker(GenServer)
  def start_link(state \\ 0) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    schedule_post(state)
    {:ok, state}
  end

  defp schedule_post(state) do
    IO.puts "Getting help data..."
    case HTTPoison.get("http://localhost:4000/help") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        rules = Poison.decode!(body)#convert info from /help String json to dictionary
        weather_rules = MessageParseUtil.parse_value(rules["the_weather_forecast_rules"])
        CacheServer.write(:weather_rules, weather_rules)
#        IO.inspect(weather_rules)
    end
    {:noreply,state}
  end
end