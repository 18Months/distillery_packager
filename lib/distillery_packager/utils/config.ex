defmodule DistilleryPackager.Utils.Config do
  @moduledoc """
  This module is used to retrieve basic information for use with configuration
  """
  alias Mix.Project

  @doc """
  Use uname to detect the architecture we're currently building for
  """
  def detect_arch do
    {arch, 0} = System.cmd("uname", ["-m"])
    arch = String.replace(arch, "\n", "")
    case arch do
      "x86_64" -> "amd64"
      "noarch" -> "all"
      _ -> arch
    end
  end

  @doc """
  Sanitize certain elements so that they are filesystem safe, and fit within
  the Debian policy / conventions.
  """
  def sanitize_config(config = %{}) do
    Map.put(config, :sanitized_name, package_name(config))
  end

  @doc """
  Return a package name to use; either the provided `package_name` from
  configuration, or a sanitized version of `name` as a default.
  """
  def package_name(%{package_name: name}) when is_binary(name) do
    validate_package_name(name)
  end

  def package_name(config = %{}) do
    config.name
      |> String.downcase
      |> String.replace(~r([^a-z0-9+\-_.]), "")
      |> String.replace("_", "-")
      |> validate_package_name
  end

  @doc """
  Validate the provided package name and return it, or throw an error if it
  doesn't match against expectations.
  """
  def validate_package_name(name) when is_binary(name) do
    if Regex.match?(~r/^[a-z0-9][a-z0-9.+-]+$/, name) do
      name
    else
      """
      Error: Debian package names must consist only of lower case
      letters (a-z), digits (0-9), plus (+) and minus (-) signs,
      and periods (.). They must be at least two characters long
      and must start with an alphanumeric character.
      """
      |> String.trim
      |> String.replace("\n", " ")
      |> throw
    end
  end

  @doc """
  Retrieve the Application root, which is used when referring to relative files
  in the library (such as templates)
  """
  def root do
    Project.deps_paths
      |> Map.fetch(:distillery_packager)
      |> case do
           {:ok, path} -> path
           :error      -> # We're trying to build ourself!?
             Application.get_env(:distillery_packager, :root)
      end
  end

  @doc """
  Get the path to a file located in the rel directory of the current project.
  You can pass either a file name, or a list of directories to a file.
  """
  def rel_dest_path(files) when is_list(files),
      do: Path.join([rel_dest_path()] ++ files)
  def rel_dest_path(file),
      do: Path.join(rel_dest_path(), file)
  def rel_dest_path, do: Path.join(File.cwd!, "rel")
end
