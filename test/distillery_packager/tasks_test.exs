defmodule DistilleryPackagerTest.GenerateTemplatesTest do
  use ExUnit.Case

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  setup_all do
    dest = [ConfigUtil.root, "rel"] |> Path.join

    Mix.Tasks.Release.Deb.PrepareBasePath.run(:test)
    Mix.Tasks.Release.Deb.GenerateTemplates.run(:test)

    on_exit fn ->
      File.rm_rf!(dest)
    end
  end

  test "Check that mix task creates correct base path directories" do
    dest = [ConfigUtil.root, "rel"] |> Path.join

    assert [dest, "distillery_packager", "debian", "additional_files"]
            |> Path.join |> File.exists?
  end

  test "Check that mix task copies over the config to the correct dir" do
    dest = [ConfigUtil.root, "rel"] |> Path.join

    assert [dest, "distillery_packager", "debian", "templates", "changelog.eex"]
            |> Path.join |> File.exists?
    assert [dest, "distillery_packager", "debian", "templates", "control.eex"]
            |> Path.join |> File.exists?

    assert [dest, "distillery_packager", "debian", "templates",
            "init_scripts", "systemd.service.eex"]
            |> Path.join
            |> File.exists?

    assert [dest, "distillery_packager", "debian", "templates",
            "init_scripts", "upstart.conf.eex"]
            |> Path.join
            |> File.exists?
  end
end
