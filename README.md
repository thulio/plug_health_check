[![CircleCI](https://circleci.com/gh/thulio/plug_health_check.svg?style=svg)](https://circleci.com/gh/thulio/plug_health_check)
[![Coverage Status](https://coveralls.io/repos/github/thulio/plug_health_check/badge.svg?branch=master)](https://coveralls.io/github/thulio/plug_health_check?branch=master)

# PlugHealthCheck

A configurable plug to health check your web app.

# Usage

Add PlugHealthCheck to the top of you pipeline:

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
