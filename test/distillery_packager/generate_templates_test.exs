defmodule DistilleryPackagerTest.GenerateTemplatesTest do
  use ExUnit.Case

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  test "Check that mix task copies over the config to the correct dir" do
    dest = [ConfigUtil.root, "rel"] |> Path.join

    assert Mix.Tasks.Release.Deb.GenerateTemplates.run(:test)
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

    assert File.rm_rf!(dest)
  end
end
