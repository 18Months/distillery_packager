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
  Sanitize certain elements so that they are filesystem safe.
  """
  def sanitize_config(config = %{}) do
    sanitized_name =
      config.name
        |> String.downcase
        |> String.replace(~r([^a-z\-\_\.]), "")

    Map.put(config, :sanitized_name, sanitized_name)
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
  def rel_dest_path(files) when is_list(files), do: Path.join([rel_dest_path()] ++ files)
  def rel_dest_path(file),                      do: Path.join(rel_dest_path(), file)
  @doc "Get the rel path of the current project."
  def rel_dest_path,                            do: Path.join(File.cwd!, "rel")

end
