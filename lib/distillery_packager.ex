defmodule DistilleryPackager do
  @moduledoc """
  This module is used to kick off the debian package generation process.
  """
  import Mix.Releases.Logger, only: [info: 1, debug: 1]

  alias DistilleryPackager.Debian.{Control, Data, Package}
  alias Mix.Project

  def start_build(config) do
    DistilleryPackager.remove_deb_dir
    deb_root = initialize_deb_dir()

    {:ok, config} = Data.build(deb_root, config)
    :ok = Control.build(deb_root, config)
    :ok = Package.build(deb_root, config)

    info("A debian package has successfully been created." <>
         "You can find it in the ./rel directory")
  end

  def remove_deb_dir do
    [Project.build_path, "deb"]
      |> Path.join
      |> File.rm_rf
  end

  defp initialize_deb_dir do
    deb_root = Path.join([Project.build_path, "deb"])

    debug("Building base debian directory")
    :ok = File.mkdir_p(deb_root)

    debug("Adding debian-binary file")
    :ok = File.write(Path.join(deb_root, "debian-binary"), "2.0\n")

    deb_root
  end

end
