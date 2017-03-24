defmodule Mix.Tasks.Release.Deb.PrepareBasePath do
  @shortdoc "Creating base directories path"

  use Mix.Task

  import Mix.Releases.Logger

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  def run(_args) do
    make_dirs()
  end

  defp make_dirs do
    info "Making ./rel/distillery_packager/debian/additional_files directory"
    :ok =
      additional_files_dir()
        |> File.mkdir_p
  end

  defp additional_files_dir do
    [ConfigUtil.rel_dest_path, "distillery_packager", "debian", "additional_files"]
      |> Path.join
  end

end
