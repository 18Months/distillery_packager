defmodule Mix.Tasks.Release.Deb.GenerateTemplates do
  @moduledoc """
  Copy Template files into project source directory so that
  users can modify them for their own purposes.

  ## Examples
  mix release.deb.generate_templates
  """
  @shortdoc "Copy debian template files into ./rel/distillery_packager/debian/templates"

  use Mix.Task

  import Mix.Releases.Logger

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  def run(_args) do
    make_dirs()
    copy_templates()
  end

  def copy_templates(dest \\ destination_dir()) do
    info "Copying templates to ./rel/distillery_packager/debian/templates"
    {:ok, _} =
      [ConfigUtil.root, "templates"]
        |> Path.join
        |> File.cp_r(dest, fn(_source, destination) ->
          IO.gets("Overwriting #{destination |> Path.basename }." <>
                  "Type y to confirm: ") == "y\n"
        end)
  end

  defp make_dirs do
    info "Making ./rel/distillery_packager/debian/templates directory"
    :ok =
      destination_dir()
        |> File.mkdir_p

    info "Making ./rel/distillery_packager/debian/additional_files directory"
    :ok =
      additional_files_dir()
        |> File.mkdir_p
  end

  defp destination_dir do
    [ConfigUtil.rel_dest_path, "distillery_packager", "debian", "templates"]
      |> Path.join
  end

  defp additional_files_dir do
    [ConfigUtil.rel_dest_path, "distillery_packager", "debian", "additional_files"]
      |> Path.join
  end

end
