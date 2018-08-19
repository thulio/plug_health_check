defmodule PlugHealthCheckTest do
  use ExUnit.Case, async: true
  use Plug.Test

  doctest PlugHealthCheck

  test "uses default path" do
    conn = conn(:get, "/_health")
    opts = PlugHealthCheck.init([])
    conn = PlugHealthCheck.call(conn, opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "overwrites default path" do
    conn = conn(:get, "/other/path")
    opts = PlugHealthCheck.init(path: "/other/path")

    conn = PlugHealthCheck.call(conn, opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "go to next Plug if path does not match" do
    conn = conn(:get, "/other/path")

    conn = PlugHealthCheck.call(conn, [])

    assert conn.state == :unset
  end
end
