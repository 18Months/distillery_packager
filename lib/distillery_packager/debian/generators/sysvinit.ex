defmodule DistilleryPackager.Debian.Generators.Sysvinit do
  @moduledoc """
  This module produces a systemd unit file from the config and a template.
  """
  alias DistilleryPackager.Debian.Generators.TemplateFinder

  import Mix.Releases.Logger, only: [debug: 1]

  def build(data_dir, config) do
    debug "Building Sysvinit File"

    systemd_script =
      ["init_scripts", "sysvinit.service.eex"]
        |> TemplateFinder.retrieve
        |> EEx.eval_file([
            description: config.description,
            name: config.name,
            uid: config.owner[:user]
        ])

    out_dir =
      [data_dir, "etc", "init.d"]
        |> Path.join

    :ok = File.mkdir_p(out_dir)

    :ok =
      [out_dir, config.sanitized_name]
        |> Path.join
        |> File.write(systemd_script)
  end

end
