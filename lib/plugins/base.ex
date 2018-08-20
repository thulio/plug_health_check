defmodule PlugHealthCheck.Plugins.Base do
  @moduledoc """
  PlugHealthCheck behaviour for plugins
  """
  @callback ping() :: :ok | {:error, atom()}
end
