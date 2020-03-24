defmodule MessageParseUtil do

  def iterate_rules(rules) do
    for rule  <-  rules do
      cond do
        rule =~ "temperature" ->
          if rule =~ ">" do
            ["temperature", ">", String.trim(List.last(String.split(rule, ">")))]
          else
            ["temperature", "<", String.trim(List.last(String.split(rule, "<")))]
          end
        rule =~ "light" ->
          if rule =~ ">" do
            ["light", ">", String.trim(List.last(String.split(rule, ">")))]
          else
            ["light", "<", String.trim(List.last(String.split(rule, "<")))]
          end
        rule =~ "athm_pressure" ->
          if rule =~ ">" do
            ["athm_pressure", ">", String.trim(List.last(String.split(rule, ">")))]
          else
            ["athm_pressure", "<", String.trim(List.last(String.split(rule, "<")))]
          end
        rule =~ "wind_speed" ->
          if rule =~ ">" do
            ["wind_speed", ">", String.trim(List.last(String.split(rule, ">")))]
          else
            ["wind_speed", "<", String.trim(List.last(String.split(rule, "<")))]
          end
        rule =~ "humidity" ->
          if rule =~ ">" do
            ["humidity", ">", String.trim(List.last(String.split(rule, ">")))]
          else
            ["humidity", "<", String.trim(List.last(String.split(rule, "<")))]
          end
        rule =~ "nothing matches" ->
          ["nothing matches", "=", "0"]
      end
    end
  end

  def parse_value(weather_rules) do
    for  weather_rule  <-  weather_rules do
      rule = String.replace(weather_rule, "if ", "")
      [head | remove_result] = String.split(rule, "then")
      weather_last_value = List.last(remove_result)
      list = iterate_rules(String.split(head, "and"))
      rules_value = Map.new()
      _ = Map.put(rules_value, String.trim(weather_last_value), list)
    end
  end

  def check_conditions(rule_operation, rule_value, sensor_value) do
    rule_operation=="<" && sensor_value < rule_value || rule_operation==">" && sensor_value > rule_value
  end

  def result_data(key, values, sensor_value) do
    result = for value <- values do
      rule_name = Enum.at(value, 0)
      rule_operation = Enum.at(value, 1)
      rule_value = String.to_integer(Enum.at(value, 2))
      if key==rule_name && check_conditions(rule_operation, rule_value, sensor_value) do
        key
      end
    end
    Enum.filter(result, & !is_nil(&1))
  end

  def check_parameters(sensor, weather_values) do
    data = for {key, sensor_value}  <-  sensor  do
      result_data(key, weather_values, sensor_value)
    end
    data_final = Enum.filter(data, fn x -> x != [] end)
    result_list = for value <- data_final, into: [], do: List.first(value)
    weather_list = for value <- weather_values, into: [], do: Enum.at(value, 0)
#    IO.inspect(weather_list)
#    IO.inspect(result_list)

    result_list == weather_list
  end

  def prediction(list) do
    gb = Enum.group_by(list, &(&1))
    max = Enum.map(gb, fn {_,val} -> length(val) end) |> Enum.max
    for {key,val} <- gb, length(val)==max, do: key
  end

  def get_message(message) do
    data = Poison.decode!(message)
    athm_pressure = (data["message"]["atmo_pressure_sensor_1"] + data["message"]["atmo_pressure_sensor_2"])/2
    humidity = (data["message"]["humidity_sensor_1"] + data["message"]["humidity_sensor_2"])/2
    wind_speed = (data["message"]["wind_speed_sensor_1"] + data["message"]["wind_speed_sensor_2"])/2
    light = (data["message"]["light_sensor_1"] + data["message"]["light_sensor_2"])/2
    temperature = (data["message"]["temperature_sensor_1"] + data["message"]["temperature_sensor_2"])/2
    [{"temperature", temperature}, {"light", light}, {"athm_pressure", athm_pressure}, {"wind_speed", wind_speed}, {"humidity", humidity}]
  end

end
