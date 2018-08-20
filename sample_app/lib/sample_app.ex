defmodule SampleApp do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Adapters.Cowboy2, scheme: :http, plug: SampleApp.Router, options: [port: 8080]},
      {SampleApp.Repo, []}
    ]

    Logger.info("Started SampleApp application")

    Supervisor.start_link(children, strategy: :one_for_one, name: SampleApp.Supervisor)
  end
end
