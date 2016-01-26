defmodule IfsQTest do
  use ExUnit.Case
  doctest IfsQ

  setup do
    on_exit fn ->
      unless :ets.info(:test_unit_pids) == :undefined, do: :ets.delete(:test_unit_pids)
      if GenServer.whereis(:ifs_dispatcher), do: IfsQ.stop
    end
  end

  test "this test suite starts fake eventer" do
    {:ok, response} = HTTPoison.get( "http://localhost:4848/hello")
    assert response.body == "world"
  end

  test "starting the ifs_q application creates a unit pid table" do
    IfsQ.start
    assert :ets.info(:test_unit_pids) != :undefined
    assert Enum.member?(:ets.all, :test_unit_pids)
  end

  test "stopping the ifs_q application deletes the units_pid table" do
    IfsQ.start
    IfsQ.stop
    assert :ets.info(:test_unit_pids) == :undefined
    assert Enum.member?(:ets.all, :test_unit_pids) == false

  end
end
