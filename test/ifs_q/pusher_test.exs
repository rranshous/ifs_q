defmodule IfsQ.PusherTest do
  use ExUnit.Case
  doctest IfsQ.Pusher

  test "this should register a name" do
    {:ok, pid} = IfsQ.Pusher.start(:pusher_name)
    assert Process.info(pid)[:registered_name] == :pusher_name
  end
end
