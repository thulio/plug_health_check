defmodule SampleApp.HTTPChecker do
  use PlugHealthCheck.Plugins.HTTP, url: "http://google.com", status_code: 200
end
