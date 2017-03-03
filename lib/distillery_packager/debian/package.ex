defmodule DistilleryPackager.Debian.Package do
  @moduledoc """
  This module is used to produce the final debian package file, using the "ar"
  compression tool.
  """
  import Logger, only: [debug: 1]

  def build(dir, config) do
    debug "Building deb file"

    out = Path.join([
      DistilleryPackager.Utils.Config.rel_dest_path,
      "#{config.sanitized_name}-#{config.version}_#{config.arch}.deb"
    ])

    File.rm out

    args = [
      "-qc",
      out,
      Path.join([dir, "debian-binary"]),
      Path.join([dir, "control.tar.gz"]),
      Path.join([dir, "data.tar.gz"]),
    ]

    {_response, 0} = System.cmd("ar", args)

    :ok
  end

end
