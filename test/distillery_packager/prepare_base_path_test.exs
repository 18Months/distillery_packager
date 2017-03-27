defmodule DistilleryPackagerTest.PrepareBasePathTest do
  use ExUnit.Case, async: false

  alias DistilleryPackager.Utils.Config, as: ConfigUtil

  setup do
    dest = [ConfigUtil.root, "rel"] |> Path.join

    assert Mix.Tasks.Release.Deb.PrepareBasePath.run(:test)

    on_exit fn ->
      {:ok, _} = File.rm_rf(dest)
    end
  end

  test "Check that mix task creates correct base path directories" do
    dest = [ConfigUtil.root, "rel"] |> Path.join

    assert [dest, "distillery_packager", "debian", "additional_files"]
            |> Path.join |> File.exists?
  end
end
