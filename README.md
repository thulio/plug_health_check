[![CircleCI](https://circleci.com/gh/thulio/plug_health_check.svg?style=svg)](https://circleci.com/gh/thulio/plug_health_check)
[![Coverage Status](https://coveralls.io/repos/github/thulio/plug_health_check/badge.svg?branch=master)](https://coveralls.io/github/thulio/plug_health_check?branch=master)

# PlugHealthCheck

A configurable plug to health check your web app.

# Usage

Add `PlugHealthCheck` to the top of you pipeline:

```elixir
defmodule SampleApp.Router do
  use Plug.Router

  plug(PlugHealthCheck)
  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Welcome"))
  match(_, do: send_resp(conn, 404, "Oops!"))
end
```

# Configuration

By default, PlugHealthCheck uses `/_health` as the default route. You can overwrite it with:

```elixir
plug(PlugHealthCheck, path: "/other/path")
```

### Plugins

`PlugHealthCheck` can be extended by using plugins. All you need to do is implement `PlugHealthCheck.Plugins.Base` and add it to the list of plugins:

```elixir
defmodule MyChecker do
  @behaviour PlugHealthCheck.Plugins.Base

  @impl true
  def ping do
    # Do some stuff
    :ok
  end
end


plug(PlugHealthCheck, plugins: [MyChecker])
```

PlugHealthCheck already comes with:

* A HTTP plugin. Example:
```elixir
defmodule MyHTTPChecker do
  use PlugHealthCheck.Plugins.HTTP, url: "http://google.com", status_code: 200
end


plug(PlugHealthCheck, plugins: [MyHTTPChecker])
```


* An [Ecto](https://github.com/elixir-ecto/ecto) plugin. Example:
```elixir
defmodule MyEctoChecker do
  use PlugHealthCheck.Plugins.Ecto, repo: MyApp.Repo
end


plug(PlugHealthCheck, plugins: [MyEctoChecker])
```
