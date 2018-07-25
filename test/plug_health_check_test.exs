defmodule PlugHealthCheckTest do
  use ExUnit.Case, async: true
  use Plug.Test

  doctest PlugHealthCheck

  defmodule BuggedServer do
    use GenServer

    def start_link(child_spec_list) do
      GenServer.start_link(__MODULE__, child_spec_list, name: __MODULE__)
    end

    def init(state) do
      {:ok, state}
    end

    def handle_cast(_request, state) do
      Process.exit(self(), :exit)
      {:noreply, state, state}
    end
  end

  setup do
    {:ok, good_supervisor_pid} = Supervisor.start_link([], strategy: :one_for_one)

    {:ok, bad_supervisor_pid} =
      Supervisor.start_link(
        [
          Supervisor.child_spec({BuggedServer, []}, id: BuggedServer, restart: :transient)
        ],
        strategy: :one_for_one
      )

    %{good_supervisor: good_supervisor_pid, bad_supervisor: bad_supervisor_pid}
  end

  test "uses default path", %{good_supervisor: supervisor_pid} do
    conn = conn(:get, "/_health")
    opts = PlugHealthCheck.init(supervisor: supervisor_pid)

    conn = PlugHealthCheck.call(conn, opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "overwrites default path", %{good_supervisor: supervisor_pid} do
    conn = conn(:get, "/other/path")
    opts = PlugHealthCheck.init(supervisor: supervisor_pid, path: "/other/path")

    conn = PlugHealthCheck.call(conn, opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "go to next Plug if path does not match", %{good_supervisor: supervisor_pid} do
    conn = conn(:get, "/other/path")
    opts = PlugHealthCheck.init(supervisor: supervisor_pid)

    conn = PlugHealthCheck.call(conn, opts)

    assert conn.state == :unset
  end

  test "send 503 if child process dies", %{bad_supervisor: supervisor_pid} do
    conn = conn(:get, "/other/path")
    opts = PlugHealthCheck.init(supervisor: supervisor_pid, path: "/other/path")

    GenServer.cast(BuggedServer, nil)

    conn = PlugHealthCheck.call(conn, opts)

    assert conn.state == :sent
    assert conn.status == 503
    assert conn.resp_body == "UNHEALTHY"
  end

  test "no supervisor configured" do
    conn = conn(:get, "/_health")
    opts = PlugHealthCheck.init([])

    conn = PlugHealthCheck.call(conn, opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end
end
