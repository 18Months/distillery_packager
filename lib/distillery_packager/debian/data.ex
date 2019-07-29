defmodule DistilleryPackager.Debian.Data do
  @moduledoc """
  This module houses the logic required to build the data payload portion of the
  debian package.
  """
  alias DistilleryPackager.Utils.Compression
  alias DistilleryPackager.Utils.Config, as: ConfigUtil
  alias DistilleryPackager.Debian.Generators.{Upstart, Systemd, Sysvinit}
  alias Mix.Project

  import Distillery.Releases.Shell, only: [info: 1, debug: 1, error: 1]

  def build(dir, config) do
    data_dir = make_data_dir(dir, config)
    copy_release(data_dir, config)
    copy_additional_files(data_dir, config.additional_files)
    remove_targz_file(data_dir, config)
    DistilleryPackager.Utils.File.remove_fs_metadata(data_dir)
    case config.exclude_init_scripts do
      true ->
        debug("Excluding init scripts")
      _ ->
        Upstart.build(data_dir, config)
        Systemd.build(data_dir, config)
        Sysvinit.build(data_dir, config)
    end

    config = Map.put_new(
      config,
      :installed_size,
      DistilleryPackager.Utils.File.get_dir_size(data_dir)
    )

    System.cmd("chmod", ["-R", "og-w", data_dir])
    Compression.compress(
      data_dir,
      Path.join([data_dir, "..", "data.tar.gz"]),
      owner: config.owner
    )
    DistilleryPackager.Utils.File.remove_tmp(data_dir)

    {:ok, config}
  end

  # We don't use/need the .tar.gz file built by Distillery Packager, so
  # remove it from the data dir to reduce filesize.
  defp remove_targz_file(data_dir, config) do
    [data_dir, config.base_path, config.name,
    "#{config.name}-#{config.version}.tar.gz"]
      |> Path.join
      |> File.rm
  end

  defp make_data_dir(dir, config) do
    debug("Building debian data directory")
    data_dir = Path.join([dir, "data"])
    :ok = File.mkdir_p(data_dir)
    :ok = File.mkdir_p(Path.join([data_dir, config.base_path, config.name]))

    data_dir
  end

  defp copy_release(data_dir, config) do
    dest = Path.join([data_dir, config.base_path, config.name])
    src = src_path(config)

    debug("Copying #{src} into #{dest} directory")
    {:ok, _} = File.cp_r(src, dest)

    dest
  end

  def copy_additional_files(data_dir, [{src, dst} | tail]) do
    rel_dst = Path.join(data_dir, Path.relative(dst))
    rel_src = [
          ConfigUtil.rel_dest_path,
          "distillery_packager", "debian", "additional_files", src
        ] |> List.flatten |> Path.join

    case File.mkdir_p(rel_dst) do
      :ok -> info("Created #{rel_dst} directory for additional files")
      _ -> nil
    end

    case File.cp_r(rel_src, rel_dst) do
      {:ok, _} -> info("Copied #{rel_src} into #{rel_dst} directory")
      _ -> error("Copy #{rel_src} into #{rel_dst} directory failed")
    end

    copy_additional_files(data_dir, tail)
  end
  def copy_additional_files(data_dir, [_ | tail]) do
    error("Copy of a file in the additional file list has been skipped,
          invalid convention format")
    copy_additional_files(data_dir, tail)
  end
  def copy_additional_files(_, _), do: nil

  defp src_path(%{test_mode: true} = config) do
    Path.join([ConfigUtil.rel_dest_path, config.name])
  end
  defp src_path(config) do
    Path.join([Project.build_path, "rel", config.name])
  end

end
