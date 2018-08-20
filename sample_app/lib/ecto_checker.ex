defmodule SampleApp.EctoChecker do
  use PlugHealthCheck.Plugins.Ecto, repo: SampleApp.Repo
end
