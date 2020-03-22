defmodule ChalkTest do
  use ExUnit.Case
  doctest Chalk

  test "greets the world" do
    assert Chalk.hello() == :world
  end
end
