defmodule DistilleryPackager.Debian.Generators.Systemd do
  @moduledoc """
  This module produces a systemd unit file from the config and a template.
  """
  alias DistilleryPackager.Debian.Generators.TemplateFinder

  import Distillery.Releases.Shell, only: [debug: 1]

  def build(data_dir, config) do
    debug "Building Systemd Service File"

    systemd_script =
      ["init_scripts", "systemd.service.eex"]
        |> TemplateFinder.retrieve
        |> EEx.eval_file([
            description: config.description,
            name: config.name,
            base_path: config.base_path,
            uid: config.owner[:user],
            gid: config.owner[:group]
        ])

    out_dir =
      [data_dir, "lib", "systemd", "system"]
        |> Path.join

    :ok = File.mkdir_p(out_dir)

    :ok =
      [out_dir, config.sanitized_name <> ".service"]
        |> Path.join
        |> File.write(systemd_script)
  end
end
