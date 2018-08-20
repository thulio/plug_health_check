defmodule SampleApp.Router do
  use Plug.Router

  plug(PlugHealthCheck, plugins: [SampleApp.EctoChecker, SampleApp.HTTPChecker])
  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Welcome"))
  match(_, do: send_resp(conn, 404, "Oops!"))
end
