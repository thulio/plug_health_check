defmodule PlugHealthCheck do
  @moduledoc false
  import Plug.Conn

  require Logger

  @default_path "/_health"

  def init(options) do
    Keyword.merge([path: @default_path], options)
  end

  def call(conn, opts) do
    if conn.request_path == opts[:path] do
      if do_check(opts[:supervisor]) do
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "OK")
      else
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(503, "UNHEALTHY")
      end
    else
      conn
    end
  end

  defp do_check(nil), do: true

  defp do_check(supervisor) do
    %{active: active, specs: specs} = Supervisor.count_children(supervisor)

    active == specs
  end
end
