defmodule DistilleryPackagerTest.TasksTest do
  use ExUnit.Case

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  setup_all do
    dest = ConfigUtil.rel_dest_path()

    Mix.Tasks.Release.Deb.PrepareBasePath.run(:test)
    Mix.Tasks.Release.Deb.GenerateTemplates.run(:test)

    on_exit fn ->
      File.rm_rf!(dest)
    end

    {:ok, dest: dest}
  end

  test "Check that mix task creates correct base path directories", config do
    assert [config.dest, "distillery_packager", "debian", "additional_files"]
            |> Path.join |> File.exists?
  end

  test "Check that mix task copies over the config", config do
    assert [config.dest, "distillery_packager", "debian",
            "templates", "control.eex"]
            |> Path.join |> File.exists?

    assert [config.dest, "distillery_packager", "debian",
            "templates", "init_scripts", "systemd.service.eex"]
            |> Path.join |> File.exists?

    assert [config.dest, "distillery_packager", "debian",
            "templates", "init_scripts", "upstart.conf.eex"]
            |> Path.join |> File.exists?
  end
end
