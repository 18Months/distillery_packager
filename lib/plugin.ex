defmodule DistilleryPackager.Plugin do
  @moduledoc """
  This module provides integration with
  [Distillery](https://github.com/bitwalker/distillery)'s plugin system.
  """
  use Distillery.Releases.Plugin

  alias DistilleryPackager.Debian.Config

  def before_assembly(release, _options), do: release
  def after_assembly(release = %Release{}, options) do
    info "Building Deb Package"
    case Config.build_config(release, options) do
      {:ok, config} ->
        DistilleryPackager.start_build(config)
        release
      _ -> nil
    end
  end
  def after_assembly(release, _options), do: release

  def before_package(release, _options), do: release
  def after_package(release, _options), do: release

  def before_release(release, _options), do: release
  def after_release(release, _options), do: release

  def after_cleanup(_args, _options) do
    DistilleryPackager.remove_deb_dir
    :ok
  end
end
