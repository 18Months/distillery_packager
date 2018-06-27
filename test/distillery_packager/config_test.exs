defmodule DistilleryPackagerTest.ConfigTest do
  use ExUnit.Case, async: false

  import DistilleryPackager.Utils.Config, only: [sanitize_config: 1,
                                                 validate_package_name: 1]

  test "Configuration is sanitized correctly" do
    out = sanitize_config(%{ name: "0$!JIM-B+O.B,'" })
    assert Map.fetch!(out, :sanitized_name) == "0jim-b+o.b"
  end

  test "Sanitized configuration is validated" do
    catch_throw sanitize_config(%{ name: "-$!JIM-B+O.B,'" })
  end

  test "Package name allows a-z, 0-9, '+', '-' and '.'" do
    allowed_chars = "fo0-bar+ba.azd"
    assert validate_package_name(allowed_chars) == allowed_chars
  end

  test "Package name must have at least two characters" do
    assert validate_package_name("aa") == "aa"
    catch_throw validate_package_name("a")
  end

  test "Package name must begin with an alphanumeric character" do
    assert validate_package_name("0a") == "0a"
    catch_throw validate_package_name("+foo")
  end

  test "Package name must not contain upper-case letters" do
    catch_throw validate_package_name("Foo")
  end
end
