defmodule PlugHealthCheck do
  @moduledoc false
  import Plug.Conn

  require Logger

  @default_path "/_health"
  @timeout 3_000

  def init(options) do
    Keyword.merge([path: @default_path, timeout: @timeout], options)
  end

  def call(conn, opts) do
    if conn.request_path == opts[:path] do
      with :ok <- check(opts[:plugins], opts[:timeout]) do
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "OK")
        |> halt()
      else
        {:errors, errors} ->
          conn
          |> put_resp_content_type("text/plain")
          |> send_resp(503, errors)
          |> halt()
      end
    else
      conn
    end
  end

  defp check(plugins, timeout) when is_list(plugins) do
    with tasks <- Enum.map(plugins, &do_check/1),
         returns <- Task.yield_many(tasks, timeout),
         statuses <- Enum.map(returns, &check_status/1),
         [] <- Enum.filter(statuses, fn status -> status != :ok end) do
      :ok
    else
      errors ->
        {:errors,
         inspect(Enum.flat_map(errors, fn error -> error |> Tuple.to_list() |> tl() end))}
    end
  end

  defp check(_plugins, _timeout) do
    :ok
  end

  defp do_check(plugin) do
    Task.async(plugin, :ping, [])
  end

  defp check_status({_task, {:ok, status}}) do
    status
  end

  defp check_status({task, _status}) do
    process = Process.info(task.pid)
    {module_name, _function, _args} = process[:dictionary][:"$initial_call"]
    Task.shutdown(task)
    {:error, :"#{module_name}_timeout"}
  end
end
