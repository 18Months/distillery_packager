defmodule Mix.Tasks.Release.Deb.GenerateTemplates do
  @moduledoc """
  This module provides a task for copy debian template files into
  ./rel/distillery_packager/debian/templates
  """

  use Mix.Task

  import Distillery.Releases.Shell

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  def run(_args) do
    make_dirs()
    copy_templates()
  end

  defp copy_templates(dest \\ destination_dir()) do
    info "Copying templates to ./rel/distillery_packager/debian/templates"
    {:ok, _} =
      [ConfigUtil.root, "templates", "debian"]
        |> Path.join
        |> File.cp_r(dest, fn(_source, destination) ->
          IO.gets("Overwriting #{destination |> Path.basename }. " <>
                  "Type y to confirm: ") == "y\n"
        end)
  end

  defp make_dirs do
    info "Making ./rel/distillery_packager/debian/templates directory"
    :ok =
      destination_dir()
        |> File.mkdir_p
  end

  defp destination_dir do
    [ConfigUtil.rel_dest_path, "distillery_packager", "debian", "templates"]
      |> Path.join
  end
end
