defmodule WEATHERTest do
  use ExUnit.Case
  doctest WEATHER

  test "greets the world" do
    assert WEATHER.hello() == :world
  end
end
