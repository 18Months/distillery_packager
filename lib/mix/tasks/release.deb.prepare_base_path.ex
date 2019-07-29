defmodule Mix.Tasks.Release.Deb.PrepareBasePath do
  @moduledoc """
  This module provides a task for preparing base path
  for debian packages
  """

  use Mix.Task

  import Distillery.Releases.Shell

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
    [ConfigUtil.rel_dest_path, "distillery_packager",
                               "debian", "additional_files"] |> Path.join
  end
end
