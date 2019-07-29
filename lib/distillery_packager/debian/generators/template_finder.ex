defmodule DistilleryPackager.Debian.Generators.TemplateFinder do
  @moduledoc """
  This module decides whether to use a custom template or to use the default.
  """
  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  import Distillery.Releases.Shell, only: [debug: 1, info: 1]

  def retrieve(pathname) do
    path = user_provided_path(pathname)
    case File.exists?(path) do
      true  ->
        info "Using user-provided file: #{path |> Path.basename}"
        path
      false ->
        debug("Using default file: #{path |> Path.basename}"
           <> " - didn't find user-provided one")
        default_path(pathname)
    end
  end

  defp user_provided_path(pathname) do
    [
      ConfigUtil.rel_dest_path,
      "distillery_packager", "debian", "templates", pathname
    ]
      |> List.flatten
      |> Path.join
  end

  defp default_path(pathname) do
    [
      ConfigUtil.root,
      "templates", "debian", pathname
    ]
      |> List.flatten
      |> Path.join
  end
end
