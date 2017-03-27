# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :distillery_packager,
  root: __DIR__ |> Path.absname |> Path.dirname
