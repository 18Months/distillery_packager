defmodule DistilleryPackager.Debian.Generators.Changelog do
  @moduledoc """
  This module produces boilerplate changelog data that's required to build a
  valid deb file.
  """
  alias DistilleryPackager.Debian.Generators.TemplateFinder
  alias DistilleryPackager.Utils.Compression

  import Mix.Releases.Logger, only: [debug: 1]

  def build(data_dir, config) do
    debug "Building Changelog file"

    {:ok, time} =
      Timex.now
        |> Timex.format("%a, %d %b %Y %H:%M:%S GMT", :strftime)

    changelog =
      ["changelog.eex"]
        |> TemplateFinder.retrieve
        |> EEx.eval_file([
          sanitized_name: config.sanitized_name,
          version: config.version,
          maintainers: config.maintainers,
          time: time
        ])

    doc_dir =
      [data_dir, "usr", "share", "doc", config.sanitized_name]
        |> Path.join

    :ok = File.mkdir_p(doc_dir)

    :ok =
      [doc_dir, "changelog"]
        |> Path.join
        |> File.write(changelog)

    Compression.compress(doc_dir, "../changelog.gz")

    [doc_dir, "changelog"]
      |> Path.join
      |> File.rm

    [doc_dir, "../changelog.gz"]
      |> Path.join
      |> File.rename(Path.join([doc_dir, "changelog.gz"]))
  end
end
