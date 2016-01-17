defmodule IfsQTest do
  use ExUnit.Case
  doctest IfsQ

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "this test starts fake eventer" do
    {:ok, response} = HTTPoison.get( "http://localhost:4848/hello")
    assert response.body == "world"
  end
end
