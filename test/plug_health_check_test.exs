defmodule PlugHealthCheckTest do
  use ExUnit.Case, async: true
  use Plug.Test

  doctest PlugHealthCheck

  describe "without plugins" do
    test "uses default path" do
      conn = conn(:get, "/_health")
      opts = PlugHealthCheck.init([])
      conn = PlugHealthCheck.call(conn, opts)

      assert conn.status == 200
      assert conn.resp_body == "OK"
    end

    test "overwrites default path" do
      conn = conn(:get, "/other/path")
      opts = PlugHealthCheck.init(path: "/other/path")

      conn = PlugHealthCheck.call(conn, opts)

      assert conn.status == 200
      assert conn.resp_body == "OK"
    end

    test "go to next Plug if path does not match" do
      conn = conn(:get, "/other/path")

      conn = PlugHealthCheck.call(conn, [])

      assert conn.state == :unset
    end
  end

  describe "with plugins" do
    defmodule HealthyPlugin do
      @behaviour PlugHealthCheck.Plugins.Base

      @impl true
      def ping do
        :ok
      end
    end

    defmodule UnhealthyPlugin do
      @behaviour PlugHealthCheck.Plugins.Base

      @impl true
      def ping do
        {:error, :unhealthy_plugin}
      end
    end

    defmodule SlowPlugin do
      @behaviour PlugHealthCheck.Plugins.Base

      @impl true
      def ping do
        Process.sleep(100)
        :ok
      end
    end

    test "single plugin healthy" do
      conn = conn(:get, "/_health")
      opts = PlugHealthCheck.init(plugins: [HealthyPlugin])
      conn = PlugHealthCheck.call(conn, opts)

      assert conn.status == 200
      assert conn.resp_body == "OK"
    end

    test "single plugin unhealthy" do
      conn = conn(:get, "/_health")
      opts = PlugHealthCheck.init(plugins: [UnhealthyPlugin])
      conn = PlugHealthCheck.call(conn, opts)

      assert conn.status == 503
      assert conn.resp_body == "[:unhealthy_plugin]"
    end

    test "both plugins" do
      conn = conn(:get, "/_health")
      opts = PlugHealthCheck.init(plugins: [HealthyPlugin, UnhealthyPlugin])
      conn = PlugHealthCheck.call(conn, opts)

      assert conn.status == 503
      assert conn.resp_body == "[:unhealthy_plugin]"
    end

    test "slow response" do
      conn = conn(:get, "/_health")
      opts = PlugHealthCheck.init(plugins: [SlowPlugin], timeout: 50)
      conn = PlugHealthCheck.call(conn, opts)

      assert conn.status == 503
      assert conn.resp_body == "[PlugHealthCheckTest.SlowPlugin_timeout]"
    end
  end
end
