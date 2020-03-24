defmodule ParseResult do
  use GenServer

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  def load(pid) do
    GenServer.cast(pid, {:load})
    pid
  end

  def await(pid), do: GenServer.call(pid, :get)

  def init(state), do: {:ok, state}

  def handle_call(:get, _, state), do: {:reply, state, state}

  def handle_cast({:load}, state) do
    {:noreply, long_process(state)}
  end

  def long_process(state) do
    process_messages(state[:weather_rules], state[:messages])
  end

  def restart_actor(weather_rules, messages) do
    {:stop, :connection_terminated, %{weather_rules: weather_rules, messages: messages}}
    start(%{weather_rules: weather_rules, messages: messages})
  end

  def process_messages(weather_rules, messages) do
    prediction = for message <- messages do
      if  message.data =~ "panic" do
        process_messages(weather_rules, List.delete(messages, message))
      else
        message_result = MessageParseUtil.get_message(message.data)
        weather_result = for rule_value  <-  weather_rules  do
          for  {weather_result , values}  <-  rule_value  do
            result = MessageParseUtil.check_parameters(message_result, values)
            if result do
              weather_result
            end
          end
        end
        if Enum.empty?(Enum.filter(Enum.concat(weather_result), & !is_nil(&1))) do
          [["NORMAL DAY"]]
        else
          weather_result
        end
      end
    end
    Enum.filter(Enum.concat(Enum.concat(prediction)), & !is_nil(&1))
  end
end