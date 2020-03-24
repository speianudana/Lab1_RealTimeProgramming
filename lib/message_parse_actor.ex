defmodule MessageParseActor do
  use GenServer

  def start_link(state \\ 0) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    schedule_post(state)
    {:ok, state}
  end

  defp schedule_post(_) do
    IO.puts "Collecting data..."
    Process.send_after(self(),:postSchedule, 5000) #start handle_info after 5 sec
  end

  #handling
  def handle_info(:postSchedule,state) do
    IO.puts "Calculating weather after 5 sec..."
    rules =  CacheServer.read(:weather_rules)
    messages = CacheServer.read(:messages)
    CacheServer.delete(:messages)
    data = Enum.chunk_every(messages, 50)
    start_children(rules, data)
    schedule_post(state)
    {:noreply,state}
  end

  #starts actors for processing the chunks of messages
  def start_children(weather_rules, list_messages) do
    result_message = for messages <- list_messages do
      0..Enum.count(messages)-1
               |> Enum.map(fn _ ->
        {:ok, pid} = ParseResult.start(%{weather_rules: weather_rules, messages: messages}) #start the actors for every chunk
          pid
        end)
               |> Enum.map(&ParseResult.load/1)
               |> Enum.map(&ParseResult.await/1)
    end

    IO.inspect(MessageParseUtil.prediction(Enum.concat(Enum.concat(result_message))))
  end
end
