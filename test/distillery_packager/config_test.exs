defmodule DistilleryPackagerTest.ConfigTest do
  use ExUnit.Case

  test "Configuration is sanitized correctly" do
    out = %{ name: "$!JIM-B+O.B,'" }
      |> DistilleryPackager.Utils.Config.sanitize_config()

    assert Map.fetch!(out, :sanitized_name) == "jim-bo.b"
  end

end
