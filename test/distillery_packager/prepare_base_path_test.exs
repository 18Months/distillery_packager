defmodule DistilleryPackagerTest.PrepareBasePathTest do
  use ExUnit.Case

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  test "Check that mix task creates correct base path directories" do
    dest = [ConfigUtil.root, "rel"] |> Path.join

    assert Mix.Tasks.Release.Deb.PrepareBasePath.run(:test)
    assert [dest, "distillery_packager", "debian", "additional_files"]
            |> Path.join |> File.exists?

    assert File.rm_rf!(dest)
  end
end
