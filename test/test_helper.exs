ExUnit.start()

defmodule TestHelper do
  def tmp_directory(path) do
    {:ok, _} = File.rm_rf(path)
    :ok = File.mkdir_p(path)
    {:ok, path}
  end

  def metadata do
    %{
      name:                  Faker.App.name,
      version:               Faker.App.version,
      vendor:                Faker.Company.name,
      arch:                  "amd64",
      maintainers:           ["#{Faker.Name.name} <#{Faker.Internet.email}>"],
      installed_size:        9999,
      external_dependencies: ["firefox"],
      homepage:              Faker.Internet.url,
      description:           Faker.Lorem.paragraph(1..5),
      maintainer_scripts:    [],
      config_files:          ["dummy_file"],
      owner:                 [user: "root", group: "root"],
      additional_files:      [],
      test_mode:             true,
      base_path:             "/opt",
      exclude_init_scripts:  nil
    } |> DistilleryPackager.Utils.Config.sanitize_config
  end
end
