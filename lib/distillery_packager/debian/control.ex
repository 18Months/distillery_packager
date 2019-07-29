defmodule DistilleryPackager.Debian.Control do
  @moduledoc """
  This module houses the logic required to build the control file and include
  custom control data such as pre/post install hooks.
  """
  alias DistilleryPackager.Debian.Generators.Control
  alias DistilleryPackager.Utils.Compression

  import Distillery.Releases.Shell, only: [debug: 1]

  # - Add ability to create pre-inst / post-inst hooks [WIP]
  def build(deb_root, config) do
    control_dir = Path.join([deb_root, "control"])

    debug "Building debian control directory"
    :ok = File.mkdir_p(control_dir)

    Control.build(config, control_dir)
    add_custom_hooks(config, control_dir)
    add_conffiles_file(config, control_dir)
    System.cmd("chmod", ["-R", "og-w", control_dir])
    Compression.compress(
      control_dir,
      Path.join([control_dir, "..", "control.tar.gz"]),
      owner: %{user: "root", group: "root"}
    )
    DistilleryPackager.Utils.File.remove_tmp(control_dir)

    :ok
  end

  defp add_conffiles_file(config, control_dir) do
    debug "Marking config files"
    config_files = config
      |> Map.get(:config_files, [])
      |> Enum.map_join(&(&1 <> "\n"))

    :ok =
      [control_dir, "conffiles"]
        |> Path.join()
        |> File.write(config_files)
  end

  defp add_custom_hooks(config, control_dir) do
    debug "Adding in custom hooks"
    for {type, path} <- config.maintainer_scripts do
      script =
        [File.cwd!, path]
          |> Path.join

      true = File.exists?(script)
      filename =
        case type do
          :pre_install    -> "preinst"
          :post_install   -> "postinst"
          :pre_uninstall  -> "prerm"
          :post_uninstall -> "postrm"
          _               -> Atom.to_string(type)
        end

      filename =
        [control_dir, filename]
          |> Path.join

      debug "Copying #{Atom.to_string(type)} file to #{filename}"
      File.cp(script, filename)
    end
  end
end
