defmodule PlugHealthCheck.Plugins.HTTP do
  @moduledoc """
  A PlugHealthCheck plugin for HTTP services
  """
  defmacro __using__(url: url, status_code: status_code) do
    quote do
      @behaviour PlugHealthCheck.Plugins.Base

      def ping do
        with {:ok, {{_http_version, unquote(status_code), _}, _headers, _body}} <-
               :httpc.request(:get, {to_charlist(unquote(url)), []}, [], []) do
          :ok
        else
          _error ->
            parsed = URI.parse(unquote(url))
            {:error, :"#{parsed.host}_unavailable"}
        end
      end
    end
  end
end
