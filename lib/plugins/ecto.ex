defmodule PlugHealthCheck.Plugins.Ecto do
  @moduledoc """
  A PlugHealthCheck plugin for Ecto
  """
  defmacro __using__(repo: repo) do
    quote do
      @behaviour PlugHealthCheck.Plugins.Base

      def ping do
        with {:ok, _result} <- unquote(repo).query("SELECT 1") do
          :ok
        else
          _error -> {:error, :ecto_unhealthy}
        end
      rescue
        _error -> {:error, :ecto_unhealthy}
      end
    end
  end
end
