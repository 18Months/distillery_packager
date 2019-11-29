defmodule DistilleryPackager.Debian.Config do
  @moduledoc """
  This module is used to capture the configuration of the debian package build.
  The module also includes validation functionality which is used to ensure that
  the data is in the correct format.
  """

  defstruct name: nil, version: nil, arch: nil, description: nil, vendor: nil,
            maintainers: nil, homepage: nil, external_dependencies: nil,
            maintainer_scripts: [], config_files: [], base_path: "/opt",
            additional_files: [], owner: [user: "root", group: "root"],
            package_name: nil, exclude_init_scripts: nil

  use Vex.Struct

  alias DistilleryPackager.Utils
  alias Mix.Project

  import Distillery.Releases.Shell, only: [error: 1]

  validates :name, presence: true
  validates :version, presence: true
  validates :arch, presence: true
  validates :description, presence: true
  validates :vendor, presence: true
  validates :maintainers, presence: true
  validates :homepage, presence: true
  validates :base_path, presence: true
  validates [:owner, :user], presence: true
  validates [:owner, :group], presence: true

  def build_config(release = %Distillery.Releases.Release{}, options) do
    base_config =
      [
        {:name, Atom.to_string(release.name)},
        {:version, format_package_version(release.version, options)},
        {:arch, format_package_arch(options)},
        {:description, Project.config[:description]}
      ] ++ config_from_package(Project.config[:deb_package])

    base_config =
      base_config
        |> Enum.dedup
        |> Enum.reject(&is_nil(&1))
        |> Enum.into(%{})

    DistilleryPackager.Debian.Config
      |> struct(base_config)
      |> DistilleryPackager.Utils.Config.sanitize_config
      |> check_valid
  end

  defp format_package_arch(%{architecture: arch}), do: arch
  defp format_package_arch(_), do: Utils.Config.detect_arch

  defp format_package_version(version, %{distribution: distribution}) do
    "#{version}~#{distribution}"
  end
  defp format_package_version(version, _), do: version

  defp config_from_package(nil) do
    """
    Error: You haven't defined any 'package' data in mix.exs.
    Check the configuration section of the github repository to
    see how to add this in.
    """
    |> String.replace("\n", " ")
    |> throw
  end
  defp config_from_package(value) when is_list(value) do
    value
    |> Enum.map(fn({key, value}) -> handle_config(key, value) end)
    |> Enum.dedup
    |> Enum.reject(&(is_nil(&1)))
  end

  @joining_list_values [:maintainers, :external_dependencies]

  defp handle_config(key, [_ | _] = value) when key in @joining_list_values do
    {key, Enum.join(value, ", ")}
  end
  defp handle_config(:config_files, value) do
    {:config_files, value}
  end
  defp handle_config(:additional_files, value) do
    {:additional_files, value}
  end
  defp handle_config(:maintainer_scripts, [_ | _] = value) do
    {:maintainer_scripts, value}
  end
  defp handle_config(:homepage, value) when is_bitstring(value) do
    {:homepage, value}
  end
  defp handle_config(:vendor, value) when byte_size(value) > 0 do
    {:vendor, value}
  end
  defp handle_config(:base_path, value) do
    {:base_path, Path.absname(value, "/")}
  end
  defp handle_config(:owner, value) when is_list(value) do
    handle_config(:owner, Enum.into(value, %{}))
  end
  defp handle_config(:owner, %{user: user, group: group})
      when user != nil and group != nil do
    {:owner, [user: user, group: group]}
  end
  defp handle_config(:package_name, value) do
    {:package_name, value}
  end
  defp handle_config(:exclude_init_scripts, value) do
    {:exclude_init_scripts, value}
  end
  defp handle_config(_, _), do: nil

  defp check_valid(config = %DistilleryPackager.Debian.Config{}) do
    # Use Vex to validate whether the config is valid. If not,
    # then raise an error with a list of config errors
    if Vex.valid?(config) do
      {:ok, config}
    else
      error "The configuration is invalid!"
      for err = {:error, _field, _type, _msg} <- Vex.errors(config) do
        print_validation_error(err)
      end
      {:error, Vex.errors(config)}
    end
  end

  defp print_validation_error(
    {:error, field, _type, msg}) when is_atom(field) do
    error(" - '#{Atom.to_string(field)}' #{msg}")
  end
  defp print_validation_error(
    {:error, field, _type, msg}) when is_list(field) do
    field = Enum.map_join(field, " -> ", &("'#{&1}'"))
    error(" - #{field} #{msg}")
  end
end
