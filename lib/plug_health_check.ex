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
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "OK")
    else
      conn
    end
  end
end
